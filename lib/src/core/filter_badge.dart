import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// An applied filter, shown under a list as a removable badge: its [label]
/// and a cross. Tapping anywhere on it calls [onRemove].
class FilterBadge extends StatelessWidget {
  const FilterBadge({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onRemove,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          decoration: BoxDecoration(
            color: colors.elevation50,
            borderRadius: BorderRadius.circular(BitcrRadius.md),
            border: Border.all(color: colors.divider75),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                label,
                style: context.bitcrText.textXsMedium(color: colors.text300),
              ),
              Icon(LucideIcons.x, size: 14, color: colors.text200),
            ],
          ),
        ),
      ),
    );
  }
}
