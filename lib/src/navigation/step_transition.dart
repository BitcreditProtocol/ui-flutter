import 'package:bitcr_ui/src/theme/page_transitions.dart';
import 'package:flutter/material.dart';

class StepTransition extends StatefulWidget {
  const StepTransition({required this.step, required this.child, super.key});

  final int step;
  final Widget child;

  static const duration = Duration(milliseconds: 300);

  @override
  State<StepTransition> createState() => _StepTransitionState();
}

class _StepTransitionState extends State<StepTransition> {
  var _isForward = true;

  @override
  void didUpdateWidget(StepTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.step != oldWidget.step) {
      _isForward = widget.step > oldWidget.step;

      _dismissKeyboard();
    }
  }

  static Animation<double> _curved(Animation<double> parent) =>
      CurvedAnimation(parent: parent, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final current = ValueKey(widget.step);

    return ClipRect(
      child: AnimatedSwitcher(
        duration: StepTransition.duration,
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.passthrough,
          children: _isForward
              ? [...previous, ?current]
              : [?current, ...previous],
        ),
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == current;

          if (isIncoming != _isForward) {
            return ScaleTransition(
              scale: Tween(
                begin: 1.0,
                end: kPageScaleFactor,
              ).animate(_curved(ReverseAnimation(animation))),
              child: child,
            );
          }

          return SlideTransition(
            position: _isForward
                ? Tween(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(_curved(animation))
                : Tween(
                    begin: Offset.zero,
                    end: const Offset(1, 0),
                  ).animate(_curved(ReverseAnimation(animation))),
            child: child,
          );
        },
        child: KeyedSubtree(key: current, child: widget.child),
      ),
    );
  }
}

void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

class StepFocusReset extends StatefulWidget {
  const StepFocusReset({required this.step, required this.child, super.key});

  final Object step;
  final Widget child;

  @override
  State<StepFocusReset> createState() => _StepFocusResetState();
}

class _StepFocusResetState extends State<StepFocusReset> {
  @override
  void didUpdateWidget(StepFocusReset oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.step != oldWidget.step) _dismissKeyboard();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
