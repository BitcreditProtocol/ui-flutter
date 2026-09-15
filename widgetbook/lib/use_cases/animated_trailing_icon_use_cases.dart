import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// The motion only reads when it runs, so this one is a toggle rather than a
/// static pair: tap the tab and watch the label slide left as the chevron
/// comes out from behind it.
@widgetbook.UseCase(name: 'Tab chevron', type: AnimatedTrailingIcon)
Widget animatedTrailingIconTab(BuildContext context) => const _TabChevronDemo();

class _TabChevronDemo extends StatefulWidget {
  const _TabChevronDemo();

  @override
  State<_TabChevronDemo> createState() => _TabChevronDemoState();
}

class _TabChevronDemoState extends State<_TabChevronDemo> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, label) in ['Payments', 'Balances'].indexed)
            GestureDetector(
              onTap: () => setState(() => _selected = index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Builder(
                  builder: (context) {
                    final color = _selected == index
                        ? colors.text300
                        : colors.text100;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: context.bitcrText.textMdMedium(color: color),
                        ),
                        AnimatedTrailingIcon(
                          icon: LucideIcons.chevronDown,
                          visible: _selected == index,
                          size: 12,
                          gap: 4,
                          color: color,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The component on its own, with the knobs that matter: flip `Visible` and
/// the row either side of it moves.
@widgetbook.UseCase(name: 'Playground', type: AnimatedTrailingIcon)
Widget animatedTrailingIconPlayground(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Center(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: colors.divider75)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Label',
            style: context.bitcrText.textMdMedium(color: colors.text300),
          ),
          AnimatedTrailingIcon(
            icon: LucideIcons.check,
            visible: context.knobs.boolean(
              label: 'Visible',
              initialValue: true,
            ),
            size: context.knobs.double
                .slider(label: 'Icon size', initialValue: 16, min: 8, max: 32)
                .roundToDouble(),
            gap: context.knobs.double
                .slider(label: 'Gap', initialValue: 8, max: 24)
                .roundToDouble(),
            color: colors.text300,
          ),
        ],
      ),
    ),
  );
}
