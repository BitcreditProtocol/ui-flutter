import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Widget _page(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Align(alignment: Alignment.topCenter, child: child),
);

@widgetbook.UseCase(name: 'Back and title', type: Topbar)
Widget topbarBackAndTitle(BuildContext context) => _page(
  Topbar(
    lead: NavigateBackButton(onPressed: () {}),
    middle: Text('Payment details', style: context.bitcrText.textMdMedium()),
  ),
);

/// One trailing action. The trail slot is the same width as the lead, so the
/// title stays on the bar's true center.
@widgetbook.UseCase(name: 'With trailing action', type: Topbar)
Widget topbarWithTrailingAction(BuildContext context) => _page(
  Topbar(
    lead: NavigateBackButton(onPressed: () {}),
    middle: Text('Payment details', style: context.bitcrText.textMdMedium()),
    trail: TopbarActionButton(
      icon: LucideIcons.share300,
      semanticLabel: 'Share',
      onPressed: () {},
    ),
  ),
);

/// Two actions, which needs `trailSlotWidth` widened to fit the group — and
/// that shifts the title off center, which is the trade-off to look at here.
@widgetbook.UseCase(name: 'Two trailing actions', type: Topbar)
Widget topbarTwoTrailingActions(BuildContext context) => _page(
  Topbar(
    lead: NavigateBackButton(onPressed: () {}),
    middle: Text('Payment', style: context.bitcrText.textMdMedium()),
    trailSlotWidth: TopbarActionGroup.widthFor(2),
    trail: TopbarActionGroup(
      children: [
        TopbarActionButton(
          icon: LucideIcons.share300,
          showChip: false,
          semanticLabel: 'Share',
          onPressed: () {},
        ),
        TopbarActionButton(
          icon: LucideIcons.ellipsis,
          showChip: false,
          semanticLabel: 'More',
          onPressed: () {},
        ),
      ],
    ),
  ),
);

/// Anything can go in the middle slot — the bar has no idea what an identity
/// chip is, which is what keeps it reusable across apps.
@widgetbook.UseCase(name: 'Custom middle', type: Topbar)
Widget topbarCustomMiddle(BuildContext context) {
  final colors = BitcrColors.of(context);

  return _page(
    Topbar(
      lead: NavigateBackButton(onPressed: () {}),
      middle: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.elevation200,
          border: Border.all(color: colors.divider50),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Avatar(name: 'Wallet 3', size: AvatarSize.sm),
            Text('Wallet 3', style: context.bitcrText.textSmMedium()),
            Icon(
              LucideIcons.chevronDown300,
              size: 16,
              color: colors.text300,
            ),
          ],
        ),
      ),
    ),
  );
}

/// The background illustration bleeds to the screen edges past the page
/// padding, and gets tinted in dark mode — worth flipping the theme addon on.
@widgetbook.UseCase(name: 'With background', type: Topbar)
Widget topbarWithBackground(BuildContext context) => _page(
  Topbar(
    backgroundAsset: 'assets/images/circle_background.png',
    lead: NavigateBackButton(onPressed: () {}),
    middle: Text('Receive', style: context.bitcrText.textMdMedium()),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: Topbar)
Widget topbarPlayground(BuildContext context) {
  final hasTrail = context.knobs.boolean(
    label: 'Trailing action',
    initialValue: true,
  );

  return _page(
    Topbar(
      backgroundAsset: context.knobs.boolean(label: 'Background')
          ? 'assets/images/circle_background.png'
          : null,
      slotSize: context.knobs.double.slider(
        label: 'Slot size',
        initialValue: 40,
        min: 24,
        max: 64,
      ),
      lead: context.knobs.boolean(label: 'Back button', initialValue: true)
          ? NavigateBackButton(onPressed: () {})
          : null,
      middle: Text(
        context.knobs.string(label: 'Title', initialValue: 'Payment details'),
        style: context.bitcrText.textMdMedium(),
      ),
      trail: hasTrail
          ? TopbarActionButton(
              icon: LucideIcons.ellipsis,
              semanticLabel: 'More',
              onPressed: () {},
            )
          : null,
    ),
  );
}
