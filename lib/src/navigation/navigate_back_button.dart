import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A circular 40×40 back button, sized the same on every screen so it always
/// sits in the same spot.
///
/// It keeps its 40×40 even inside a slot that allots it less, by overflowing
/// that slot rather than shrinking into it.
///
/// Navigation is the caller's: this only reports [onPressed], so the same
/// button works with any router.
class NavigateBackButton extends StatelessWidget {
  const NavigateBackButton({
    super.key,
    this.onPressed,
    this.isDark = false,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  final VoidCallback? onPressed;
  final bool isDark;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    final resolvedBackgroundColor =
        backgroundColor ?? (isDark ? colors.text300 : colors.elevation200);
    final resolvedBorderColor =
        borderColor ?? (isDark ? colors.text300 : colors.divider50);
    final resolvedIconColor =
        iconColor ?? (isDark ? colors.elevation200 : colors.text300);

    return OverflowBox(
      minWidth: _size,
      maxWidth: _size,
      minHeight: _size,
      maxHeight: _size,
      fit: OverflowBoxFit.deferToChild,
      child: MergeSemantics(
        child: Semantics(
          label: MaterialLocalizations.of(context).backButtonTooltip,
          button: true,
          child: SizedBox(
            width: _size,
            height: _size,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: resolvedBackgroundColor,
                foregroundColor: resolvedBackgroundColor,
                overlayColor: Colors.transparent,
                shape: CircleBorder(
                  side: BorderSide(color: resolvedBorderColor),
                ),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Icon(
                LucideIcons.chevronLeft300,
                size: 24,
                color: resolvedIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
