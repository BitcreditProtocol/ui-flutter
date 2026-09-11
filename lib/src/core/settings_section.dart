import 'package:bitcr_ui/src/core/backup_dot.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const double _kContentPadding = 12;
const double _kIconBoxSize = 32;
const double _kIconGap = 12;
const double _kSectionGap = 24;

/// A settings-menu row: a bordered icon tile, a label, an optional current
/// value on the right, and a chevron.
///
/// Standalone it draws its own card. Inside a [SettingsSectionCard] pass
/// `bordered: false` — the card draws the surface for the whole group and
/// [SettingsSectionDivider] separates the rows.
///
/// [value] is the muted right-aligned text this row's current setting reads as
/// — a locale code, a currency, a formatted example. Use [trailing] instead
/// when the slot needs a real widget, like a spinner while that setting is
/// still loading.
class SettingsSectionItem extends StatelessWidget {
  const SettingsSectionItem({
    super.key,
    this.icon,
    this.leading,
    required this.label,
    this.value,
    this.enabled = true,
    this.onTap,
    this.trailing,
    this.showDot = false,
    this.showChevron = true,
    this.color,
    this.bordered = true,
  }) : assert(
         icon != null || leading != null,
         'Provide either icon or leading',
       ),
       assert(
         value == null || trailing == null,
         'value and trailing share the same slot — pass one or the other',
       );

  final IconData? icon;
  final Widget? leading;
  final String label;
  final String? value;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDot;
  final bool showChevron;
  final Color? color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final baseColor = enabled ? colors.text300 : colors.text200;
    final contentColor = color ?? baseColor;

    final leadingSlot = leading != null
        ? SizedBox(
            width: _kIconBoxSize,
            height: _kIconBoxSize,
            child: Center(child: leading),
          )
        : Container(
            width: _kIconBoxSize,
            height: _kIconBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.elevation50,
              border: Border.all(color: colors.divider75),
              borderRadius: BorderRadius.circular(BitcrRadius.md),
            ),
            child: Icon(icon, size: 20, color: contentColor),
          );

    final valueSlot = value != null
        ? Text(
            value!,
            style: context.bitcrText.textSmRegular(color: colors.text200),
          )
        : trailing;

    final content = Padding(
      padding: const EdgeInsets.all(_kContentPadding),
      child: Row(
        children: [
          leadingSlot,
          const SizedBox(width: _kIconGap),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: context.bitcrText.textMdMedium(
                      color: contentColor,
                    ),
                  ),
                ),
                if (showDot) ...[const SizedBox(width: 8), const BackupDot()],
              ],
            ),
          ),
          if (valueSlot != null) ...[
            valueSlot,
            if (showChevron) const SizedBox(width: 8),
          ],
          if (showChevron)
            Icon(LucideIcons.chevronRight300, size: 24, color: baseColor),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: bordered
          ? Container(
              decoration: BoxDecoration(
                color: colors.elevation200,
                borderRadius: BorderRadius.circular(BitcrRadius.md),
              ),
              child: content,
            )
          : content,
    );
  }
}

/// The hairline between two [SettingsSectionItem]s in a card, inset to start
/// under the label rather than under the icon tile.
class SettingsSectionDivider extends StatelessWidget {
  const SettingsSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _kContentPadding + _kIconBoxSize + _kIconGap,
        right: _kContentPadding,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: BitcrColors.of(context).divider75,
      ),
    );
  }
}

/// Rounded elevated container used to group [SettingsSectionItem]s (passed
/// with `bordered: false`) with [SettingsSectionDivider]s between them.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BitcrColors.of(context).elevation200,
        borderRadius: BorderRadius.circular(BitcrRadius.md),
      ),
      child: Column(children: children),
    );
  }
}

/// Vertical list of [SettingsSectionItem]s or [SettingsSectionCard]s, each
/// entry spaced apart as its own block.
class SettingsSectionList extends StatelessWidget {
  const SettingsSectionList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(spacing: _kSectionGap, children: children);
  }
}
