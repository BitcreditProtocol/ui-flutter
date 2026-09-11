import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A full-screen "hold on, we're switching" state: a spinner over a title and
/// a hint. Shown while the app tears down and rebuilds around a change the
/// user just made (switching wallet, network or account).
///
/// [title] and [subtitle] are required — the app supplies the translated copy.
class SwitchingOverlay extends StatelessWidget {
  const SwitchingOverlay({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitcrColors.of(context).elevation50,
      body: Center(
        child: SwitchingStatusContent(title: title, subtitle: subtitle),
      ),
    );
  }
}

/// The spinner-title-subtitle stack on its own, for the same state shown
/// inside an existing layout rather than as a whole screen.
class SwitchingStatusContent extends StatelessWidget {
  const SwitchingStatusContent({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SpinningLoader(),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style:
              titleStyle ??
              context.bitcrText.displayXsMedium(color: colors.text300),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style:
              subtitleStyle ??
              context.bitcrText.textSmRegular(color: colors.text200),
        ),
      ],
    );
  }
}

/// The continuously rotating loader icon, at the 900ms turn the design uses.
class SpinningLoader extends StatefulWidget {
  const SpinningLoader({super.key, this.size = 40});

  final double size;

  @override
  State<SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<SpinningLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        LucideIcons.loader,
        size: widget.size,
        color: BitcrColors.of(context).text300,
      ),
    );
  }
}
