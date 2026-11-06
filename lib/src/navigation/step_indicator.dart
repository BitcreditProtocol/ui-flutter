import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.steps,
    required this.current,
    this.semanticLabel,
  });

  final int steps;
  final int current;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < steps; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 22,
                height: 2,
                decoration: BoxDecoration(
                  color: index <= current
                      ? colors.text300
                      : colors.elevation350,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
