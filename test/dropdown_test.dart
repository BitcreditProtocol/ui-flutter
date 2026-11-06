// the menu opens from its trigger and closes on a pick or an outside tap, sizes
// to its rows unless given a width, stays clear of the screen's sides, and
// opens upwards when the trigger sits too low for it.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _screen = Size(400, 800);

Future<void> pump(
  WidgetTester tester,
  Widget dropdown, {
  Alignment at = Alignment.topCenter,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Align(alignment: at, child: dropdown),
      ),
    ),
  );
}

Widget _trigger() =>
    const SizedBox(width: 100, height: 40, child: Center(child: Text('Open')));

Future<void> open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pump();
}

Rect menu(WidgetTester tester) => tester.getRect(
  find.ancestor(of: find.text('First'), matching: find.byType(Container)).last,
);

void main() {
  group('Dropdown', () {
    testWidgets('opens below the trigger and closes on a pick', (tester) async {
      var picked = 0;

      await pump(
        tester,
        Dropdown(
          items: [
            DropdownItem(onTap: () => picked++, child: const Text('First')),
          ],
          child: _trigger(),
        ),
      );

      expect(find.text('First'), findsNothing);

      await open(tester);

      expect(find.text('First'), findsOneWidget);
      expect(menu(tester).top, 40 + 4);

      await tester.tap(find.text('First'));
      await tester.pump();

      expect(picked, 1);
      expect(find.text('First'), findsNothing);
    });

    testWidgets('an item can leave the menu open', (tester) async {
      var picked = 0;

      await pump(
        tester,
        Dropdown(
          items: [
            DropdownItem(
              closeOnTap: false,
              onTap: () => picked++,
              child: const Text('First'),
            ),
          ],
          child: _trigger(),
        ),
      );

      await open(tester);
      await tester.tap(find.text('First'));
      await tester.pump();

      expect(picked, 1);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('an outside tap closes it and reports both changes', (
      tester,
    ) async {
      final changes = <bool>[];

      await pump(
        tester,
        Dropdown(
          onOpenChanged: changes.add,
          items: const [DropdownItem(child: Text('First'))],
          child: _trigger(),
        ),
      );

      await open(tester);
      await tester.tapAt(const Offset(200, 700));
      await tester.pump();

      expect(find.text('First'), findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('a disabled item ignores taps', (tester) async {
      var picked = 0;

      await pump(
        tester,
        Dropdown(
          items: [
            DropdownItem(
              disabled: true,
              onTap: () => picked++,
              child: const Text('First'),
            ),
          ],
          child: _trigger(),
        ),
      );

      await open(tester);
      await tester.tap(find.text('First'));
      await tester.pump();

      expect(picked, 0);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('a disabled dropdown does not open', (tester) async {
      await pump(
        tester,
        Dropdown(
          disabled: true,
          items: const [DropdownItem(child: Text('First'))],
          child: _trigger(),
        ),
      );

      await open(tester);

      expect(find.text('First'), findsNothing);
    });

    testWidgets('fits its rows, but no narrower than minWidth', (tester) async {
      await pump(
        tester,
        Dropdown(
          items: const [DropdownItem(child: Text('First'))],
          child: _trigger(),
        ),
      );

      await open(tester);

      expect(menu(tester).width, Dropdown.minWidth);
    });

    testWidgets('a width wider than the screen keeps the margins', (
      tester,
    ) async {
      await pump(
        tester,
        Dropdown(
          width: 1000,
          items: const [DropdownItem(child: Text('First'))],
          child: _trigger(),
        ),
      );

      await open(tester);

      final rect = menu(tester);

      expect(rect.left, Dropdown.screenMargin);
      expect(rect.right, _screen.width - Dropdown.screenMargin);
    });

    testWidgets('lines up with the trigger by alignment', (tester) async {
      Future<Rect> openAligned(DropdownAlignment alignment) async {
        await pump(
          tester,
          Dropdown(
            key: ValueKey(alignment),
            alignment: alignment,
            width: 200,
            items: const [DropdownItem(child: Text('First'))],
            child: _trigger(),
          ),
        );
        await open(tester);

        return menu(tester);
      }

      final trigger = Rect.fromLTWH(150, 0, 100, 40);

      expect((await openAligned(DropdownAlignment.start)).left, trigger.left);
      await tester.tapAt(const Offset(200, 700));
      await tester.pump();

      expect((await openAligned(DropdownAlignment.end)).right, trigger.right);
      await tester.tapAt(const Offset(200, 700));
      await tester.pump();

      expect(
        (await openAligned(DropdownAlignment.center)).center.dx,
        trigger.center.dx,
      );
    });

    testWidgets('opens upwards when there is no room below', (tester) async {
      await pump(
        tester,
        Dropdown(
          items: [
            for (var i = 0; i < 5; i++)
              DropdownItem(child: Text(i == 0 ? 'First' : 'Row $i')),
          ],
          child: _trigger(),
        ),
        at: Alignment.bottomCenter,
      );

      await open(tester);

      expect(menu(tester).bottom, _screen.height - 40 - 4);
    });

    testWidgets('separates groups with a rule', (tester) async {
      await pump(
        tester,
        Dropdown(
          items: const [
            DropdownItem(child: Text('First')),
            DropdownSeparator(),
            DropdownItem(child: Text('Second')),
          ],
          child: _trigger(),
        ),
      );

      await open(tester);

      expect(find.byType(Separator), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Second')).dy -
            tester.getBottomLeft(find.text('First')).dy,
        6 + 4 + 1 + 4 + 6,
      );
    });
  });
}
