import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Sizes', type: Avatar)
Widget avatarSizes(BuildContext context) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  spacing: 16,
  children: [
    for (final size in AvatarSize.values)
      Avatar(name: 'Wallet 1', size: size),
  ],
);

/// The three kinds side by side — personal is round, a company gets the
/// squared-off radius, anon shows a glyph instead of initials.
@widgetbook.UseCase(name: 'Kinds', type: Avatar)
Widget avatarKinds(BuildContext context) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  spacing: 16,
  children: [
    for (final kind in AvatarKind.values)
      Avatar(name: 'Wallet 1', kind: kind, size: AvatarSize.lg),
  ],
);

/// `dark` is what the wallet sets on testnet — the same avatar, marked.
@widgetbook.UseCase(name: 'Dark', type: Avatar)
Widget avatarDark(BuildContext context) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  spacing: 16,
  children: const [
    Avatar(name: 'Wallet 1', size: AvatarSize.lg),
    Avatar(name: 'Wallet 1', size: AvatarSize.lg, dark: true),
  ],
);

/// In a list, which is where the border earns its keep: the avatar sits on a
/// raised row, so it takes that row's fill rather than the page's.
@widgetbook.UseCase(name: 'In a wallet list', type: Avatar)
Widget avatarInList(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final name in const ['Wallet 1', 'Wallet 3', 'Wallet 2'])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.divider50)),
            ),
            child: Row(
              spacing: 12,
              children: [
                Avatar(
                  name: name,
                  backgroundColor: colors.elevation200,
                  borderColor: colors.divider50,
                ),
                Text(name, style: context.bitcrText.textMdMedium()),
              ],
            ),
          ),
      ],
    ),
  );
}

/// A single-word name yields one initial, and an empty name none at all —
/// the circle has to survive both.
@widgetbook.UseCase(name: 'Initials fallback', type: Avatar)
Widget avatarInitialsFallback(BuildContext context) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  spacing: 16,
  children: const [
    Avatar(name: 'Alice Andersson', size: AvatarSize.lg),
    Avatar(name: 'Alice', size: AvatarSize.lg),
    Avatar(name: '', size: AvatarSize.lg),
  ],
);

/// An unreachable URL, so the image fails and the initials behind it show
/// through.
@widgetbook.UseCase(name: 'Broken image URL', type: Avatar)
Widget avatarBrokenImage(BuildContext context) => const Avatar(
  name: 'Alice Andersson',
  imageUrl: 'https://example.invalid/missing.png',
  size: AvatarSize.lg,
);

@widgetbook.UseCase(name: 'Playground', type: Avatar)
Widget avatarPlayground(BuildContext context) => Avatar(
  name: context.knobs.string(label: 'Name', initialValue: 'Wallet 1'),
  imageUrl: context.knobs.stringOrNull(label: 'Image URL'),
  size: context.knobs.object.dropdown(
    label: 'Size',
    options: AvatarSize.values,
    initialOption: AvatarSize.sm,
    labelBuilder: (s) => s.name,
  ),
  kind: context.knobs.object.dropdown(
    label: 'Kind',
    options: AvatarKind.values,
    labelBuilder: (k) => k.name,
  ),
  dark: context.knobs.boolean(label: 'Dark'),
);
