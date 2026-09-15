import 'package:flutter/material.dart';

/// A trailing [icon] that fades in and slides right as it appears, widening
/// the row it sits in so a centred label shifts left to make room.
///
/// Tabs and filter chips share this motion: the label moves left, the icon
/// appears and moves right. Put it in the row unconditionally and drive it
/// with [visible] — an `if (visible)` around a plain [Icon] snaps the label
/// sideways instead, which is the thing this exists to avoid.
///
/// [duration] is the one timing for the gesture. Anything that animates
/// alongside the icon — a chip's border, a row's background — should use it
/// too, so the parts land together.
class AnimatedTrailingIcon extends StatelessWidget {
  const AnimatedTrailingIcon({
    super.key,
    required this.icon,
    required this.visible,
    required this.size,
    required this.color,
    required this.gap,
  });

  final IconData icon;
  final bool visible;
  final double size;
  final Color color;
  final double gap;

  static const Duration duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1 : 0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, progress, child) => ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          widthFactor: progress,
          child: Opacity(opacity: progress, child: child),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: gap),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
