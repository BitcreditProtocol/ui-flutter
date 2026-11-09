import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

void main() {
  testWidgets('the info button shows its message on tap', (tester) async {
    await pumpInApp(tester, const FieldInfoButton(message: 'Max 10 MB'));

    expect(find.bySemanticsLabel('Max 10 MB'), findsOneWidget);
    expect(find.text('Max 10 MB'), findsNothing);

    await tester.tap(find.byIcon(LucideIcons300.info));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Max 10 MB'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Max 10 MB'), findsNothing);
  });

  testWidgets('the outline style swaps the border for divider300', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      Builder(
        builder: (context) => Button(
          variant: ButtonVariant.outline,
          style: outlineButtonStyle(context),
          onPressed: () {},
          child: const Text('Cancel'),
        ),
      ),
    );

    final shape =
        tester
                .widget<ElevatedButton>(find.byType(ElevatedButton))
                .style!
                .shape!
                .resolve({})
            as RoundedRectangleBorder;

    expect(shape.side.color, BitcrColors.light.divider300);
    expect(shape.borderRadius, BorderRadius.circular(BitcrRadius.md));
  });

  testWidgets('the small style is 44 tall', (tester) async {
    await pumpInApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(20),
        child: FilledButton(
          style: smallButtonStyle,
          onPressed: () {},
          child: const Text('Back'),
        ),
      ),
    );

    final surface = find.descendant(
      of: find.byType(FilledButton),
      matching: find.byType(Material),
    );

    expect(tester.getSize(surface).height, 44);
  });

  testWidgets('outlined buttons hug their label inside the wrapper', (
    tester,
  ) async {
    final theme = BitcrTheme.light.copyWith(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      ),
    );

    Widget button() =>
        OutlinedButton(onPressed: () {}, child: const Text('Add'));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              button(),
              HuggingOutlinedButtons(child: Center(child: button())),
            ],
          ),
        ),
      ),
    );

    final sizes = tester
        .widgetList(find.byType(OutlinedButton))
        .map((w) => tester.getSize(find.byWidget(w)))
        .toList();

    expect(sizes.first.width, 800);
    expect(sizes.last.width, lessThan(200));
    expect(sizes.last.height, lessThan(52));
  });
}
