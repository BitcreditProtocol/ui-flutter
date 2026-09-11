import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TopbarActionButton)
Widget topbarActionButtonDefault(BuildContext context) => TopbarActionButton(
  icon: LucideIcons.share300,
  semanticLabel: 'Share details',
  onPressed: () {},
);

@widgetbook.UseCase(name: 'Loading', type: TopbarActionButton)
Widget topbarActionButtonLoading(BuildContext context) => const
    TopbarActionButton(
      icon: LucideIcons.share300,
      semanticLabel: 'Share details',
      isLoading: true,
    );

/// Next to [NavigateBackButton] — they're meant to be the same 40px circle, so
/// any drift between them shows up here.
@widgetbook.UseCase(name: 'Beside the back button', type: TopbarActionButton)
Widget topbarActionButtonBesideBack(BuildContext context) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    NavigateBackButton(onPressed: () {}),
    TopbarActionButton(
      icon: LucideIcons.ellipsis,
      semanticLabel: 'More',
      onPressed: () {},
    ),
  ],
);

@widgetbook.UseCase(name: 'Playground', type: TopbarActionButton)
Widget topbarActionButtonPlayground(BuildContext context) =>
    TopbarActionButton(
      icon: context.knobs.object
          .dropdown(
            label: 'Icon',
            options: const [
              ('share', LucideIcons.share300),
              ('ellipsis', LucideIcons.ellipsis),
              ('x', LucideIcons.x),
              ('search', LucideIcons.search),
            ],
            labelBuilder: (option) => option.$1,
          )
          .$2,
      semanticLabel: context.knobs.string(
        label: 'Semantic label',
        initialValue: 'Share details',
      ),
      tooltip: context.knobs.stringOrNull(label: 'Tooltip'),
      isLoading: context.knobs.boolean(label: 'Loading'),
      showChip: context.knobs.boolean(label: 'Show chip', initialValue: true),
      onPressed: () {},
    );

/// The grouped form: the chip is drawn once around the whole row, so the
/// buttons inside it turn theirs off.
@widgetbook.UseCase(name: 'Two actions', type: TopbarActionGroup)
Widget topbarActionGroupTwo(BuildContext context) => TopbarActionGroup(
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
);
