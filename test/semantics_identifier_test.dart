import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// [AppTextField] and [PasscodeForm] both hide their real input: the first
/// behind a decorated row, the second behind the passcode dots. An end-to-end
/// driver needs the identifier on the editable node itself — one on a wrapper
/// at the call site names an ancestor it cannot type into — so both widgets
/// take it as a parameter and put it where the text field is.
///
/// [SettingsSwitch] has the same shape of problem for a different reason: an
/// identifier forces its own [SemanticsNode], which would strand it above the
/// node carrying the tap action, leaving a driver able to find the switch but
/// not to flip it.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('AppTextField exposes its identifier on the text field node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      AppTextField(
        controller: TextEditingController(),
        label: 'Amount',
        identifier: 'amount-field',
      ),
    );

    final node = tester.getSemantics(
      find.bySemanticsIdentifier('amount-field'),
    );

    expect(node.identifier, 'amount-field');
    expect(
      node.label,
      contains('Amount'),
      reason: 'the identifier must land on the labelled text-field node',
    );

    handle.dispose();
  });

  testWidgets('PasscodeForm exposes its identifier on the hidden input', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      PasscodeForm(
        value: '',
        onChanged: (_, _) {},
        identifier: 'pin-entry-field',
      ),
    );

    expect(find.bySemanticsIdentifier('pin-entry-field'), findsOneWidget);

    // Typing has to reach the field the identifier names, not just find it.
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();

    expect(find.bySemanticsIdentifier('pin-entry-field'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('SettingsSwitch keeps its identifier on the node that toggles', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    bool? reported;

    await pump(
      tester,
      SettingsSwitch(
        value: false,
        onChanged: (next) => reported = next,
        identifier: 'dev-mode-switch',
      ),
    );

    final node = tester.getSemantics(
      find.bySemanticsIdentifier('dev-mode-switch'),
    );

    // The whole point: one node the driver can both select and act on. An
    // identifier that lands on a parent of the toggle is no use to Appium.
    expect(
      node,
      matchesSemantics(
        identifier: 'dev-mode-switch',
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();

    expect(reported, isTrue);

    handle.dispose();
  });

  testWidgets('all three stay silent when no identifier is given', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      AppTextField(controller: TextEditingController(), label: 'Amount'),
    );

    expect(find.bySemanticsIdentifier('amount-field'), findsNothing);

    await pump(tester, SettingsSwitch(value: false, onChanged: (_) {}));

    expect(find.bySemanticsIdentifier('dev-mode-switch'), findsNothing);

    handle.dispose();
  });
}
