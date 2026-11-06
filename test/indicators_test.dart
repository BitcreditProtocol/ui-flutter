import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

List<Color?> _colors(WidgetTester tester, Type type) => [
  for (final container in tester.widgetList<Container>(
    find.descendant(of: find.byType(type), matching: find.byType(Container)),
  ))
    (container.decoration as BoxDecoration?)?.color,
];

void main() {
  testWidgets('the step bar fills up to the current step', (tester) async {
    await pumpInApp(
      tester,
      const StepIndicator(steps: 4, current: 1, semanticLabel: 'Step 2 of 4'),
    );

    final colors = BitcrColors.light;
    expect(_colors(tester, StepIndicator), [
      colors.text300,
      colors.text300,
      colors.elevation350,
      colors.elevation350,
    ]);
    expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
  });

  testWidgets('dots highlight the current page and report taps', (
    tester,
  ) async {
    final taps = <int>[];

    await pumpInApp(
      tester,
      DotIndicator(
        steps: 3,
        current: 0,
        onTap: taps.add,
        semanticLabelBuilder: (index) => 'Go to page ${index + 1}',
      ),
    );

    await tester.tap(find.bySemanticsLabel('Go to page 3'));
    expect(taps, [2]);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Go to page 1')),
      matchesSemantics(
        label: 'Go to page 1',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });
}
