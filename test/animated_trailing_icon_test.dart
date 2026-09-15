// The whole point of `AnimatedTrailingIcon` over `if (visible) Icon(...)` is
// that the row's width changes gradually, so a centred label slides instead of
// jumping. These check the two ends and the middle of that.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpRow(WidgetTester tester, {required bool visible}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Payments'),
                AnimatedTrailingIcon(
                  icon: LucideIcons.chevronDown,
                  visible: visible,
                  size: 12,
                  gap: 4,
                  color: const Color(0xFF000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );

double iconWidth(WidgetTester tester) =>
    tester.getSize(find.byType(AnimatedTrailingIcon)).width;

void main() {
  testWidgets('hidden, it takes no width at all', (tester) async {
    await pumpRow(tester, visible: false);
    await tester.pumpAndSettle();

    expect(iconWidth(tester), 0);
  });

  testWidgets('visible, it takes the icon plus its gap', (tester) async {
    await pumpRow(tester, visible: true);
    await tester.pumpAndSettle();

    expect(iconWidth(tester), 16); // 12 icon + 4 gap
  });

  testWidgets('and gets there over time, so the label slides', (tester) async {
    await pumpRow(tester, visible: false);
    await tester.pumpAndSettle();
    final labelBefore = tester.getTopLeft(find.text('Payments')).dx;

    await pumpRow(tester, visible: true);
    await tester.pump(AnimatedTrailingIcon.duration ~/ 2);

    final midWidth = iconWidth(tester);
    expect(midWidth, greaterThan(0));
    expect(
      midWidth,
      lessThan(16),
      reason: 'a snap to full width would defeat the component',
    );

    // The row grew to the right of a centred layout, so the label moved left.
    expect(tester.getTopLeft(find.text('Payments')).dx, lessThan(labelBefore));

    await tester.pumpAndSettle();
    expect(iconWidth(tester), 16);
  });
}
