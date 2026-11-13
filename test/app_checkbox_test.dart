import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(AppCheckbox),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('checked shows the brand check', (tester) async {
    await pumpInApp(tester, const AppCheckbox(value: true));

    final colors = BitcrColors.light;
    expect(find.byIcon(LucideIcons200.check), findsOneWidget);
    expect(_decoration(tester).color, colors.brand50);
    expect(tester.getSize(find.byType(AppCheckbox)), const Size.square(20));
  });

  testWidgets('unchecked is an empty box', (tester) async {
    await pumpInApp(tester, const AppCheckbox(value: false));

    expect(find.byIcon(LucideIcons200.check), findsNothing);
    expect(_decoration(tester).color, BitcrColors.light.elevation200);
  });
}
