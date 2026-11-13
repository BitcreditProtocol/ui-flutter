// AppTextField did not pass autofill hints on, so an email field showed the
// iOS keyboard's word suggestions instead of offering the user's address.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('autofill hints reach the text field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.autofillHints, [AutofillHints.email]);
  });
}
