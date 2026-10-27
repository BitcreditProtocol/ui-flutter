// eBills kept its own text field because its forms are driven by
// Form.validate(): about 43 of its 54 fields carry a validator and the screens
// never pass error text by hand. AppTextField now joins a surrounding Form
// when given a validator, so the same field serves both styles — the wallet
// keeps passing errorText itself, eBills hands over a validator.
//
// The keyboard action defaults to "next" so a form's fields chain through the
// keyboard the way eBills' did, while a multi-line field keeps its newline key.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String? _required(String? value) =>
    (value == null || value.isEmpty) ? 'Required' : null;

Future<GlobalKey<FormState>> _pumpForm(
  WidgetTester tester,
  TextEditingController controller,
) async {
  final formKey = GlobalKey<FormState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Form(
          key: formKey,
          child: AppTextField(
            controller: controller,
            label: 'Name',
            validator: _required,
          ),
        ),
      ),
    ),
  );
  return formKey;
}

void main() {
  testWidgets('Form.validate runs the validator and shows its message', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = await _pumpForm(tester, controller);

    expect(find.text('Required'), findsNothing);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    controller.text = 'Ada';
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('the error appears as soon as the user clears the field', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Ada');
    await _pumpForm(tester, controller);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('errorText wins over the validator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            errorText: 'Taken',
            validator: _required,
            autovalidateMode: AutovalidateMode.always,
          ),
        ),
      ),
    );

    expect(find.text('Taken'), findsOneWidget);
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('keyboard action is next on one line, newline on several', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              AppTextField(controller: TextEditingController()),
              AppTextField(controller: TextEditingController(), maxLines: 4),
              AppTextField(
                controller: TextEditingController(),
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
    );

    final actions = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((f) => f.textInputAction)
        .toList();
    expect(actions, [
      TextInputAction.next,
      TextInputAction.newline,
      TextInputAction.done,
    ]);
  });
}
