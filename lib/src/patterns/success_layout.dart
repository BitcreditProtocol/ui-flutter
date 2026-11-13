import 'package:bitcr_ui/src/core/button.dart';
import 'package:bitcr_ui/src/core/button_styles.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:material_ui/material_ui.dart';

class SuccessLayout extends StatelessWidget {
  const SuccessLayout({
    required this.title,
    required this.description,
    required this.illustration,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryIcon,
    super.key,
  });

  final String title;
  final String description;
  final Widget illustration;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData? secondaryIcon;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 116),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.bitcrText.displayXsMedium(
                      color: colors.text300,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: context.bitcrText.textMdRegular(
                      color: colors.text200,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: AspectRatio(aspectRatio: 1, child: illustration),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Button(onPressed: onPrimary, child: Text(primaryLabel)),
        if (secondaryLabel case final label?) ...[
          const SizedBox(height: 12),
          Button(
            variant: ButtonVariant.outline,
            style: outlineButtonStyle(context),
            onPressed: onSecondary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (secondaryIcon case final icon?) ...[
                  Icon(icon, size: 20, color: colors.text300),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
