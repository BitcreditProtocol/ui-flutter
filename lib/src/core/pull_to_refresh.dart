import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// Wraps a screen in the pull-down-to-refresh gesture.
///
/// [onRefresh] must complete when the work is done — the spinner stays up
/// until its future resolves.
///
/// The gesture is driven by the nearest scrollable below this widget. A screen
/// whose content is shorter than the viewport has nothing to overscroll, so
/// set [childScrolls] to false there and the wrapper supplies a scroll view
/// that always accepts the pull.
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
      child: childScrolls ? child : _AlwaysScrollable(child: child),
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
