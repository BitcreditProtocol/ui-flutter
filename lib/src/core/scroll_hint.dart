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
  BuildContext? _scrollable;
  var _hasMoreBelow = false;
  var _isScrolled = false;
  var _viewport = EdgeInsets.zero;

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

    final scrollable = context == null ? null : Scrollable.maybeOf(context);

    if (scrollable != null) {
      _position = scrollable.position;
      _scrollable = scrollable.context;
    }

    final hasMoreBelow = metrics.extentAfter > 1;
    final isScrolled = metrics.extentBefore > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewport = _measureViewport() ?? _viewport;

      if (hasMoreBelow == _hasMoreBelow &&
          isScrolled == _isScrolled &&
          viewport == _viewport) {
        return;
      }

      setState(() {
        _hasMoreBelow = hasMoreBelow;
        _isScrolled = isScrolled;
        _viewport = viewport;
      });
    });
  }

  EdgeInsets? _measureViewport() {
    final scrollableContext = _scrollable;

    if (scrollableContext == null || !scrollableContext.mounted) return null;

    final hint = context.findRenderObject();
    final scrollable = scrollableContext.findRenderObject();

    if (hint is! RenderBox ||
        scrollable is! RenderBox ||
        !hint.hasSize ||
        !scrollable.hasSize ||
        !scrollable.attached) {
      return null;
    }

    final rect =
        scrollable.localToGlobal(Offset.zero, ancestor: hint) & scrollable.size;

    double edge(double value) => value < 0.5 ? 0 : value.roundToDouble();

    return EdgeInsets.fromLTRB(
      edge(rect.left),
      edge(rect.top),
      edge(hint.size.width - rect.right),
      edge(hint.size.height - rect.bottom),
    );
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
    final viewport = _viewport;
    final inset = viewport.bottom > 0 ? 0.0 : widget.bottom;
    final band = inset + ScrollHint._arrowBand;

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
            left: viewport.left,
            right: viewport.right,
            top: viewport.top,
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
          left: viewport.left,
          right: viewport.right,
          bottom: viewport.bottom,
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
          left: viewport.left,
          right: viewport.right,
          bottom: viewport.bottom + inset + 6,
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
