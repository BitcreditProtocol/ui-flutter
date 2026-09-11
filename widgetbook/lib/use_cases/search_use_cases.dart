import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Drives [Search] in its controlled mode — the app owns the query — and shows
/// what each callback reports, which is the part worth reviewing.
class _ControlledSearch extends StatefulWidget {
  const _ControlledSearch({required this.size, required this.debounce});

  final SearchSize size;
  final bool debounce;

  @override
  State<_ControlledSearch> createState() => _ControlledSearchState();
}

class _ControlledSearchState extends State<_ControlledSearch> {
  String _value = '';
  String _lastSearch = '';

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Search(
            value: _value,
            placeholder: 'Search payments',
            size: widget.size,
            enableDebounce: widget.debounce,
            onChange: (next) => setState(() => _value = next),
            onSearch: (next) => setState(() => _lastSearch = next),
          ),
          Text(
            'value: "$_value"',
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
          Text(
            'onSearch: "$_lastSearch"',
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Empty', type: Search)
Widget searchEmpty(BuildContext context) => const Padding(
  padding: EdgeInsets.all(24),
  child: Search(placeholder: 'Search payments'),
);

/// Uncontrolled with text already in it, so the clear button is visible.
@widgetbook.UseCase(name: 'With text', type: Search)
Widget searchWithText(BuildContext context) => const Padding(
  padding: EdgeInsets.all(24),
  child: Search(value: 'alice', placeholder: 'Search payments'),
);

@widgetbook.UseCase(name: 'Sizes', type: Search)
Widget searchSizes(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    spacing: 12,
    children: [
      for (final size in SearchSize.values)
        Search(placeholder: 'Search — ${size.name}', size: size),
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: Search)
Widget searchPlayground(BuildContext context) => _ControlledSearch(
  size: context.knobs.object.dropdown(
    label: 'Size',
    options: SearchSize.values,
    initialOption: SearchSize.md,
    labelBuilder: (s) => s.name,
  ),
  debounce: context.knobs.boolean(label: 'Debounce', initialValue: true),
);
