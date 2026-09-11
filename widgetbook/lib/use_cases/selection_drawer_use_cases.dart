import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stands in for the app: holds the selected value the way a preferences
/// provider would, so the check mark moves when you tap a row.
class SelectionHarness<T> extends StatefulWidget {
  const SelectionHarness({
    super.key,
    required this.initial,
    required this.builder,
  });

  final T initial;
  final Widget Function(T selected, ValueChanged<T> onSelect) builder;

  @override
  State<SelectionHarness<T>> createState() => _SelectionHarnessState<T>();
}

class _SelectionHarnessState<T> extends State<SelectionHarness<T>> {
  late T _selected = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(
    _selected,
    (next) => setState(() => _selected = next),
  );
}

/// Renders the drawer body in place — the real thing is inside a modal sheet.
Widget _inSheet(BuildContext context, Widget drawer) {
  final colors = BitcrColors.of(context);

  return Align(
    alignment: Alignment.bottomCenter,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.elevation50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(BitcrRadius.xxl),
        ),
      ),
      child: drawer,
    ),
  );
}

// The option lists below are what an app would pass in — the labels stand in
// for its translations, and the second lines for its generated examples.

const _currencies = [
  SelectionOption(value: 'USD', label: 'US Dollar', secondaryLabel: 'USD'),
  SelectionOption(value: 'EUR', label: 'Euro', secondaryLabel: 'EUR'),
  SelectionOption(value: 'GBP', label: 'British Pound', secondaryLabel: 'GBP'),
  SelectionOption(value: 'CHF', label: 'Swiss Franc', secondaryLabel: 'CHF'),
  SelectionOption(value: 'JPY', label: 'Japanese Yen', secondaryLabel: 'JPY'),
];

const _dateFormats = [
  SelectionOption(
    value: 'automatic',
    label: 'Automatic',
    secondaryLabel: '10/09/2026',
  ),
  SelectionOption(
    value: 'dmy',
    label: '10/09/2026',
    secondaryLabel: 'dd/MM/yyyy',
  ),
  SelectionOption(
    value: 'mdy',
    label: '09/10/2026',
    secondaryLabel: 'MM/dd/yyyy',
  ),
  SelectionOption(
    value: 'ymd',
    label: '2026-09-10',
    secondaryLabel: 'yyyy-MM-dd',
  ),
];

const _decimalFormats = [
  SelectionOption(value: 'comma', label: 'Comma', secondaryLabel: '1.000,00'),
  SelectionOption(value: 'point', label: 'Point', secondaryLabel: '1,000.00'),
  SelectionOption(value: 'space', label: 'Space', secondaryLabel: '1 000,00'),
];

List<SelectionOption<String>> get _languages => const [
  ('en', 'English', '🇬🇧'),
  ('de', 'Deutsch', '🇩🇪'),
  ('es', 'Español', '🇪🇸'),
  ('it', 'Italiano', '🇮🇹'),
  ('tr', 'Türkçe', '🇹🇷'),
  ('pt', 'Português', '🇵🇹'),
].map((entry) {
  final (code, name, flag) = entry;
  return SelectionOption(
    value: code,
    label: name,
    secondaryLabel: code,
    leading: Text(flag, style: const TextStyle(fontSize: 24)),
    searchTerms: [code, name],
  );
}).toList();

