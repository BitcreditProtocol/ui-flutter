import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

void main() {
  test('the verified badge asset is bundled', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final data = await rootBundle.load(
      'packages/bitcr_ui/assets/icons/badge_check.svg',
    );

    expect(data.lengthInBytes, greaterThan(0));
  });

  testWidgets('verified reads its label', (tester) async {
    await pumpInApp(
      tester,
      const EmailBadge(
        isVerified: true,
        verifiedLabel: 'Email verified',
        notVerifiedLabel: 'Email not verified',
      ),
    );

    expect(find.bySemanticsLabel('Email verified'), findsOneWidget);
    expect(find.byIcon(LucideIcons200.badgeAlert), findsNothing);
  });

  testWidgets('unverified explains itself on tap', (tester) async {
    await pumpInApp(
      tester,
      const EmailBadge(
        isVerified: false,
        verifiedLabel: 'Email verified',
        notVerifiedLabel: 'Email not verified',
      ),
    );

    await tester.tap(find.byIcon(LucideIcons200.badgeAlert));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Email not verified'), findsOneWidget);
  });
}
