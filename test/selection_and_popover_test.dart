// Two things that only show up at scale or under an awkward parent: a long
// option list building every row, and a popover that could not be measured by
// the widgets that ask their children how big they want to be.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(theme: BitcrTheme.light, home: Scaffold(body: child)),
);

List<SelectionOption<int>> optionsOf(int count) => <SelectionOption<int>>[
  for (var i = 0; i < count; i++)
    SelectionOption<int>(value: i, label: 'Option $i'),
];

Widget drawerOf(List<SelectionOption<int>> options, {bool search = false}) =>
    SelectionDrawer<int>(
      title: 'Pick one',
      options: options,
      selected: 0,
      onSelect: (_) {},
      search: search
          ? const SelectionDrawerSearch(
              placeholder: 'Search',
              emptyTitle: 'Nothing',
              emptySubtitle: 'Try another word',
              clearLabel: 'Clear',
            )
          : null,
    );

void main() {
  group('SelectionDrawer', () {
    testWidgets('a short list builds every row, as it always did', (
      tester,
    ) async {
      await pump(tester, drawerOf(optionsOf(9)));

      expect(find.byType(SelectionRow, skipOffstage: false), findsNWidgets(9));
      // No `ListView`, so the sheet still sizes itself to its rows.
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a long list builds only what is on screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const count = 151;
      await pump(tester, drawerOf(optionsOf(count)));

      final built = find
          .byType(SelectionRow, skipOffstage: false)
          .evaluate()
          .length;
      expect(built, lessThan(count ~/ 2));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('a search that narrows a long list hugs its rows again', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pump(tester, drawerOf(optionsOf(151), search: true));
      expect(find.byType(ListView), findsOneWidget);

      // Down to one match, so the threshold applies to what is shown rather
      // than to the whole list and the sheet goes back to sizing to its rows.
      await tester.enterText(find.byType(TextField), 'Option 137');
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SelectionRow), findsOneWidget);
    });
  });

  group('TruncatedTextPopover', () {
    const long =
        'bitcrtCpWFrWCED9MnQEktCB8WY7Q77e1tlsEBEmbomu-gh49EnXDD5-ydhbXgvaHR0';

    testWidgets('lays out inside a parent that measures intrinsics', (
      tester,
    ) async {
      // `IntrinsicWidth` asks its child how wide it wants to be, which a
      // `LayoutBuilder` cannot answer -- it throws. Wrapping the text in one
      // therefore put this widget out of reach of `IntrinsicWidth`,
      // `IntrinsicHeight`, `DataTable` and `MenuAnchor`.
      await pump(
        tester,
        const IntrinsicWidth(
          child: TruncatedTextPopover(
            text: long,
            maxLength: 24,
            truncationMode: TruncationMode.middle,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('and inside a MenuAnchor panel', (tester) async {
      final controller = MenuController();
      await pump(
        tester,
        MenuAnchor(
          controller: controller,
          menuChildren: const <Widget>[
            TruncatedTextPopover(
              text: long,
              maxLength: 24,
              truncationMode: TruncationMode.middle,
            ),
          ],
          builder: (context, controller, _) => TextButton(
            onPressed: controller.open,
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('still truncates and still opens the whole value', (
      tester,
    ) async {
      await pump(
        tester,
        const SizedBox(
          width: 300,
          child: TruncatedTextPopover(
            text: long,
            maxLength: 24,
            truncationMode: TruncationMode.middle,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Shortened in place, with the middle gone and both ends kept.
      expect(find.text(long), findsNothing);
      expect(find.textContaining('…'), findsOneWidget);

      await tester.tap(find.textContaining('…'));
      await tester.pumpAndSettle();

      expect(find.text(long), findsOneWidget);
    });

    testWidgets('leaves a short value alone', (tester) async {
      await pump(
        tester,
        const SizedBox(
          width: 300,
          child: TruncatedTextPopover(text: 'short', maxLength: 24),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('short'), findsOneWidget);
    });
  });
}
