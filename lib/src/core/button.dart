import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Which of the four button roles this is. [disabled] is reachable both as a
/// variant and via the [Button.disabled] flag, so a call site can either pick
/// the look or drive it from state.
enum ButtonVariant { primary, secondary, outline, disabled }

enum ButtonSize { large, medium, small }

/// The standard action button: a flat [ElevatedButton] over the color tokens,
/// with a 1px border on every variant so the outline one lines up with the
/// filled ones.
///
/// [style] is merged *over* the computed style, so a call site can override a
/// single property without restating the variant.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.buttonSize = ButtonSize.medium,
    this.disabled = false,
    this.style,
    this.onLongPress,
    this.foregroundColor,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize buttonSize;
  final bool disabled;
  final ButtonStyle? style;
  final VoidCallback? onLongPress;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final effectiveVariant = disabled ? ButtonVariant.disabled : variant;

    final Color bg = switch (effectiveVariant) {
      ButtonVariant.disabled => colors.baseInactive,
      ButtonVariant.primary => colors.baseActive,
      ButtonVariant.secondary => colors.elevation200,
      ButtonVariant.outline => Colors.transparent,
    };
    final Color fg =
        foregroundColor ??
        switch (effectiveVariant) {
          ButtonVariant.disabled => colors.textInactive,
          ButtonVariant.primary => colors.textActive,
          ButtonVariant.secondary => colors.text100,
          ButtonVariant.outline => colors.text300,
        };
    final Color border =
        foregroundColor ??
        switch (effectiveVariant) {
          ButtonVariant.disabled => colors.baseInactive,
          ButtonVariant.primary => colors.baseActive,
          ButtonVariant.secondary => colors.elevation200,
          ButtonVariant.outline => colors.text300,
        };
    final EdgeInsets padding = switch (buttonSize) {
      ButtonSize.large => const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      ButtonSize.medium => const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      ButtonSize.small => const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 20,
      ),
    };

    final defaultStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all(bg),
      foregroundColor: WidgetStateProperty.all(fg),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BitcrRadius.md),
          side: BorderSide(color: border),
        ),
      ),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      textStyle: WidgetStateProperty.all(
        context.bitcrText.textSmMedium(color: fg).copyWith(letterSpacing: 0),
      ),
    );

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      onLongPress: onLongPress,
      style: style?.merge(defaultStyle) ?? defaultStyle,
      child: child,
    );
  }
}
