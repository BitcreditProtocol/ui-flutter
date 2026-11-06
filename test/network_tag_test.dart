import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

Color _dot(WidgetTester tester) =>
    tester.widget<PulsingDot>(find.byType(PulsingDot)).color;

void main() {
  testWidgets('online shows a green dot and no chevron', (tester) async {
    await pumpInApp(tester, const NetworkTag(label: 'Mainnet'));

    expect(find.text('Mainnet'), findsOneWidget);
    expect(_dot(tester), BitcrColors.light.signalSuccess);
    expect(find.byIcon(LucideIcons300.chevronDown), findsNothing);
  });

  testWidgets('offline turns the dot red', (tester) async {
    await pumpInApp(
      tester,
      const NetworkTag(label: 'Mainnet. Offline', isOffline: true),
    );

    expect(_dot(tester), BitcrColors.light.signalError);
  });

  testWidgets('a tappable tag shows a chevron and reports taps', (
    tester,
  ) async {
    var taps = 0;

    await pumpInApp(
      tester,
      NetworkTag(
        label: 'Testnet 4',
        onTap: () => taps++,
        semanticHint: 'Switch network',
      ),
    );

    expect(find.byIcon(LucideIcons300.chevronDown), findsOneWidget);

    await tester.tap(find.text('Testnet 4'));
    expect(taps, 1);
  });
}
