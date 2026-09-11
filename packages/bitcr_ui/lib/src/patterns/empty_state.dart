import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// The "nothing here yet" placeholder: a centred illustration over a title, a
/// wrapped subtitle and an optional action button. Shared by the payments,
/// requests and notifications lists so they line up exactly.
///
/// [asset] is resolved against the host app's asset bundle, so the
/// illustration stays app-owned; pass [assetPackage] to load one that ships
/// inside a package instead.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    this.assetPackage,
    this.buttonLabel,
    this.onTap,
    this.topInset = 0,
  });

  final String asset;
  final String? assetPackage;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onTap;
  final double topInset;

  static const double _imageHeight = 72;
  static const double _subtitleWidth = 216;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final label = buttonLabel;

    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      asset,
                      package: assetPackage,
                      height: _imageHeight,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.bitcrText.textLgMedium(
                        color: colors.text300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _subtitleWidth,
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: context.bitcrText.textMdRegular(
                          color: colors.text200,
                        ),
                      ),
                    ),
                    if (label != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.divider300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              BitcrRadius.md,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          label,
                          style: context.bitcrText.textSmMedium(
                            color: colors.text300,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
