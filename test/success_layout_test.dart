import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

const _illustrationKey = Key('illustration');

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  IconData? secondaryIcon,
}) => pumpInApp(
  tester,
  SuccessLayout(
    title: 'All set',
    description: 'Your identity is ready.',
    illustration: const ColoredBox(
      key: _illustrationKey,
      color: Color(0xFF00AA00),
    ),
    primaryLabel: 'Finish',
    onPrimary: onPrimary ?? () {},
    secondaryLabel: secondaryLabel,
    onSecondary: onSecondary,
    secondaryIcon: secondaryIcon,
  ),
);

void main() {
  testWidgets('shows the copy and a 220 square illustration', (tester) async {
    await _pump(tester);

    expect(find.text('All set'), findsOneWidget);
    expect(find.text('Your identity is ready.'), findsOneWidget);
    expect(tester.getSize(find.byKey(_illustrationKey)), const Size(220, 220));
    expect(find.byType(Button), findsOneWidget);
  });

  testWidgets('the primary button calls back', (tester) async {
    var taps = 0;

    await _pump(tester, onPrimary: () => taps++);
    await tester.tap(find.text('Finish'));

    expect(taps, 1);
  });

  testWidgets('the secondary button shows its icon and calls back', (
    tester,
  ) async {
    var taps = 0;

    await _pump(
      tester,
      secondaryLabel: 'Share',
      secondaryIcon: LucideIcons200.scanQrCode,
      onSecondary: () => taps++,
    );
    await tester.tap(find.text('Share'));

    expect(find.byIcon(LucideIcons200.scanQrCode), findsOneWidget);
    expect(taps, 1);
  });
}
