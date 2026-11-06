import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? _value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: RadioOptionGroup<String>(
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      options: [
        RadioOption(
          value: 'personal',
          label: 'Personal',
          description: 'Use your name',
          leading: (selected) => Icon(
            LucideIcons200.user,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        const RadioOption(value: 'incognito', label: 'Incognito'),
      ],
    ),
  );
}

void main() {
  testWidgets('nothing is selected until a card is tapped', (tester) async {
    await pumpInApp(tester, const _Harness());

    expect(find.byType(RadioCard), findsNWidgets(2));
    expect(find.text('Use your name'), findsOneWidget);
    expect(
      tester.widgetList<AppRadio>(find.byType(AppRadio)).map((r) => r.selected),
      [false, false],
    );
  });

  testWidgets('tapping a card selects only that one', (tester) async {
    await pumpInApp(tester, const _Harness());

    await tester.tap(find.text('Personal'));
    await tester.pump();

    expect(
      tester.widgetList<AppRadio>(find.byType(AppRadio)).map((r) => r.selected),
      [true, false],
    );
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons200.user)).color,
      Colors.white,
    );

    await tester.tap(find.text('Incognito'));
    await tester.pump();

    expect(
      tester.widgetList<AppRadio>(find.byType(AppRadio)).map((r) => r.selected),
      [false, true],
    );
  });

  testWidgets('a card reads as a checked radio', (tester) async {
    await pumpInApp(tester, const _Harness());
    await tester.tap(find.text('Personal'));
    await tester.pump();

    expect(
      tester.getSemantics(find.text('Personal')),
      matchesSemantics(
        label: 'Personal\nUse your name',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
  });
}
