// A required field's label ends in an asterisk that is drawn in the error
// colour while the field is empty, so a missing value stands out; once filled
// it turns grey like the label, as the country selector does.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpField(
  WidgetTester tester, {
  required bool isRequired,
  String text = '',
}) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(
      body: AppTextField(
        controller: TextEditingController(text: text),
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
  testWidgets(
    'an empty required field draws its asterisk in the error colour',
    (tester) async {
      await _pumpField(tester, isRequired: true);

      final span = _labelSpan(tester);
      expect(span.toPlainText(), 'Name*');

      final asterisk = span.children!.single as TextSpan;
      expect(asterisk.text, '*');
      expect(asterisk.style?.color, BitcrColors.light.signalError);
    },
  );

  testWidgets('a filled required field draws its asterisk in grey', (
    tester,
  ) async {
    await _pumpField(tester, isRequired: true, text: 'Ada');

    final asterisk = _labelSpan(tester).children!.single as TextSpan;
    expect(asterisk.style?.color, BitcrColors.light.text200);
  });

  testWidgets('an optional label has no asterisk', (tester) async {
    await _pumpField(tester, isRequired: false);

    expect(_labelSpan(tester).toPlainText(), 'Name');
  });
}
