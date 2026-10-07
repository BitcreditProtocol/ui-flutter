import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// A top navigation bar with three slots: [lead], [middle], and [trail].
///
/// - [lead] — left slot, typically a back button ([slotSize] tall, at least
///   [slotSize] wide).
/// - [middle] — center slot, typically a title. Pass whatever belongs there —
///   a title, an identity chip, a logo, a progress indicator; the bar doesn't
///   care. It is centered on the bar itself, not on the space between the
///   side slots, so a trail wider than [lead] no longer pulls it off-center;
///   only when it would collide with a side slot does it slide away from it.
/// - [trail] — right slot, typically an action icon or a [TopbarTextButton].
///   It takes the width its child needs, at least [slotSize].
/// - [actions] — shorthand for a [trail] of several buttons side by side,
///   spaced as the design spaces them. Pass either this or [trail].
/// - [slotSize] — the bar's height and the side slots' minimum width
///   (default: 44, matching [NavigateBackButton] and [TopbarActionButton], so
///   the bar is the same height and the back button sits in the same spot on
///   every screen).
/// - [trailSlotWidth] — pins the [trail] slot to an exact width. Rarely
///   needed: the slot already grows with its child and [middle] stays
///   centered either way.
/// - [backgroundAsset] — an illustration rendered behind the bar, bleeding to
///   full-screen size. Resolved against the host app's bundle, like
///   [EmptyState.asset]; pass [backgroundAssetPackage] for artwork shipping
///   inside a package. Tinted in dark mode so it doesn't glare.
///
/// [Topbar.search] is the variant whose middle is a search field filling the
/// space after [lead] rather than a centered title.
class Topbar extends StatelessWidget {
  const Topbar({
    super.key,
    this.lead,
    this.middle,
    this.trail,
    this.actions,
    this.backgroundAsset,
    this.backgroundAssetPackage,
    this.slotSize = 44,
    this.trailSlotWidth,
  }) : assert(
         trail == null || actions == null,
         'Pass either trail or actions, not both',
       ),
       _centerMiddle = true;

  const Topbar.search({
    super.key,
    this.lead,
    required Widget search,
    this.trail,
    this.actions,
    this.backgroundAsset,
    this.backgroundAssetPackage,
    this.slotSize = 44,
    this.trailSlotWidth,
  }) : assert(
         trail == null || actions == null,
         'Pass either trail or actions, not both',
       ),
       middle = search,
       _centerMiddle = false;

  final Widget? lead;
  final Widget? middle;
  final Widget? trail;
  final List<Widget>? actions;
  final String? backgroundAsset;
  final String? backgroundAssetPackage;
  final double slotSize;
  final double? trailSlotWidth;
  final bool _centerMiddle;

  static const double actionSpacing = 10;

  static const double _titleSpacing = 8;
  static const double _searchSpacing = 12;

  Widget? _buildTrail() {
    final children = actions;
    final Widget? content = children == null || children.isEmpty
        ? trail
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: actionSpacing,
            children: children,
          );
    if (content == null) return null;

    final width = trailSlotWidth;
    if (width != null) {
      return SizedBox(width: width, height: slotSize, child: content);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: slotSize, minHeight: slotSize),
      child: content,
    );
  }

  Widget _buildRow() {
    final leadChild = lead;
    final trailChild = _buildTrail();
    final middleChild = middle;

    final Widget? resolvedMiddle = middleChild == null
        ? null
        : _centerMiddle
        ? DefaultTextStyle.merge(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: middleChild,
          )
        : Padding(
            padding: EdgeInsetsDirectional.only(
              start: leadChild == null ? 0 : _searchSpacing,
              end: trailChild == null ? 0 : _searchSpacing,
            ),
            child: middleChild,
          );

    return SizedBox(
      height: slotSize,
      child: NavigationToolbar(
        leading: leadChild == null
            ? null
            : ConstrainedBox(
                constraints: BoxConstraints(minWidth: slotSize),
                child: leadChild,
              ),
        middle: resolvedMiddle,
        trailing: trailChild,
        centerMiddle: _centerMiddle,
        middleSpacing: _centerMiddle ? _titleSpacing : 0,
      ),
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
                        ? BitcrColors.of(context).white
                              .withValues(alpha: 180 / 255)
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
