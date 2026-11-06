import 'package:bitcr_ui/src/overlays/selection_drawer.dart';
import 'package:bitcr_ui/src/patterns/currency_badge.dart';
import 'package:flutter/widgets.dart';

class CurrencyOption {
  const CurrencyOption({required this.code, required this.name, this.label});

  final String code;
  final String name;
  final String? label;
}

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.title,
    required this.currencies,
    required this.selected,
    required this.onSelect,
    this.closeSemanticLabel,
    this.search,
  });

  final String title;
  final List<CurrencyOption> currencies;
  final String? selected;
  final ValueChanged<String> onSelect;
  final String? closeSemanticLabel;
  final SelectionDrawerSearch? search;

  @override
  Widget build(BuildContext context) => SelectionDrawer<String>(
    title: title,
    closeSemanticLabel: closeSemanticLabel,
    selected: selected,
    onSelect: onSelect,
    search: search,
    options: [
      for (final currency in currencies)
        SelectionOption(
          value: currency.code,
          label: currency.name,
          secondaryLabel: currency.label ?? currency.code.toUpperCase(),
          leading: ExcludeSemantics(child: CurrencyBadge(code: currency.code)),
        ),
    ],
  );
}