/// The currency drawer's shape: one line per option plus its code.
@widgetbook.UseCase(name: 'Currency', type: SelectionDrawer)
Widget selectionDrawerCurrency(BuildContext context) => _inSheet(
  context,
  SelectionHarness<String>(
    initial: 'EUR',
    builder: (selected, onSelect) => SelectionDrawer<String>(
      title: 'Currency',
      closeSemanticLabel: 'Close',
      options: _currencies,
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

/// The language drawer: the same list plus a search field, flags in the
/// leading slot, and the locale code as a search term. Type "de" or "deu" to
/// see it match on both the code and the name.
@widgetbook.UseCase(name: 'Language, with search', type: SelectionDrawer)
Widget selectionDrawerLanguage(BuildContext context) => _inSheet(
  context,
  SelectionHarness<String>(
    initial: 'en',
    builder: (selected, onSelect) => SelectionDrawer<String>(
      title: 'Language',
      closeSemanticLabel: 'Close',
      options: _languages,
      selected: selected,
      onSelect: onSelect,
      search: const SelectionDrawerSearch(
        placeholder: 'Search languages',
        emptyTitle: 'No languages found',
        emptySubtitle: 'Try a different search term.',
        clearLabel: 'Clear search',
      ),
    ),
  ),
);

/// The date-format drawer, where the primary line *is* the generated example
/// and the second line is the pattern.
@widgetbook.UseCase(name: 'Date format', type: SelectionDrawer)
Widget selectionDrawerDateFormat(BuildContext context) => _inSheet(
  context,
  SelectionHarness<String>(
    initial: 'automatic',
    builder: (selected, onSelect) => SelectionDrawer<String>(
      title: 'Date format',
      closeSemanticLabel: 'Close',
      options: _dateFormats,
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

@widgetbook.UseCase(name: 'Decimal separator', type: SelectionDrawer)
Widget selectionDrawerDecimalFormat(BuildContext context) => _inSheet(
  context,
  SelectionHarness<String>(
    initial: 'point',
    builder: (selected, onSelect) => SelectionDrawer<String>(
      title: 'Decimal separator',
      closeSemanticLabel: 'Close',
      options: _decimalFormats,
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

/// Nothing selected — which is what the app passes while the stored
/// preference is still loading. No row should be checked.
@widgetbook.UseCase(name: 'Nothing selected', type: SelectionDrawer)
Widget selectionDrawerNothingSelected(BuildContext context) => _inSheet(
  context,
  SelectionDrawer<String>(
    title: 'Currency',
    closeSemanticLabel: 'Close',
    options: _currencies,
    selected: null,
    onSelect: (_) {},
  ),
);

/// A list long enough to scroll, so the topbar stays put while the options
/// move under it.
@widgetbook.UseCase(name: 'Scrolling list', type: SelectionDrawer)
Widget selectionDrawerScrolling(BuildContext context) => _inSheet(
  context,
  SelectionHarness<int>(
    initial: 3,
    builder: (selected, onSelect) => SelectionDrawer<int>(
      title: 'Currency',
      closeSemanticLabel: 'Close',
      options: [
        for (var i = 0; i < 24; i++)
          SelectionOption(
            value: i,
            label: 'Option ${i + 1}',
            secondaryLabel: 'Secondary line ${i + 1}',
          ),
      ],
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

/// Opens the real modal sheet, so the entrance animation and scrim are the
/// actual ones.
@widgetbook.UseCase(name: 'Open as a modal sheet', type: SelectionDrawer)
Widget selectionDrawerModal(BuildContext context) => Center(
  child: Button(
    onPressed: () => showBottomDrawer<void>(
      context,
      builder: (sheetContext) => SelectionHarness<String>(
        initial: 'EUR',
        builder: (selected, onSelect) => SelectionDrawer<String>(
          title: 'Currency',
          closeSemanticLabel: 'Close',
          options: _currencies,
          selected: selected,
          // What a real call site does: persist, then dismiss. The drawer
          // never pops itself.
          onSelect: (next) {
            onSelect(next);
            Navigator.of(sheetContext).pop();
          },
        ),
      ),
    ),
    child: const Text('Open currency drawer'),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: SelectionDrawer)
Widget selectionDrawerPlayground(BuildContext context) {
  final withSearch = context.knobs.boolean(label: 'Search field');
  final withSecondary = context.knobs.boolean(
    label: 'Second line',
    initialValue: true,
  );
  final withLeading = context.knobs.boolean(label: 'Leading widget');
  final count = context.knobs.int
      .slider(label: 'Options', initialValue: 5, min: 1, max: 24)
      .toInt();

  return _inSheet(
    context,
    SelectionHarness<int>(
      initial: 0,
      builder: (selected, onSelect) => SelectionDrawer<int>(
        title: context.knobs.string(label: 'Title', initialValue: 'Currency'),
        closeSemanticLabel: 'Close',
        options: [
          for (var i = 0; i < count; i++)
            SelectionOption(
              value: i,
              label: 'Option ${i + 1}',
              secondaryLabel: withSecondary ? 'Secondary line ${i + 1}' : null,
              leading: withLeading
                  ? const Icon(LucideIcons.coins300, size: 24)
                  : null,
            ),
        ],
        selected: selected,
        onSelect: onSelect,
        search: withSearch
            ? const SelectionDrawerSearch(
                placeholder: 'Search options',
                emptyTitle: 'No options found',
                emptySubtitle: 'Try a different search term.',
                clearLabel: 'Clear search',
              )
            : null,
      ),
    ),
  );
}

/// The row on its own, outside a drawer — a settings screen uses the same one.
@widgetbook.UseCase(name: 'Selected and unselected', type: SelectionRow)
Widget selectionRowStates(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SelectionRow(
        label: 'Euro',
        secondaryLabel: 'EUR',
        selected: true,
        onTap: () {},
      ),
      SelectionRow(label: 'US Dollar', selected: false, onTap: () {}),
      SelectionRow(
        label: 'Deutsch',
        secondaryLabel: 'de',
        leading: const Text('🇩🇪', style: TextStyle(fontSize: 24)),
        selected: false,
        showDivider: false,
        onTap: () {},
      ),
    ],
  ),
);
