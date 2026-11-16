import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'selection_drawer_use_cases.dart';

const _currencies = [
  CurrencyOption(code: 'btc', name: 'Bitcoin'),
  CurrencyOption(code: 'sat', name: 'Bitcoin', label: 'sat'),
  CurrencyOption(code: 'usd', name: 'US Dollar'),
  CurrencyOption(code: 'eur', name: 'Euro'),
  CurrencyOption(code: 'gbp', name: 'British Pound'),
  CurrencyOption(code: 'chf', name: 'Swiss Franc'),
  CurrencyOption(code: 'jpy', name: 'Japanese Yen'),
  CurrencyOption(code: 'ang', name: 'Netherlands Antillean Gulden'),
  CurrencyOption(code: 'xau', name: 'Gold (Troy Ounce)'),
  CurrencyOption(code: 'xof', name: 'West African CFA Franc'),
];

const _search = SelectionDrawerSearch(
  placeholder: 'Search...',
  emptyTitle: 'No currencies found',
  emptySubtitle: 'No currencies match your search.',
  clearLabel: 'Clear search',
);

Widget _inSheet(BuildContext context, Widget drawer) => Align(
  alignment: Alignment.bottomCenter,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: BitcrColors.of(context).elevation50,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(BitcrRadius.xxl),
      ),
    ),
    child: drawer,
  ),
);

@widgetbook.UseCase(name: 'Default', type: CurrencySelector)
Widget currencySelectorDefault(BuildContext context) => _inSheet(
  context,
  SelectionHarness<String>(
    initial: 'eur',
    builder: (selected, onSelect) => CurrencySelector(
      title: 'Display currencies',
      closeSemanticLabel: 'Close',
      currencies: _currencies,
      selected: selected,
      onSelect: onSelect,
      search: _search,
    ),
  ),
);

@widgetbook.UseCase(name: 'Open as a modal sheet', type: CurrencySelector)
Widget currencySelectorModal(BuildContext context) => Center(
  child: SelectionHarness<String>(
    initial: 'btc',
    builder: (selected, onSelect) => Button(
      onPressed: () => showBottomDrawer<void>(
        context,
        opensKeyboard: true,
        builder: (sheet) => CurrencySelector(
          title: 'Display currencies',
          closeSemanticLabel: 'Close',
          currencies: _currencies,
          selected: selected,
          search: _search,
          onSelect: (code) {
            onSelect(code);
            Navigator.of(sheet).pop();
          },
        ),
      ),
      child: Text('Currency: ${selected.toUpperCase()}'),
    ),
  ),
);

@widgetbook.UseCase(name: 'Badges', type: CurrencyBadge)
Widget currencyBadges(BuildContext context) => Center(
  child: Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final currency in _currencies) CurrencyBadge(code: currency.code),
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: CurrencyBadge)
Widget currencyBadgePlayground(BuildContext context) => Center(
  child: CurrencyBadge(
    code: context.knobs.string(label: 'Code', initialValue: 'eur'),
  ),
);
