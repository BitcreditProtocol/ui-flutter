import 'package:bitcr_ui/src/core/animated_trailing_icon.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A filter option as a chip: the label, and a check that slides out from
/// behind it when the option is selected.
///
/// Selecting doesn't dismiss anything and the chip holds no state of its own —
/// [selected] and [onTap] belong to the filter sheet around it, the same way
/// [SelectionDrawer] and [SelectionCards] work.
///
/// The border and the check animate on the one [AnimatedTrailingIcon.duration]
/// so the chip reads as a single change rather than two.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final radius = BorderRadius.circular(BitcrRadius.md);

    return Semantics(
      selected: selected,
      child: AnimatedContainer(
        duration: AnimatedTrailingIcon.duration,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: selected ? colors.text300 : colors.divider75,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.bitcrText.textXsMedium(
                        color: colors.text300,
                      ),
                    ),
                  ),
                  AnimatedTrailingIcon(
                    icon: LucideIcons.check,
                    visible: selected,
                    size: 16,
                    gap: 8,
                    color: colors.text300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
