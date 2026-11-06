import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Spinner extends StatefulWidget {
  const Spinner({super.key, this.size = 16, this.color, this.semanticLabel});

  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _controller,
    child: Icon(
      LucideIcons.loader,
      size: widget.size,
      color:
          widget.color ??
          IconTheme.of(context).color ??
          BitcrColors.of(context).text300,
      semanticLabel: widget.semanticLabel,
    ),
  );
}
