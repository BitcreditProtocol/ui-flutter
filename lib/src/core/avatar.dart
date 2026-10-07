import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// The avatar scale, 20 to 64. [chip] is the 24 an [IdentityChip] holds and
/// [nav] the 44 that stands in for a navigation button, both off the scale
/// because the design's are.
enum AvatarSize { xs, sm, md, lg, xl, chip, nav }

/// What the avatar stands for, which decides its shape and fallback: people
/// and anonymous entities are round, companies get a squared-off rounded rect,
/// and an anonymous entity shows a glyph instead of initials.
enum AvatarKind { personal, company, anon }

/// Uppercase initials from the first letter of up to two name words.
String avatarInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

  return words.take(2).map((word) => word.substring(0, 1)).join().toUpperCase();
}

/// An entity avatar: initials on a bordered surface, or a remote image when
/// there is one.
///
/// Not wallet-specific — use it for wallets, contacts, companies and users
/// alike. [kind] drives the shape and the fallback; [dark] inverts it, which
/// the wallet uses to mark testnet.
///
/// [backgroundColor] and [borderColor] exist because the avatar has to sit on
/// surfaces of different elevations — pass the one it's resting on so the
/// circle doesn't look cut out of the wrong shade.
///
/// [gradient] fills the avatar with colour instead, for an app that tells its
/// identities apart by hue; the initials turn white and the border goes, since
/// the fill already separates it from the surface. It wins over [dark] and
/// [backgroundColor]. The palette is the app's, not this package's.
///
/// [imageUrl] is the common case and is loaded over the network. Pass [image]
/// instead for a picture that is not at a URL — one just chosen on the device
/// and not yet uploaded, or a bundled asset. It takes precedence, and either
/// way the avatar clips it, covers with it and decodes it at display size.
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

    final Widget fallback = kind == AvatarKind.anon
        ? Icon(Icons.person, color: foreground, size: _fontSize * 1.2)
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
