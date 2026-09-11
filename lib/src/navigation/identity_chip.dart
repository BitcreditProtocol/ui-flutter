import 'package:bitcr_ui/src/core/avatar.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A pill naming the thing the screen is currently acting as: an avatar, a
/// name, and optionally a chevron when there's something to switch to.
///
/// Not wallet-specific — a wallet, an account, a company, a user. It sits in
/// [Topbar]'s middle slot.
///
/// Use it directly when there's nothing to switch to; wrap it in an
/// [IdentitySwitcher] when there is.
class IdentityChip extends StatelessWidget {
  const IdentityChip({
    super.key,
    required this.name,
    this.imageUrl,
    this.showChevron = false,
    this.open = false,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool showChevron;
  final bool open;
  final VoidCallback? onTap;

  static const double minHeight = 40;
  static const double _maxNameWidth = 160;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    final pill = Container(
      constraints: const BoxConstraints(minWidth: 64, minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.elevation200,
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: open ? colors.divider200 : colors.divider50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Avatar(
            name: name,
            imageUrl: imageUrl,
            borderColor: colors.divider50,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxNameWidth),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: context.bitcrText
                  .textSmMedium(color: colors.text300)
                  .copyWith(height: 1.5),
            ),
          ),
          if (showChevron)
            Icon(
              open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
              color: colors.text300,
            ),
        ],
      ),
    );

    if (onTap == null) return pill;

    return GestureDetector(onTap: onTap, child: pill);
  }
}
