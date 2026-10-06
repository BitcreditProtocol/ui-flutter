import 'dart:async';

import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ToastVariant { info, success, warning, error }

const double _toastInset = 20;

/// The filled status badge a [Toast] shows ahead of its message.
class ToastIcon extends StatelessWidget {
  const ToastIcon({super.key, required this.variant});

  final ToastVariant variant;

  static const double size = 20;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    final (name, exported, badge) = switch (variant) {
      ToastVariant.info => ('info', const Color(0xFF1B0F00), colors.text300),
      ToastVariant.success => (
        'success',
        const Color(0xFF006F29),
        colors.signalSuccess,
      ),
      ToastVariant.warning => (
        'warning',
        const Color(0xFFAE5F00),
        colors.signalAlert,
      ),
      ToastVariant.error => (
        'error',
        const Color(0xFFA32B16),
        colors.signalError,
      ),
    };

    return SvgPicture.asset(
      'assets/icons/toast_$name.svg',
      package: 'bitcr_ui',
      width: size,
      height: size,
      colorMapper: _ToastBadgeColors(
        exportedBadge: exported,
        badge: badge,
        mark: colors.elevation200,
      ),
    );
  }
}

@immutable
class _ToastBadgeColors extends ColorMapper {
  const _ToastBadgeColors({
    required this.exportedBadge,
    required this.badge,
    required this.mark,
  });

  static const Color _exportedMark = Color(0xFFF6F2E7);

  final Color exportedBadge;
  final Color badge;
  final Color mark;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _exportedMark) return mark;
    if (color == exportedBadge) return badge;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _ToastBadgeColors &&
      other.exportedBadge == exportedBadge &&
      other.badge == badge &&
      other.mark == mark;

  @override
  int get hashCode => Object.hash(exportedBadge, badge, mark);
}

class ToastAction {
  const ToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// A handle on a toast that is currently on screen.
class ToastController {
  ToastController._(this._dismiss);

  final VoidCallback _dismiss;
  bool _dismissed = false;
  bool get isDismissed => _dismissed;

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _dismiss();
  }
}

/// The toast card itself: a leading variant icon, the message and optional
/// description, then the optional action and close buttons.
///
/// [showToast] is what an app normally calls — this is the widget it inserts,
/// exposed separately so the card can be laid out directly (in a catalog, a
/// golden test, or an app that owns its own presentation).
class Toast extends StatelessWidget {
  const Toast({
    super.key,
    required this.message,
    this.variant = ToastVariant.info,
    this.description,
    this.action,
    this.onClose,
  });

  final String message;
  final ToastVariant variant;
  final String? description;
  final ToastAction? action;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final textStyles = context.bitcrText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevation200,
        borderRadius: BorderRadius.circular(BitcrRadius.md),
        border: Border.all(color: colors.divider75),
        boxShadow: [
          BoxShadow(
            color: colors.divider75.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ToastIcon(variant: variant),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  message,
                  style: textStyles.textSmMedium(color: colors.text300),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: textStyles.textXsRegular(color: colors.text200),
                  ),
              ],
            ),
          ),
          if (action case final action?)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: action.onPressed,
              child: Text(
                action.label,
                style: textStyles.textSmMedium(color: colors.text300),
              ),
            ),
          if (onClose case final onClose?)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Icon(LucideIcons.x, size: 20, color: colors.text200),
            ),
        ],
      ),
    );
  }
}

/// Shows a top-anchored toast via an [Overlay] rather than a bottom-anchored
/// [SnackBar] (which has no top-anchored mode).
///
/// Dismissal follows the design spec:
/// - When [showCloseButton] is true the toast shows a trailing close (×)
///   button and can *only* be dismissed by tapping it (no auto-dismiss).
/// - Otherwise the toast has no close button and auto-dismisses after
///   [duration] (2 seconds by default).
///
/// In both cases it is also swipe-up dismissible, matching the behavior a
/// [SnackBar] would provide for free. An optional [description] renders as a
/// second, lighter line beneath [message], and an optional [action] as a
/// trailing button.
///
/// Returns a [ToastController] for programmatic dismissal, or null when there
/// is no overlay to insert into — which is the case in a widget test that
/// pumps a bare widget with no [Navigator] above it.
ToastController? showToast(
  BuildContext context, {
  required String message,
  ToastVariant variant = ToastVariant.info,
  String? description,
  ToastAction? action,
  bool showCloseButton = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
}) {
  final resolvedOverlay =
      overlay ?? Overlay.maybeOf(context, rootOverlay: true);
  if (resolvedOverlay == null) return null;

  final topPadding = MediaQueryData.fromView(View.of(context)).viewPadding.top;

  late final OverlayEntry entry;
  late final ToastController controller;
  Timer? autoDismissTimer;

  void remove() {
    autoDismissTimer?.cancel();
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: topPadding,
      left: _toastInset,
      right: _toastInset,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.up,
          resizeDuration: null,
          onDismissed: (_) => controller.dismiss(),
          child: Toast(
            message: message,
            variant: variant,
            description: description,
            action: action == null
                ? null
                : ToastAction(
                    label: action.label,
                    onPressed: () {
                      controller.dismiss();
                      action.onPressed();
                    },
                  ),
            onClose: showCloseButton ? () => controller.dismiss() : null,
          ),
        ),
      ),
    ),
  );

  controller = ToastController._(remove);

  resolvedOverlay.insert(entry);
  if (!showCloseButton) {
    autoDismissTimer = Timer(duration, controller.dismiss);
  }

  return controller;
}

/// Shorthand for [showToast] with [ToastVariant.error].
///
/// Deliberately does no logging — what reaches the developer log, and in what
/// shape, is the consuming app's call.
ToastController? showErrorToast(
  BuildContext context,
  String message, {
  String? description,
  ToastAction? action,
  bool showCloseButton = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
}) => showToast(
  context,
  message: message,
  variant: ToastVariant.error,
  description: description,
  action: action,
  showCloseButton: showCloseButton,
  duration: duration,
  overlay: overlay,
);

/// Shorthand for [showToast] with [ToastVariant.info].
ToastController? showInfoToast(
  BuildContext context,
  String message, {
  String? description,
  ToastAction? action,
  bool showCloseButton = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
}) => showToast(
  context,
  message: message,
  variant: ToastVariant.info,
  description: description,
  action: action,
  showCloseButton: showCloseButton,
  duration: duration,
  overlay: overlay,
);

/// Shorthand for [showToast] with [ToastVariant.warning].
ToastController? showWarningToast(
  BuildContext context,
  String message, {
  String? description,
  ToastAction? action,
  bool showCloseButton = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
}) => showToast(
  context,
  message: message,
  variant: ToastVariant.warning,
  description: description,
  action: action,
  showCloseButton: showCloseButton,
  duration: duration,
  overlay: overlay,
);

/// Shorthand for [showToast] with [ToastVariant.success].
ToastController? showSuccessToast(
  BuildContext context,
  String message, {
  String? description,
  ToastAction? action,
  bool showCloseButton = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
}) => showToast(
  context,
  message: message,
  variant: ToastVariant.success,
  description: description,
  action: action,
  showCloseButton: showCloseButton,
  duration: duration,
  overlay: overlay,
);
