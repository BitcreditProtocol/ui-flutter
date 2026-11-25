import 'package:material_ui/material_ui.dart';

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

  /// The page a tab tap is sliding to, while that slide runs. Pages passed on
  /// the way (Balances, between Activity and Requests) are not reported:
  /// reporting one would select it and stop the slide there.
  int? _slidingTo;

  @override
  void didUpdateWidget(covariant SwipeableViews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index || !_controller.hasClients) return;

    final target = widget.index;
    _slidingTo = target;
    // Completes when the slide ends or a drag interrupts it; a newer tap
    // has already replaced the target.
    _controller
        .animateToPage(
          target,
          duration: SwipeableViews.duration,
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (_slidingTo == target) _slidingTo = null;
        });
  }

  void _onPageChanged(int page) {
    if (_slidingTo != null) return;
    widget.onIndexChanged(page);
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
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) => widget.children[index],
    );
  }
}
