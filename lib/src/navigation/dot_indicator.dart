import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.steps,
    required this.current,
    this.onTap,
    this.semanticLabelBuilder,
  });

  final int steps;
  final int current;
  final ValueChanged<int>? onTap;
  final String Function(int index)? semanticLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final color = BitcrColors.of(context).text300;
    final onTap = this.onTap;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < steps; index++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Semantics(
              button: true,
              selected: index == current,
              label: semanticLabelBuilder?.call(index),
              child: GestureDetector(
                onTap: onTap == null ? null : () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == current
                        ? color
                        : color.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
