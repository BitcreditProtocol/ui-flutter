import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, int step) => tester.pumpWidget(
  MaterialApp(
    home: StepTransition(
      step: step,
      child: Scaffold(
        body: Column(children: [Text('step $step'), const Spacer()]),
      ),
    ),
  ),
);

double _left(WidgetTester tester, int step) =>
    tester.getTopLeft(find.text('step $step')).dx;

void main() {
  testWidgets('a later step slides in over the current one', (tester) async {
    await _pump(tester, 0);
    await _pump(tester, 1);
    await tester.pump(const Duration(milliseconds: 60));

    expect(_left(tester, 1), greaterThan(0));
    expect(_left(tester, 0), lessThan(0));
    expect(_left(tester, 0), greaterThan(-20));

    await tester.pumpAndSettle();

    expect(_left(tester, 1), 0);
    expect(find.text('step 0'), findsNothing);
  });

  testWidgets('going back slides the current step off the earlier one', (
    tester,
  ) async {
    await _pump(tester, 1);
    await _pump(tester, 0);
    await tester.pump(const Duration(milliseconds: 60));

    expect(_left(tester, 1), greaterThan(0));
    expect(_left(tester, 0), lessThan(0));
    expect(_left(tester, 0), greaterThan(-20));

    await tester.pumpAndSettle();

    expect(_left(tester, 0), 0);
    expect(find.text('step 1'), findsNothing);
  });

  for (final (name, build) in <(String, Widget Function(int, FocusNode))>[
    (
      'StepTransition',
      (step, focus) => StepTransition(
        step: step,
        child: Scaffold(body: TextField(focusNode: focus)),
      ),
    ),
    (
      'StepFocusReset',
      (step, focus) => StepFocusReset(
        step: step,
        child: Scaffold(body: TextField(focusNode: focus)),
      ),
    ),
  ]) {
    testWidgets('$name closes the keyboard when the step changes', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);

      await tester.pumpWidget(MaterialApp(home: build(0, focus)));
      focus.requestFocus();
      await tester.pump();

      expect(focus.hasFocus, isTrue);

      await tester.pumpWidget(MaterialApp(home: build(1, focus)));
      await tester.pump();

      expect(focus.hasFocus, isFalse);
    });
  }
}
