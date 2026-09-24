import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Publishes the height of a screen's body so an [EmptyState] below it can
/// tell how much of that body the header took.
///
/// Wrap a screen body once, outside its header — usually a [LayoutBuilder]
/// straight inside the `SafeArea` — and every empty state under it lands at
/// the same height, whatever the header is made of and whenever it grows or
/// shrinks:
///
/// ```dart
/// LayoutBuilder(
///   builder: (context, constraints) => EmptyStateAnchor(
///     bodyHeight: constraints.maxHeight,
///     child: Column(children: [MyHeader(), Expanded(child: list)]),
///   ),
/// )
/// ```
class EmptyStateAnchor extends InheritedWidget {
  const EmptyStateAnchor({
    super.key,
    required this.bodyHeight,
    required super.child,
  });

  final double bodyHeight;

  static double? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<EmptyStateAnchor>()
      ?.bodyHeight;

  @override
  bool updateShouldNotify(EmptyStateAnchor oldWidget) =>
      bodyHeight != oldWidget.bodyHeight;
}

/// The "nothing here yet" placeholder: an illustration over a title, a wrapped
/// subtitle and an optional action button. Shared by the payments, requests,
/// notifications and contacts lists.
///
/// Under an [EmptyStateAnchor] the illustration hangs [illustrationTop] below
/// the top of the screen body. That is what stops it drifting when the header
/// above it gains a search field or a row of filter badges, and what lines
/// several lists up with each other despite their different headers. Without
/// an anchor it falls back to centring in the space it is given, which is what
/// you want inside a drawer or a card.
///
/// [asset] is resolved against the host app's asset bundle, so the
/// illustration stays app-owned; pass [assetPackage] to load one that ships
/// inside a package instead.
///
/// [asset] goes through [Image.asset], which decodes raster formats only. An
/// app whose illustrations are SVG — or any other format this package should
/// not need a decoder for — passes [illustration] and renders it itself. It is
/// given the same [imageHeight] a bundled asset would get, so the two line up.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.asset,
    this.illustration,
    required this.title,
    required this.subtitle,
    this.assetPackage,
    this.buttonLabel,
    this.buttonIcon,
    this.onTap,
    this.illustrationTop = defaultIllustrationTop,
  }) : assert(
         (asset == null) != (illustration == null),
         'Provide either asset or illustration, not both',
       );

  final String? asset;
  final Widget? illustration;
  final String? assetPackage;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onTap;
  final double illustrationTop;

  static const double defaultIllustrationTop = 209;
  static const double imageHeight = 72;
  static const double _subtitleWidth = 216;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final label = buttonLabel;
    final icon = buttonIcon;
    final bodyHeight = EmptyStateAnchor.maybeOf(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: imageHeight,
            child:
                illustration ??
                Image.asset(asset!, package: assetPackage, height: imageHeight),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.bitcrText.textLgMedium(color: colors.text300),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: _subtitleWidth,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.bitcrText.textMdRegular(color: colors.text200),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.text300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BitcrRadius.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: colors.text300),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: context.bitcrText.textSmMedium(
                      color: colors.text300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final topInset = bodyHeight == null
            ? null
            : (illustrationTop - (bodyHeight - constraints.maxHeight)).clamp(
                0.0,
                illustrationTop,
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: topInset == null
                ? Center(child: content)
                : Padding(
                    padding: EdgeInsets.only(top: topInset),
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: content,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
