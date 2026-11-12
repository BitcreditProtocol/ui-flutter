import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';

class Separator extends StatelessWidget {
  const Separator({super.key, this.color, this.indent = 0});

  final Color? color;
  final double indent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(start: indent),
    child: CustomPaint(
      size: const Size.fromHeight(1),
      painter: _RulePainter(
        color: color ?? BitcrColors.of(context).divider75,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      ),
    ),
  );
}

class _RulePainter extends CustomPainter {
  const _RulePainter({required this.color, required this.devicePixelRatio});

  final Color color;
  final double devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final pixels = devicePixelRatio.round().clamp(1, 4);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, pixels / devicePixelRatio),
      Paint()
        ..color = color
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) =>
      old.color != color || old.devicePixelRatio != devicePixelRatio;
}
