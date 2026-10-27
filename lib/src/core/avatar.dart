import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

enum AvatarSize { xs, sm, md, lg, xl, chip, nav }

enum AvatarKind { personal, company, anon }

String avatarInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

  return words.take(2).map((word) => word.substring(0, 1)).join().toUpperCase();
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.image,
    this.size = AvatarSize.sm,
    this.kind = AvatarKind.personal,
    this.dark = false,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.placeholderIcon,
  });

  final String name;
  final String? imageUrl;
  final ImageProvider? image;
  final AvatarSize size;
  final AvatarKind kind;
  final bool dark;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final IconData? placeholderIcon;

  double get _dimension => switch (size) {
    AvatarSize.xs => 20,
    AvatarSize.sm => 32,
    AvatarSize.md => 40,
    AvatarSize.lg => 48,
    AvatarSize.xl => 64,
    AvatarSize.chip => 24,
    AvatarSize.nav => 44,
  };

  double get _fontSize => switch (size) {
    AvatarSize.xs => 10,
    AvatarSize.sm => 14,
    AvatarSize.md => 16,
    AvatarSize.lg => 20,
    AvatarSize.xl => 24,
    AvatarSize.chip => 10,
    AvatarSize.nav => 14,
  };

  BorderRadius get _borderRadius => switch (kind) {
    AvatarKind.personal || AvatarKind.anon => BorderRadius.circular(_dimension),
    AvatarKind.company => BorderRadius.circular(_dimension * 0.2),
  };

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final dim = _dimension;
    final url = imageUrl;
    final provider =
        image ?? (url != null && url.isNotEmpty ? NetworkImage(url) : null);

    final resolvedBackground =
        backgroundColor ?? (dark ? colors.black : colors.elevation50);
    final resolvedBorder = gradient != null
        ? null
        : Border.all(color: borderColor ?? colors.divider75);
    final foreground = gradient != null || dark ? colors.white : colors.text300;

    final placeholder = name.trim().isEmpty ? placeholderIcon : null;

    final Widget fallback = kind == AvatarKind.anon || placeholder != null
        ? Icon(
            placeholder ?? Icons.person,
            color: foreground,
            size: _fontSize * 1.2,
          )
        : Text(
            avatarInitials(name),
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1,
            ),
          );

    return Container(
      width: dim,
      height: dim,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gradient == null ? resolvedBackground : null,
        gradient: gradient,
        border: resolvedBorder,
        borderRadius: _borderRadius,
      ),
      child: provider == null
          ? fallback
          : Stack(
              alignment: Alignment.center,
              children: [
                fallback,
                _AvatarImage(image: provider, dimension: dim),
              ],
            ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.image, required this.dimension});

  final ImageProvider image;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final decodeSize = (dimension * MediaQuery.devicePixelRatioOf(context))
        .round();

    return Image(
      image: ResizeImage(
        image,
        width: decodeSize,
        height: decodeSize,
        policy: ResizeImagePolicy.fit,
      ),
      width: dimension,
      height: dimension,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => const SizedBox.shrink(),
    );
  }
}
