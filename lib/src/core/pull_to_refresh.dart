import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// Wraps a screen in the pull-down-to-refresh gesture.
///
/// [onRefresh] must complete when the work is done — the spinner stays up
/// until its future resolves.
///
/// The gesture is driven by the nearest scrollable below this widget, which
/// accepts the pull even when its content is shorter than the viewport, so a
/// screen's existing scroll view needs no physics of its own. A screen with
/// no scrollable at all has nothing to overscroll, so set [childScrolls] to
/// false there and the wrapper supplies a scroll view that accepts the pull.
///
/// [semanticsLabel] is the screen reader's announcement; the library ships no
/// strings, so a localised app passes its own.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.childScrolls = true,
    this.semanticsLabel,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final bool childScrolls;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.brand200,
      backgroundColor: colors.elevation100,
      semanticsLabel: semanticsLabel,
      child: childScrolls
          ? _FillingScrollable(child: child)
          : _AlwaysScrollable(child: child),
    );
  }
}

/// Lets the child's own scroll view take the pull.
///
/// Scroll views below default to physics that ignore a drag when their
/// content fits, so this makes them always accept one. And the indicator
/// stacks its child loosely, which would shrink a SingleChildScrollView to
/// its content: a pull on the blank space below would miss it, and the screen
/// would lay out smaller than without the wrapper, so this fills instead.
class _FillingScrollable extends StatelessWidget {
  const _FillingScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);

    return SizedBox.expand(
      child: ScrollConfiguration(
        behavior: behavior.copyWith(
          physics: AlwaysScrollableScrollPhysics(
            parent: behavior.getScrollPhysics(context),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _AlwaysScrollable extends StatelessWidget {
  const _AlwaysScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}
