import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// The title row of a top-level screen, with optional [actions] on the far
/// edge.
///
/// At [collapse] 0 the [title] is large and start-aligned; at 1 it is the
/// small title centered on the row, the way an iOS large title settles into
/// the navigation bar once content scrolls under it. Values in between morph
/// one into the other. [LargeTitleLayout] drives it from scrolling; on its own
/// it is the static large title.
///
/// The row is always [height] tall, so collapsing never shifts what's below.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.collapse = 0,
  });

  final String title;
  final List<Widget> actions;
  final double collapse;

  static const double height = 44;
  static const double sideSlotWidth = 100;
  static const double actionSpacing = 10;
  static const double _titleSpacing = 8;

  @override
  Widget build(BuildContext context) {
    final t = collapse.clamp(0.0, 1.0);
    final colors = BitcrColors.of(context);
    final text = context.bitcrText;
    final style = TextStyle.lerp(
      text.displaySmSemibold(color: colors.text300),
      text.textMdMedium(color: colors.text300),
      t,
    );
    const reserve = sideSlotWidth + _titleSpacing;
    final endReserve = actions.isEmpty ? reserve * t : reserve;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: reserve * t,
                end: endReserve,
              ),
              child: Align(
                alignment: AlignmentDirectional.lerp(
                  AlignmentDirectional.topStart,
                  AlignmentDirectional.center,
                  t,
                )!,
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ),
          ),
          if (actions.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: actionSpacing,
                children: actions,
              ),
            ),
        ],
      ),
    );
  }
}

/// A top-level screen's layout: a [ScreenHeader], an optional [pinned]
/// section (tabs, a search field) that always stays, an optional
/// [collapsible] section (search, filter badges) that gets out of the way,
/// and the scrolling [body].
///
/// Once the body is scrolled, the header collapses: the large title settles
/// into the small centered one, [collapsible] folds away and a hairline
/// separates the header from the content. Scrolling back to the top reverses
/// it. Both directions animate over [duration] rather than tracking the
/// finger, so a slow scroll still gets the whole transition.
///
/// Any vertical scrollable inside [body] drives it, however deeply nested —
/// a list per page of a [SwipeableViews] works as-is. A body too short to
/// scroll meaningfully never collapses, so the header can't fold away and
/// leave nothing to scroll back with.
///
/// Set [keepCollapsibleVisible] while [collapsible] is in use, for instance a
/// search with a query, so it stays put even with the header collapsed.
///
/// Sections are padded by [horizontalPadding]; the body is not.
class LargeTitleLayout extends StatefulWidget {
  const LargeTitleLayout({
    super.key,
    required this.title,
    this.actions = const [],
    this.pinned,
    this.collapsible,
    this.keepCollapsibleVisible = false,
    required this.body,
  });

  final String title;
  final List<Widget> actions;
  final Widget? pinned;
  final Widget? collapsible;
  final bool keepCollapsibleVisible;
  final Widget body;

  static const double horizontalPadding = 20;
  static const double sectionSpacing = 10;
  static const double bodySpacing = 14;
  static const Duration duration = Duration(milliseconds: 250);
  static const double collapseOffset = 4;
  static const double minScrollExtent = 80;

  @override
  State<LargeTitleLayout> createState() => _LargeTitleLayoutState();
}

class _LargeTitleLayoutState extends State<LargeTitleLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LargeTitleLayout.duration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  bool _collapsed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollUpdateNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;

    if (!_collapsed &&
        metrics.pixels > LargeTitleLayout.collapseOffset &&
        metrics.maxScrollExtent > LargeTitleLayout.minScrollExtent) {
      _collapsed = true;
      _controller.forward();
    } else if (_collapsed && metrics.pixels <= 0) {
      _collapsed = false;
      _controller.reverse();
    }

    return false;
  }

  Widget _section(Widget child) => Padding(
    padding: const EdgeInsets.fromLTRB(
      LargeTitleLayout.horizontalPadding,
      0,
      LargeTitleLayout.horizontalPadding,
      LargeTitleLayout.sectionSpacing,
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final pinned = widget.pinned;
    final collapsible = widget.collapsible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;
            final hideCollapsible = widget.keepCollapsibleVisible ? 0.0 : t;

            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: colors.divider75.withValues(
                      alpha: colors.divider75.a * t,
                    ),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section(
                    ScreenHeader(
                      title: widget.title,
                      actions: widget.actions,
                      collapse: t,
                    ),
                  ),
                  if (pinned != null) _section(pinned),
                  if (collapsible != null)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 1 - hideCollapsible,
                        child: Opacity(
                          opacity: 1 - hideCollapsible,
                          child: _section(collapsible),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: _onScroll,
            child: widget.body,
          ),
        ),
      ],
    );
  }
}
