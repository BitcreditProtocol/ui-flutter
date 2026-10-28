import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows that [child], a vertical scroll view, holds more than fits: the
/// content fades out at the top once it is scrolled and at the bottom while
/// there is more below, and a round arrow at the bottom scrolls to the end.
class ScrollHint extends StatefulWidget {
  const ScrollHint({
    super.key,
    required this.child,
    this.bottom = 0,
    this.backgroundColor,
    this.showTopFade = true,
    this.semanticLabel,
  });

  final Widget child;
  final double bottom;
  final Color? backgroundColor;
  final bool showTopFade;
  final String? semanticLabel;

  static const double arrowSize = 32;
  static const double fadeHeight = 80;
  static const double topFadeHeight = 100;
  static const double _arrowBand = arrowSize + 6;

  static const Duration duration = Duration(milliseconds: 150);

  @override
  State<ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<ScrollHint> {
  ScrollPosition? _position;
  var _hasMoreBelow = false;
  var _isScrolled = false;

  bool _onNotification(ScrollNotification notification) {
    _update(notification.depth, notification.metrics, notification.context);

    return false;
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    _update(notification.depth, notification.metrics, notification.context);

    return false;
  }

  void _update(int depth, ScrollMetrics metrics, BuildContext? context) {
    if (depth != 0 || metrics.axis != Axis.vertical) return;

    if (context != null) _position = Scrollable.maybeOf(context)?.position;

    final hasMoreBelow = metrics.extentAfter > 1;
    final isScrolled = metrics.extentBefore > 0;

    if (hasMoreBelow == _hasMoreBelow && isScrolled == _isScrolled) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _hasMoreBelow = hasMoreBelow;
        _isScrolled = isScrolled;
      });
    });
  }

  void _scrollToBottom() {
    final position = _position;

    if (position == null) return;

    position.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final background = widget.backgroundColor ?? colors.elevation50;
    final band = widget.bottom + ScrollHint._arrowBand;

    Widget fade({required bool visible, required Widget child}) =>
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: ScrollHint.duration,
            child: child,
          ),
        );

    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: _onMetrics,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onNotification,
            child: widget.child,
          ),
        ),
        if (widget.showTopFade)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: ScrollHint.topFadeHeight,
            child: fade(
              visible: _isScrolled,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [background, background.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: band + ScrollHint.fadeHeight,
          child: fade(
            visible: _hasMoreBelow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: ScrollHint.fadeHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [background.withValues(alpha: 0), background],
                      ),
                    ),
                  ),
                ),
                Expanded(child: ColoredBox(color: background)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.bottom + 6,
          child: Center(
            child: IgnorePointer(
              ignoring: !_hasMoreBelow,
              child: AnimatedOpacity(
                opacity: _hasMoreBelow ? 1 : 0,
                duration: ScrollHint.duration,
                child: Semantics(
                  button: true,
                  label: widget.semanticLabel,
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      width: ScrollHint.arrowSize,
                      height: ScrollHint.arrowSize,
                      decoration: BoxDecoration(
                        color: colors.elevation200,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.divider50),
                      ),
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 20,
                        color: colors.text300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
