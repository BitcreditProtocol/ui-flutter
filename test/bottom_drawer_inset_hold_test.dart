import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bottom inset a drawer sits above when no keyboard is up.
const double _navBarHeight = 48;

/// The keyboard a *pushed* screen brings up — not the drawer's own.
const double _keyboardHeight = 300;

const Key _contentKey = Key('drawer-content');

/// The window's insets, drivable from a test: the keyboard belongs to the
/// window, so it changes for the drawer too, whatever route is on top of it.
Widget _app(
  ValueNotifier<EdgeInsets> viewInsets, {
  required WidgetBuilder builder,
}) => ValueListenableBuilder<EdgeInsets>(
  valueListenable: viewInsets,
  builder: (context, insets, _) => MediaQuery(
    data: MediaQueryData(
      viewInsets: insets,
      padding: const EdgeInsets.only(bottom: _navBarHeight),
      viewPadding: const EdgeInsets.only(bottom: _navBarHeight),
    ),
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  showBottomDrawer<void>(context, builder: builder),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('a drawer holds its position while another route is on top', (
    tester,
  ) async {
    // A screen pushed over a drawer — an authentication prompt, say — raises a
    // keyboard of its own, and the drawer is still painted for as long as the
    // push transition runs. Following the window insets there would show the
    // drawer sliding up behind the incoming screen.
    final viewInsets = ValueNotifier(EdgeInsets.zero);
    addTearDown(viewInsets.dispose);

    await tester.pumpWidget(
      _app(
        viewInsets,
        builder: (_) => const BottomDrawer(
          title: 'Limit amount',
          child: SizedBox(key: _contentKey, height: 100),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final atRest = tester.getRect(find.byKey(_contentKey)).bottom;

    // Not opaque: a route mid-transition still lets the drawer paint, which is
    // the window in which this was visible.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();

    viewInsets.value = const EdgeInsets.only(bottom: _keyboardHeight);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(_contentKey)).bottom,
      closeTo(atRest, 0.01),
      reason: 'the drawer moved with a keyboard that is not its own',
    );

    navigator.pop();
    await tester.pumpAndSettle();

    // Back on top, the drawer takes the insets again.
    viewInsets.value = EdgeInsets.zero;
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(_contentKey)).bottom,
      closeTo(atRest, 0.01),
    );
  });

  testWidgets('a covered drawer still follows its own keyboard down', (
    tester,
  ) async {
    // Opening a screen from a drawer that has a field focused closes that
    // keyboard and raises the new screen's in one go. The drawer belongs to
    // the first half of that: it should ride the insets down, then sit still
    // while they come back up for the screen now in front of it.
    final viewInsets = ValueNotifier(
      const EdgeInsets.only(bottom: _keyboardHeight),
    );
    addTearDown(viewInsets.dispose);

    await tester.pumpWidget(
      _app(
        viewInsets,
        builder: (_) => const BottomDrawer(
          title: 'Limit amount',
          child: SizedBox(key: _contentKey, height: 100),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final withKeyboard = tester.getRect(find.byKey(_contentKey)).bottom;

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
    await tester.pump();

    // The drawer's keyboard leaves...
    viewInsets.value = EdgeInsets.zero;
    await tester.pumpAndSettle();

    final settled = tester.getRect(find.byKey(_contentKey)).bottom;

    expect(
      settled - withKeyboard,
      closeTo(_keyboardHeight - _navBarHeight, 0.01),
      reason: 'the drawer did not come down with its own keyboard',
    );

    // ...and the pushed screen's arrives.
    viewInsets.value = const EdgeInsets.only(bottom: _keyboardHeight);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(_contentKey)).bottom,
      closeTo(settled, 0.01),
    );
  });

  testWidgets('a drawer still rises for its own keyboard', (tester) async {
    final viewInsets = ValueNotifier(EdgeInsets.zero);
    addTearDown(viewInsets.dispose);

    await tester.pumpWidget(
      _app(
        viewInsets,
        builder: (_) => const BottomDrawer(
          title: 'Limit amount',
          child: SizedBox(key: _contentKey, height: 100),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final atRest = tester.getRect(find.byKey(_contentKey)).bottom;

    viewInsets.value = const EdgeInsets.only(bottom: _keyboardHeight);
    await tester.pumpAndSettle();

    expect(
      atRest - tester.getRect(find.byKey(_contentKey)).bottom,
      closeTo(_keyboardHeight - _navBarHeight, 0.01),
    );
  });
}
