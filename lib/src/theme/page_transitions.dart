import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart' show CupertinoPageTransition;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kBackGestureWidth = 20.0;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // milliseconds
const int _kMaxPageBackAnimationTime = 300; // milliseconds
const double _kMinFlingVelocity = 1.0;

/// End scale of the zoom-out applied to a screen once another route is
/// pushed on top of it.
///
/// Exported because an app that scales a shell or a pinned element alongside
/// the page has to use the same number, or backgrounded screens zoom by
/// different amounts depending on how they were pushed.
const double kPageScaleFactor = 1.03;

/// The page transition every Bitcredit app uses: the incoming route slides in
/// from the trailing edge while the one behind it zooms out slightly, plus an
/// edge swipe-back gesture.
///
/// Wired up by [BitcrTheme] through [ThemeData.pageTransitionsTheme], so it
/// applies to ordinary pushes without call sites doing anything. An app that
/// drives a transition by hand — say to slide the content while pinning a nav
/// bar — can call [buildTransitions] directly.
class BitcrPageTransitionsBuilder extends PageTransitionsBuilder {
  const BitcrPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final detector = _SwipeBackGestureDetector<T>(
      key: GlobalObjectKey(route),
      route: route,
      child: child,
    );

    final userGestureInProgress =
        route.navigator?.userGestureInProgress ?? false;

    // Mid-swipe the route has to track the finger linearly, which is exactly
    // what Cupertino's transition does — the curved slide below would fight it.
    if (userGestureInProgress && animation.value < 1.0) {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: true,
        child: detector,
      );
    }

    final Widget primary = DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (context, animation, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        textDirection: Directionality.of(context),
        child: child!,
      ),
      reverseBuilder: (context, animation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1.0, 0.0),
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          textDirection: Directionality.of(context),
          child: child,
        );
      },
      child: detector,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: kPageScaleFactor).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        ),
      ),
      child: primary,
    );
  }
}

/// Renders one throwaway cycle of the app's page-transition effects (the
/// slide + scale from [BitcrPageTransitionsBuilder]) at near-zero opacity right
/// after the first frame. The engine compiles each GPU pipeline the first
/// time it's actually drawn, so without this the first few *different*
/// transitions after launch (first push, first pop, ...) each stall while
/// their pipeline compiles; this pays that cost once, invisibly, before the
/// user's first real navigation.
///
/// It duplicates the builder's effects on purpose, and has to keep duplicating
/// them: warming a transition the app no longer uses warms nothing. Change one,
/// change the other.
class TransitionWarmUp extends StatefulWidget {
  const TransitionWarmUp({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<TransitionWarmUp> createState() => _TransitionWarmUpState();
}

class _TransitionWarmUpState extends State<TransitionWarmUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    await _controller.forward();
    await _controller.reverse();
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const SizedBox.expand(),
    );

    final slid = DualTransitionBuilder(
      animation: _controller,
      forwardBuilder: (context, animation, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child!,
      ),
      reverseBuilder: (context, animation, child) => SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child!,
      ),
      child: content,
    );

    final scaled = ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: kPageScaleFactor).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      ),
      child: slid,
    );

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(opacity: 0.01, child: SizedBox.expand(child: scaled)),
      ),
    );
  }
}

class _SwipeBackGestureDetector<T> extends StatefulWidget {
  const _SwipeBackGestureDetector({
    super.key,
    required this.route,
    required this.child,
  });

  final PageRoute<T> route;
  final Widget child;

  @override
  State<_SwipeBackGestureDetector<T>> createState() =>
      _SwipeBackGestureDetectorState<T>();
}

class _SwipeBackGestureDetectorState<T>
    extends State<_SwipeBackGestureDetector<T>> {
  late final HorizontalDragGestureRecognizer _recognizer;
  _SwipeBackGestureController? _gestureController;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();

    // A gesture still in flight when this is torn down would leave the
    // navigator believing a user gesture is in progress forever.
    if (_gestureController != null) {
      final navigator = _gestureController!.navigator;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.mounted && navigator.userGestureInProgress) {
          navigator.didStopUserGesture();
        }
      });

      _gestureController = null;
    }

    super.dispose();
  }

  bool get _isGestureEnabled {
    final route = widget.route;

    if (route.isFirst) return false;
    if (route.willHandlePopInternally) return false;
    if (route.fullscreenDialog) return false;
    if (route.popDisposition == RoutePopDisposition.doNotPop) return false;
    if (route.animation!.status != AnimationStatus.completed) return false;

    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }

    if (route.navigator!.userGestureInProgress) return false;

    return true;
  }

  double _convertToLogical(double value) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => -value,
      TextDirection.ltr => value,
    };
  }

  double get _width => context.size?.width ?? 1;

  void _handleDragStart(DragStartDetails details) {
    _gestureController = _SwipeBackGestureController(
      navigator: widget.route.navigator!,
      // ignore: invalid_use_of_protected_member
      controller: widget.route.controller!,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _gestureController?.dragUpdate(
      _convertToLogical(details.primaryDelta! / _width),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    _gestureController?.dragEnd(
      _convertToLogical(details.velocity.pixelsPerSecond.dx / _width),
    );
    _gestureController = null;
  }

  void _handleDragCancel() {
    _gestureController?.dragEnd(0);
    _gestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isGestureEnabled) _recognizer.addPointer(event);
  }

  @override
  Widget build(BuildContext context) {
    final gestureWidth =
        _kBackGestureWidth + MediaQuery.paddingOf(context).left;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: gestureWidth,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

class _SwipeBackGestureController {
  _SwipeBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      final droppedPageForwardAnimationTime = math.min(
        lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime,
          0,
          controller.value,
        )!.floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1.0,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: animationCurve,
      );
    } else {
      navigator.pop();

      if (controller.isAnimating) {
        final droppedPageBackAnimationTime = lerpDouble(
          0,
          _kMaxDroppedSwipePageForwardAnimationTime,
          controller.value,
        )!.floor();
        controller.animateBack(
          0.0,
          duration: Duration(milliseconds: droppedPageBackAnimationTime),
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      late final AnimationStatusListener animationStatusCallback;

      animationStatusCallback = (status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
