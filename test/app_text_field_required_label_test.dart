// A required field's label ends in an asterisk that is drawn in the error
// colour, so a mandatory field stands out; the label text itself stays grey.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpField(WidgetTester tester, {required bool isRequired}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            label: 'Name',
            isRequired: isRequired,
          ),
        ),
      ),
    );

TextSpan _labelSpan(WidgetTester tester) {
  final text = tester.widget<Text>(find.textContaining('Name'));
  return text.textSpan! as TextSpan;
}

void main() {
  testWidgets('a required label draws its asterisk in the error colour', (
    tester,
  ) async {
    await _pumpField(tester, isRequired: true);

    final span = _labelSpan(tester);
    expect(span.toPlainText(), 'Name*');

    final asterisk = span.children!.single as TextSpan;
    expect(asterisk.text, '*');
    expect(asterisk.style?.color, BitcrColors.light.signalError);
  });

  testWidgets('an optional label has no asterisk', (tester) async {
    await _pumpField(tester, isRequired: false);

    expect(_labelSpan(tester).toPlainText(), 'Name');
  });
}
