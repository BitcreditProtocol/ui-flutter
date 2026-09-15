import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// A filter sheet's worth of chips, wired up: tapping one runs the border and
/// the check together, which is the thing to look at here. A static pair of
/// selected/unselected chips wouldn't show it.
@widgetbook.UseCase(name: 'Filter section', type: FilterChipButton)
Widget filterChipButtonSection(BuildContext context) => const _FilterDemo();

class _FilterDemo extends StatefulWidget {
  const _FilterDemo();

  @override
  State<_FilterDemo> createState() => _FilterDemoState();
}

class _FilterDemoState extends State<_FilterDemo> {
  final _selected = <String>{'Unpaid'};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in const [
              'Unpaid',
              'Paid',
              'Expired',
              'Rejected',
              'Last 30 days',
            ])
              FilterChipButton(
                label: label,
                selected: _selected.contains(label),
                onTap: () => setState(
                  () => _selected.contains(label)
                      ? _selected.remove(label)
                      : _selected.add(label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The ellipsis case: a chip narrow enough that the label has to give way, and
/// the check still gets its width.
@widgetbook.UseCase(name: 'Overflowing label', type: FilterChipButton)
Widget filterChipButtonOverflowing(BuildContext context) => Center(
  child: SizedBox(
    width: 160,
    child: FilterChipButton(
      label: 'A filter label far too long to fit',
      selected: true,
      onTap: () {},
    ),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: FilterChipButton)
Widget filterChipButtonPlayground(BuildContext context) => Center(
  child: FilterChipButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Unpaid'),
    selected: context.knobs.boolean(label: 'Selected', initialValue: true),
    onTap: () {},
  ),
);
