import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// [SettingsSwitch] paints its own track and knob rather than wrapping a
/// Material [Switch], so nothing hands it switch semantics for free. Without
/// them a screen reader announces an unlabelled tappable blob — no on/off
/// state, no toggle action — and an end-to-end driver looking for a native
/// switch (android.widget.Switch, XCUIElementTypeSwitch) never finds the row
/// at all. Both platforms key off the toggled flag, so these tests pin the
/// flag, the tap action and the disabled state.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('carries toggled state and a tap action', (tester) async {
    final handle = tester.ensureSemantics();

    await pump(tester, SettingsSwitch(value: false, onChanged: (_) {}));

    expect(
      tester.getSemantics(find.byType(SettingsSwitch)),
      matchesSemantics(
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('reports the on state when the value is true', (tester) async {
    final handle = tester.ensureSemantics();

    await pump(tester, SettingsSwitch(value: true, onChanged: (_) {}));

    expect(
      tester.getSemantics(find.byType(SettingsSwitch)),
      matchesSemantics(
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('the semantic tap toggles, not just a raw pointer tap', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    bool? reported;

    await pump(
      tester,
      SettingsSwitch(value: false, onChanged: (next) => reported = next),
    );

    // Dispatch the semantics action rather than a pointer tap: a pointer tap
    // reaches the GestureDetector even with no semantics at all, so only this
    // proves the action an assistive tech or Appium driver invokes is wired
    // through to onChanged.
    final node = tester.getSemantics(find.byType(SettingsSwitch));
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();

    expect(reported, isTrue);

    handle.dispose();
  });

  testWidgets('a null onChanged is announced as disabled', (tester) async {
    final handle = tester.ensureSemantics();

    await pump(tester, const SettingsSwitch(value: true));

    expect(
      tester.getSemantics(find.byType(SettingsSwitch)),
      matchesSemantics(
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );

    handle.dispose();
  });
}
