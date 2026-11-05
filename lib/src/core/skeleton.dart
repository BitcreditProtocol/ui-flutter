import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.widthFactor,
    this.color,
    this.radius = 6,
  });

  final double? width;
  final double? height;
  final double? widthFactor;
  final Color? color;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  static const _curve = Cubic(0.4, 0, 0.6, 1);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  late final _opacity = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: _curve)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: _curve)),
      weight: 1,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget block = FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? BitcrColors.of(context).elevation200,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );

    if (widget.widthFactor case final factor?) {
      block = FractionallySizedBox(
        widthFactor: factor,
        alignment: AlignmentDirectional.centerStart,
        child: block,
      );
    }

    return ExcludeSemantics(child: block);
  }
}
