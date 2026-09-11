import 'package:bitcr_ui/src/core/backup_dot.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

/// One destination in a [BottomNavigation].
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    this.showBadge = false,
  });

  final String label;
  final IconData icon;
  final bool showBadge;
}

/// The app's bottom tab bar: evenly spaced icon-and-label destinations over a
/// top-bordered surface, with the safe-area inset handled.
///
/// Entirely driven by [items] — the bar knows nothing about routes, so the app
/// maps [onTap] to whatever navigation it uses.
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final bottomPadding = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 0.0,
      TargetPlatform.macOS => 10.0,
      _ => isTablet ? 0.0 : 5.0,
    };

    return SafeArea(
      top: false,
      left: false,
      right: false,
      maintainBottomViewPadding: true,
      child: Container(
        padding: EdgeInsets.only(bottom: bottomPadding, top: 14),
        decoration: BoxDecoration(
          color: colors.elevation50,
          border: Border(top: BorderSide(color: colors.divider100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final (index, item) in items.indexed)
              Expanded(
                child: _NavigationButton(
                  label: item.label,
                  icon: item.icon,
                  isActive: index == currentIndex,
                  showBadge: item.showBadge,
                  onPressed: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isActive = false,
    this.showBadge = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final decorationColor = isActive ? colors.text300 : colors.text200;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: decorationColor),
              if (showBadge)
                const Positioned(top: -2, right: -4, child: BackupDot()),
            ],
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: decorationColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
