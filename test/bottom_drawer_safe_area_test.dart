import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `showModalBottomSheet(useSafeArea: true)` expands to `SafeArea(bottom:
/// false)`, so the sheet deliberately leaves the bottom inset to its contents.
/// Drawers that pass their own layout rather than a [BottomDrawer] used to have
/// nothing applying it, and ran under the Android navigation bar.
const double _navBarHeight = 48;

/// A drawer built by hand — the shape most call sites use, and the one that had
/// no bottom inset of its own.
const Key _customContentKey = Key('custom-drawer-content');

Widget _app({required WidgetBuilder builder}) => MediaQuery(
  data: const MediaQueryData(
    padding: EdgeInsets.only(bottom: _navBarHeight),
    viewPadding: EdgeInsets.only(bottom: _navBarHeight),
  ),
  child: MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showBottomDrawer<void>(context, builder: builder),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _openDrawer(WidgetTester tester, WidgetBuilder builder) async {
  await tester.pumpWidget(_app(builder: builder));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a custom drawer clears the system navigation bar', (
    tester,
  ) async {
    await _openDrawer(
      tester,
      (_) => Container(
        key: _customContentKey,
        height: 200,
        color: const Color(0xFF000000),
      ),
    );

    final screenBottom = tester.getSize(find.byType(MaterialApp)).height;
    final contentBottom = tester.getRect(find.byKey(_customContentKey)).bottom;

    expect(screenBottom - contentBottom, greaterThanOrEqualTo(_navBarHeight));
  });

  testWidgets('a BottomDrawer clears it without double padding', (
    tester,
  ) async {
    await _openDrawer(
      tester,
      (_) => const BottomDrawer(
        title: 'Filters',
        child: SizedBox(key: _customContentKey, height: 100),
      ),
    );

    final screenBottom = tester.getSize(find.byType(MaterialApp)).height;
    final contentBottom = tester.getRect(find.byKey(_customContentKey)).bottom;
    final gap = screenBottom - contentBottom;

    // The nav bar plus BottomDrawer's own 24 design gap, and nothing more:
    // the inset must be applied once, not by both the sheet and the drawer.
    expect(gap, closeTo(_navBarHeight + 24, 0.01));
  });
}
