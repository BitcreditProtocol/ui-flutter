import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _currencies = [
  CurrencyOption(code: 'btc', name: 'Bitcoin'),
  CurrencyOption(code: 'sat', name: 'Bitcoin', label: 'sat'),
  CurrencyOption(code: 'eur', name: 'Euro'),
  CurrencyOption(code: 'xau', name: 'Gold (Troy Ounce)'),
];

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  test('flags come from two-letter country codes', () {
    expect(countryFlag('de'), '🇩🇪');
    expect(countryFlag('DE'), '🇩🇪');
    expect(countryFlag('DEU'), isNull);
    expect(countryFlag(null), isNull);
  });

  test('a currency takes the flag of its country prefix', () {
    expect(currencyFlag('eur'), '🇪🇺');
    expect(currencyFlag('CHF'), '🇨🇭');
    expect(currencyFlag('ang'), '🇳🇱');
    expect(currencyFlag('xau'), isNull);
    expect(currencyFlag('x'), isNull);
  });

  testWidgets('bitcoin units get the orange badge', (tester) async {
    await _pump(
      tester,
      const Column(
        children: [
          CurrencyBadge(code: 'btc'),
          CurrencyBadge(code: 'SAT'),
        ],
      ),
    );

    expect(find.text('B'), findsNWidgets(2));
  });

  testWidgets('a fiat currency shows its flag and a flagless one its code', (
    tester,
  ) async {
    await _pump(
      tester,
      const Column(
        children: [
          CurrencyBadge(code: 'eur'),
          CurrencyBadge(code: 'xau'),
        ],
      ),
    );

    expect(find.text('🇪🇺'), findsOneWidget);
    expect(find.text('XAU'), findsOneWidget);
    expect(
      tester.getSize(find.byType(CurrencyBadge).first),
      const Size.square(CurrencyBadge.size),
    );
  });

  testWidgets('the drawer lists names with codes and reports a pick', (
    tester,
  ) async {
    String? picked;

    await _pump(
      tester,
      CurrencySelector(
        title: 'Display currencies',
        currencies: _currencies,
        selected: 'eur',
        onSelect: (code) => picked = code,
      ),
    );

    expect(find.text('Display currencies'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('sat'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.byIcon(LucideIcons200.check), findsOneWidget);

    await tester.tap(find.text('Gold (Troy Ounce)'));

    expect(picked, 'xau');
  });

  testWidgets('searching matches the code', (tester) async {
    await _pump(
      tester,
      CurrencySelector(
        title: 'Display currencies',
        currencies: _currencies,
        selected: null,
        onSelect: (_) {},
        search: const SelectionDrawerSearch(
          placeholder: 'Search...',
          emptyTitle: 'No currencies found',
          emptySubtitle: 'No currencies match your search.',
          clearLabel: 'Clear search',
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'eur');
    await tester.pump();

    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('Bitcoin'), findsNothing);
  });
}
