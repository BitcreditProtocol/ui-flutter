import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: NavigateBackButton)
Widget navigateBackButtonDefault(BuildContext context) =>
    NavigateBackButton(onPressed: () {});

/// The inverted pair, on the dark surface it's meant for — judging `isDark`
/// against the light page background tells you nothing.
@widgetbook.UseCase(name: 'On a dark header', type: NavigateBackButton)
Widget navigateBackButtonDark(BuildContext context) => ColoredBox(
  color: BitcrColors.of(context).text300,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: NavigateBackButton(isDark: true, onPressed: () {}),
  ),
);

/// Inside a slot narrower than 40px: it should overflow the slot and stay
/// round, not squash into an oval.
@widgetbook.UseCase(name: 'In a too-small slot', type: NavigateBackButton)
Widget navigateBackButtonTightSlot(BuildContext context) => Center(
  child: SizedBox(
    width: 24,
    height: 24,
    child: NavigateBackButton(onPressed: () {}),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: NavigateBackButton)
Widget navigateBackButtonPlayground(BuildContext context) {
  final isDark = context.knobs.boolean(label: 'Dark');
  final colors = BitcrColors.of(context);

  return ColoredBox(
    color: isDark ? colors.text300 : colors.elevation50,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: NavigateBackButton(
        isDark: isDark,
        onPressed: context.knobs.boolean(label: 'Enabled', initialValue: true)
            ? () {}
            : null,
      ),
    ),
  );
}
