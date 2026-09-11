import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// A top navigation bar with three slots: [lead], [middle], and [trail].
///
/// - [lead] — left slot, typically a back button ([slotSize]×[slotSize])
/// - [middle] — center slot, typically a title (expands to fill remaining
///   space). Pass whatever belongs there — a title, an identity chip, a
///   segmented control; the bar doesn't care.
/// - [trail] — right slot, typically an action icon ([slotSize]×[slotSize]).
///   When null, a same-sized placeholder is rendered to keep [middle] centered.
/// - [slotSize] — side slot dimensions (default: 40, matching
///   [NavigateBackButton] and [TopbarActionButton], so the bar is the same
///   height and the back button sits in the same spot on every screen). Only
///   override it for a bar whose side buttons are deliberately smaller; a slot
///   smaller than its child forces the child to fill it anyway, except for
///   [NavigateBackButton], which escapes via an OverflowBox and ends up 4px
///   off.
/// - [trailSlotWidth] — width of the [trail] slot alone (default: [slotSize]).
///   Widen it for a bar that trails more than one action button (see
///   [TopbarActionGroup.widthFor]). [middle] is centered in whatever the slots
///   leave over, so a trail wider than [lead] shifts the title left of the
///   bar's true center.
/// - [backgroundAsset] — an illustration rendered behind the bar, bleeding to
///   full-screen size. Resolved against the host app's bundle, like
///   [EmptyState.asset]; pass [backgroundAssetPackage] for artwork shipping
///   inside a package. Tinted in dark mode so it doesn't glare.
class Topbar extends StatelessWidget {
  const Topbar({
    super.key,
    this.lead,
    this.middle,
    this.trail,
    this.backgroundAsset,
    this.backgroundAssetPackage,
    this.slotSize = 40,
    this.trailSlotWidth,
  });

  final Widget? lead;
  final Widget? middle;
  final Widget? trail;
  final String? backgroundAsset;
  final String? backgroundAssetPackage;
  final double slotSize;
  final double? trailSlotWidth;

  Widget _buildRow() {
    return Row(
      children: [
        SizedBox(width: slotSize, height: slotSize, child: lead),
        Expanded(child: Center(child: middle)),
        SizedBox(
          width: trailSlotWidth ?? slotSize,
          height: slotSize,
          child: trail,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = backgroundAsset;
    if (asset == null) return _buildRow();

    final screenSize = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.viewPaddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hBleed = (screenSize.width - constraints.maxWidth) / 2;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -(topPadding + 8),
              left: -hBleed,
              width: screenSize.width,
              height: screenSize.height,
              child: Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Image.asset(
                    asset,
                    package: backgroundAssetPackage,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                    color: isDark
                        ? BitcrColors.of(
                            context,
                          ).white.withValues(alpha: 180 / 255)
                        : null,
                    colorBlendMode: isDark ? BlendMode.srcATop : null,
                  );
                },
              ),
            ),
            _buildRow(),
          ],
        );
      },
    );
  }
}
