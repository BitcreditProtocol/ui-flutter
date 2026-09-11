import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Title only', type: ScreenHeader)
Widget screenHeaderTitleOnly(BuildContext context) => const Padding(
  padding: EdgeInsets.symmetric(horizontal: 24),
  child: ScreenHeader(title: 'Settings'),
);

@widgetbook.UseCase(name: 'With trailing action', type: ScreenHeader)
Widget screenHeaderWithTrailing(BuildContext context) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: ScreenHeader(
    title: 'Payments',
    trailing: Button(
      buttonSize: ButtonSize.small,
      variant: ButtonVariant.outline,
      onPressed: () {},
      child: const Text('Filter'),
    ),
  ),
);

/// The ellipsis case: a title long enough to collide with the trailing slot,
/// which is where the `Flexible` earns its place.
@widgetbook.UseCase(name: 'Overflowing title', type: ScreenHeader)
Widget screenHeaderOverflowing(BuildContext context) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: ScreenHeader(
    title: 'A screen title far too long to fit on one line',
    trailing: Icon(LucideIcons.ellipsis, color: BitcrColors.of(context).text300),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: ScreenHeader)
Widget screenHeaderPlayground(BuildContext context) {
  final hasTrailing = context.knobs.boolean(
    label: 'Show trailing action',
    initialValue: true,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: ScreenHeader(
      title: context.knobs.string(label: 'Title', initialValue: 'Settings'),
      trailing: hasTrailing
          ? Icon(
              LucideIcons.ellipsis,
              color: BitcrColors.of(context).text300,
            )
          : null,
    ),
  );
}
