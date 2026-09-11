import 'dart:math' as math;

import 'package:bitcr_ui/src/navigation/topbar.dart';
import 'package:bitcr_ui/src/navigation/topbar_action_button.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The platform IME animation curve and durations.
///
/// Exported because anything animating alongside the keyboard has to match
/// these to look like one motion — see [imeSheetAnimationStyle].
const Curve imeCurve = Cubic(0.2, 0, 0, 1);
const Duration imeShowDuration = Duration(milliseconds: 285);
const Duration imeHideDuration = Duration(milliseconds: 340);

/// Entrance/exit matching the platform IME animation, so a drawer that opens
/// the keyboard with it rises as one motion instead of two.
///
/// A keyboard drawer's top edge travels the sheet's own height *plus* the
/// keyboard height (the sheet grows as [MediaQuery.viewInsetsOf] comes in).
/// With the material defaults (250ms/200ms on [Easing.legacyDecelerate]) those
/// two contributions run on different curves over different durations, which
/// reads as the sheet and the keyboard racing each other. Driving the sheet on
/// the IME curve and duration makes the sum a single smooth ease.
const AnimationStyle imeSheetAnimationStyle = AnimationStyle(
  duration: imeShowDuration,
  curve: imeCurve,
  reverseDuration: imeHideDuration,
  reverseCurve: imeCurve,
);

/// The contents of a bottom sheet: a [Topbar] with a close button and the
/// [title], then [child].
///
/// Pass this to [showBottomDrawer], which supplies the sheet itself. Bottom
/// padding clears the keyboard when it's up and the home indicator when it
/// isn't.
class BottomDrawer extends StatelessWidget {
  const BottomDrawer({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.closeSemanticLabel,
    this.trail,
    this.contentSpacing = 32,
  });

  /// The app's translated heading.
  final String title;

  final Widget child;

  /// Defaults to popping the current route.
  final VoidCallback? onClose;

  /// Accessibility label for the close button — the app's copy.
  final String? closeSemanticLabel;

  /// An optional action in the topbar's trailing slot.
  final Widget? trail;

  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    // Clear the keyboard when it's up, the home indicator when it isn't.
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding = math.max(bottomInset, safeBottom) + 24;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Topbar(
            lead: TopbarActionButton(
              icon: LucideIcons.x300,
              semanticLabel: closeSemanticLabel,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
            ),
            middle: Text(
              title,
              textAlign: TextAlign.center,
              style: context.bitcrText
                  .textMdMedium(color: colors.text300)
                  .copyWith(letterSpacing: 0),
            ),
            trail: trail,
          ),
          SizedBox(height: contentSpacing),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Opens a [BottomDrawer] as a modal bottom sheet, styled to the design.
///
/// Set [opensKeyboard] for drawers that auto-focus a field on open (see
/// [imeSheetAnimationStyle]). Drawers without a keyboard keep the snappier
/// material defaults.
Future<T?> showBottomDrawer<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool opensKeyboard = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: BitcrColors.of(context).elevation50,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    // Push onto the root navigator so the sheet and its scrim cover the shell's
    // bottom navigation bar instead of being clipped above it.
    useRootNavigator: true,
    sheetAnimationStyle: opensKeyboard ? imeSheetAnimationStyle : null,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BitcrRadius.xxl),
      ),
    ),
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: builder,
  );
}
