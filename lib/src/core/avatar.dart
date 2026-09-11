import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

enum AvatarSize { xs, sm, md, lg }

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
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AvatarSize.sm,
    this.kind = AvatarKind.personal,
    this.dark = false,
    this.backgroundColor,
    this.borderColor,
  });

  final String name;
  final String? imageUrl;
  final AvatarSize size;
  final AvatarKind kind;
  final bool dark;
  final Color? backgroundColor;
  final Color? borderColor;

  double get _dimension => switch (size) {
    AvatarSize.xs => 20,
    AvatarSize.sm => 32,
    AvatarSize.md => 40,
    AvatarSize.lg => 48,
  };

  double get _fontSize => switch (size) {
    AvatarSize.xs => 10,
    AvatarSize.sm => 14,
    AvatarSize.md => 16,
    AvatarSize.lg => 20,
  };

  BorderRadius get _borderRadius => switch (kind) {
    AvatarKind.personal ||
    AvatarKind.anon => BorderRadius.circular(_dimension),
    AvatarKind.company => BorderRadius.circular(_dimension * 0.2),
  };

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final dim = _dimension;
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    final resolvedBackground =
        backgroundColor ?? (dark ? colors.black : colors.elevation50);
    final resolvedBorder = borderColor ?? colors.divider75;
    final foreground = dark ? colors.white : colors.text300;

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
        color: resolvedBackground,
        border: Border.all(color: resolvedBorder),
        borderRadius: _borderRadius,
      ),
      child: hasImage
          ? Stack(
              alignment: Alignment.center,
              children: [fallback, _AvatarImage(url: url, dimension: dim)],
            )
          : fallback,
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url, required this.dimension});

  final String url;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final decodeSize =
        (dimension * MediaQuery.devicePixelRatioOf(context)).round();

    return Image(
      image: ResizeImage(
        NetworkImage(url),
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
