import 'package:bitcr_ui/src/core/animated_trailing_icon.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One tab of a [TabSwitch].
///
/// [showChevron] marks a tab that opens something — a filter sheet, a menu —
/// when tapped again while selected; it only shows on the selected tab.
/// [semanticsIdentifier] is for UI tests to find the tab by.
class TabSwitchItem {
  const TabSwitchItem({
    required this.label,
    this.showChevron = false,
    this.semanticsIdentifier,
  });

  final String label;
  final bool showChevron;
  final String? semanticsIdentifier;
}

/// A segmented control: equal-width tabs on a sunken track, the selected one
/// raised on a pill that slides between them.
///
/// [onTap] fires for every tab, the selected one included, so the caller
/// decides what tapping the current tab does.
class TabSwitch extends StatelessWidget {
  const TabSwitch({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  }) : assert(items.length > 1, 'A TabSwitch needs at least two tabs');

  final List<TabSwitchItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const double height = 44;
  static const Duration duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final radius = BorderRadius.circular(BitcrRadius.md);
    final border = Border.all(color: colors.divider50);
    final last = items.length - 1;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.elevation200,
        borderRadius: radius,
      ),
      foregroundDecoration: BoxDecoration(border: border, borderRadius: radius),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: duration,
            curve: Curves.easeInOut,
            alignment: Alignment(-1 + 2 * selectedIndex / last, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.elevation50,
                  borderRadius: radius,
                  border: border,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: _Tab(
                    item: item,
                    selected: index == selectedIndex,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final TabSwitchItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final color = selected ? colors.text300 : colors.text200;

    return Semantics(
      identifier: item.semanticsIdentifier,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: TabSwitch.duration,
                  style: context.bitcrText.textSmMedium(color: color),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AnimatedTrailingIcon(
                icon: LucideIcons.chevronDown,
                visible: selected && item.showChevron,
                size: 12,
                gap: 4,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
