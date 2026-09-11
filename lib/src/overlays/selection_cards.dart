import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// One card in a [SelectionCards] row.
class SelectionCardOption<T> {
  const SelectionCardOption({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

/// A row of equally sized option cards, one of them selected — the theme
/// picker's layout.
///
/// Use this instead of [SelectionDrawer] when there are few enough options
/// that they fit side by side and each one deserves an icon. Drop it into a
/// [BottomDrawer] as the child.
///
/// As with [SelectionDrawer], selecting doesn't dismiss anything: [onSelect]
/// owns that.
class SelectionCards<T> extends StatelessWidget {
  const SelectionCards({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.spacing = 16,
  });

  final List<SelectionCardOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing,
      children: [
        for (final option in options)
          Expanded(
            child: _SelectionCard(
              icon: option.icon,
              label: option.label,
              selected: option.value == selected,
              onTap: () => onSelect(option.value),
            ),
          ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BitcrRadius.lg),
          border: Border.all(
            color: selected ? colors.text300 : colors.divider75,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: colors.text300),
            Text(
              label,
              textAlign: TextAlign.left,
              style: context.bitcrText
                  .textSmRegular(color: colors.text300)
                  .copyWith(letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}
