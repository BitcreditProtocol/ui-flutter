// `EmptyState.asset` goes through `Image.asset`, which decodes raster formats
// only. Apps whose illustrations are SVG cannot use it at all, and this package
// deliberately carries no SVG decoder — so they hand over a rendered widget
// instead, and it has to land at the same size a bundled asset would.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, EmptyState emptyState) =>
    tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(body: emptyState),
      ),
    );

void main() {
  testWidgets('an app-rendered illustration is laid out at the asset height', (
    tester,
  ) async {
    await _pump(
      tester,
      const EmptyState(
        illustration: Placeholder(key: Key('illustration')),
        title: 'No payments yet',
        subtitle: 'Your payments will be listed here once you make one.',
      ),
    );

    expect(find.byKey(const Key('illustration')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('illustration'))).height,
      EmptyState.imageHeight,
    );
  });

  testWidgets('the illustration replaces the asset rather than joining it', (
    tester,
  ) async {
    await _pump(
      tester,
      const EmptyState(
        illustration: Placeholder(),
        title: 'No payments yet',
        subtitle: 'Your payments will be listed here once you make one.',
      ),
    );

    expect(find.byType(Image), findsNothing);
  });

  test('exactly one of asset and illustration is required', () {
    expect(
      () => EmptyState(
        asset: 'assets/images/no_payments.png',
        illustration: const Placeholder(),
        title: 'No payments yet',
        subtitle: 'Your payments will be listed here.',
      ),
      throwsAssertionError,
    );

    expect(
      () => EmptyState(
        title: 'No payments yet',
        subtitle: 'Your payments will be listed here.',
      ),
      throwsAssertionError,
    );
  });
}
