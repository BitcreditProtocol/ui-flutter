// PasscodeForm was PIN-only: it drew dots and reported one digit per edit.
// eBills' email verification needs the same hidden-field-under-boxes entry
// for a six-digit code, which differs in three ways — the digits are shown,
// the platform may autofill the whole code from the SMS or mail in one edit,
// and the keyboard's done key submits. A one-edit autofill used to report
// only its last digit, so the parent's value ended up one character long.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host extends StatefulWidget {
  const _Host({required this.obscure, this.onSubmitted});

  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  var value = '';

  @override
  Widget build(BuildContext context) => PasscodeForm(
    value: value,
    length: 6,
    obscure: widget.obscure,
    autofillHints: const [AutofillHints.oneTimeCode],
    onSubmitted: widget.onSubmitted,
    onChanged: (index, digit) => setState(() {
      final head = value.substring(0, index.clamp(0, value.length));
      value = digit.isEmpty ? head : head + digit;
    }),
  );
}

Future<_HostState> _pump(
  WidgetTester tester, {
  bool obscure = true,
  ValueChanged<String>? onSubmitted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Center(
          child: _Host(obscure: obscure, onSubmitted: onSubmitted),
        ),
      ),
    ),
  );
  return tester.state<_HostState>(find.byType(_Host));
}

void main() {
  testWidgets('a whole code entered at once reaches the parent', (
    tester,
  ) async {
    final host = await _pump(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(host.value, '123456');
  });

  testWidgets('obscure: false shows the digits', (tester) async {
    await _pump(tester, obscure: false);

    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('the default hides the digits', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();

    expect(find.text('4'), findsNothing);
  });

  testWidgets('done submits', (tester) async {
    String? submitted;
    await _pump(tester, onSubmitted: (v) => submitted = v);

    await tester.enterText(find.byType(TextField), '654321');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, '654321');
  });

  testWidgets('six boxes shrink instead of overflowing a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester);

    expect(tester.takeException(), isNull);
  });
}
