import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// The design system's "Navigation button": a 40px circle holding a 24px icon.
///
/// Set [showChip] to false when the button sits inside a [TopbarActionGroup],
/// which draws the surrounding chip once for the whole row.
class TopbarActionButton extends StatelessWidget {
  const TopbarActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.isLoading = false,
    this.showChip = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool isLoading;
  final bool showChip;

  static const double buttonSize = 40;
  static const double iconSize = 24;
  static const double groupedWidth = 48;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    final Widget content = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(colors.text300),
            ),
          )
        : Icon(icon, size: iconSize, color: colors.text300);

    Widget button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isLoading ? 0.7 : 1,
        child: showChip
            ? Container(
                width: buttonSize,
                height: buttonSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.elevation200,
                  border: Border.all(color: colors.divider50),
                  shape: BoxShape.circle,
                ),
                child: content,
              )
            : SizedBox(width: groupedWidth, child: Center(child: content)),
      ),
    );

    if (semanticLabel != null) {
      button = MergeSemantics(
        child: Semantics(button: true, label: semanticLabel, child: button),
      );
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Two or more [TopbarActionButton]s sharing a single pill, for screens with
/// more than one trailing action.
class TopbarActionGroup extends StatelessWidget {
  const TopbarActionGroup({super.key, required this.children});

  final List<Widget> children;

  static double widthFor(int actionCount) =>
      actionCount * TopbarActionButton.groupedWidth;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Container(
      width: widthFor(children.length),
      height: TopbarActionButton.buttonSize,
      decoration: BoxDecoration(
        color: colors.elevation200,
        border: Border.all(color: colors.divider50),
        borderRadius: BorderRadius.circular(TopbarActionButton.buttonSize / 2),
      ),
      child: Row(
        children: [for (final child in children) Expanded(child: child)],
      ),
    );
  }
}
