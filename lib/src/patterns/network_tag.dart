import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

class NetworkTag extends StatelessWidget {
  const NetworkTag({
    super.key,
    required this.label,
    this.isOffline = false,
    this.onTap,
    this.semanticHint,
  });

  final String label;
  final bool isOffline;
  final VoidCallback? onTap;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final onTap = this.onTap;

    final tag = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingDot(
          color: isOffline ? colors.signalError : colors.signalSuccess,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: context.bitcrText.textSmRegular(color: colors.text200),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 6),
          Icon(LucideIcons300.chevronDown, size: 16, color: colors.text200),
        ],
      ],
    );

    if (onTap == null) return tag;

    return Semantics(
      button: true,
      hint: semanticHint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: tag,
      ),
    );
  }
}

class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, required this.color});

  final Color color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;

              return Opacity(
                opacity: (1 - t) * 0.2,
                child: Transform.scale(scale: 0.6 + t * 0.4, child: child),
              );
            },
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
