import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum RefreshButtonSize { xs, sm, md, lg }

/// A flat "refresh" control: an optional label next to an icon that spins
/// while [isLoading].
class RefreshButton extends StatefulWidget {
  const RefreshButton({
    super.key,
    this.onPressed,
    this.label,
    this.tooltip,
    this.isLoading = false,
    this.disabled = false,
    this.size = RefreshButtonSize.md,
    this.icon = LucideIcons.refreshCw300,
    this.iconSize,
    this.color,
    this.labelStyle,
    this.semanticLabel,
    this.spinDuration = const Duration(seconds: 1),
  });

  final VoidCallback? onPressed;
  final String? label;
  final String? tooltip;
  final bool isLoading;
  final bool disabled;
  final RefreshButtonSize size;
  final IconData icon;
  final double? iconSize;
  final Color? color;
  final TextStyle? labelStyle;
  final String? semanticLabel;
  final Duration spinDuration;

  static double iconSizeOf(RefreshButtonSize size) => switch (size) {
    RefreshButtonSize.xs => 16,
    RefreshButtonSize.sm => 20,
    RefreshButtonSize.md => 24,
    RefreshButtonSize.lg => 28,
  };

  static double spacingOf(RefreshButtonSize size) =>
      size == RefreshButtonSize.lg ? 8 : 4;

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: widget.spinDuration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.spinDuration != oldWidget.spinDuration) {
      _spin.duration = widget.spinDuration;
    }
    if (widget.isLoading == oldWidget.isLoading) return;

    if (widget.isLoading) {
      _spin.repeat();
    } else {
      _spin.animateTo(1).whenComplete(() {
        if (mounted && !widget.isLoading) _spin.value = 0;
      });
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final color = widget.disabled
        ? (widget.color ?? colors.brand200).withValues(alpha: 0.4)
        : widget.color ?? colors.brand200;

    final textStyles = context.bitcrText;
    final baseLabelStyle = switch (widget.size) {
      RefreshButtonSize.lg => textStyles.textSmRegular(color: color),
      _ => textStyles.textXsRegular(color: color),
    };

    final interactive = !widget.isLoading && !widget.disabled;

    Widget button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: interactive ? widget.onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: RefreshButton.spacingOf(widget.size),
        children: [
          if (widget.label case final label?)
            Text(label, style: baseLabelStyle.merge(widget.labelStyle)),
          RotationTransition(
            turns: _spin,
            child: Icon(
              widget.icon,
              size: widget.iconSize ?? RefreshButton.iconSizeOf(widget.size),
              color: color,
            ),
          ),
        ],
      ),
    );

    final semanticLabel =
        widget.semanticLabel ?? widget.label ?? widget.tooltip;
    if (semanticLabel != null) {
      button = MergeSemantics(
        child: Semantics(
          button: true,
          enabled: interactive,
          label: semanticLabel,
          child: button,
        ),
      );
    }

    if (widget.tooltip case final tooltip?) {
      button = Tooltip(message: tooltip, child: button);
    }

    return button;
  }
}
