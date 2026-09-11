import 'package:flutter/material.dart';

/// A horizontally swipeable pager for tab-bar screens, keeping the selected
/// [index] and the page position in sync: swiping reports the new index, and
/// an [index] changed from outside (a tab tap) slides to that page.
class SwipeableViews extends StatefulWidget {
  const SwipeableViews({
    super.key,
    required this.index,
    required this.onIndexChanged,
    required this.children,
  });

  final int index;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> children;

  static const Duration duration = Duration(milliseconds: 250);

  @override
  State<SwipeableViews> createState() => _SwipeableViewsState();
}

class _SwipeableViewsState extends State<SwipeableViews> {
  late final PageController _controller = PageController(
    initialPage: widget.index,
  );

  @override
  void didUpdateWidget(covariant SwipeableViews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index || !_controller.hasClients) return;

    _controller.animateToPage(
      widget.index,
      duration: SwipeableViews.duration,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.children.length,
      onPageChanged: widget.onIndexChanged,
      itemBuilder: (context, index) => widget.children[index],
    );
  }
}
