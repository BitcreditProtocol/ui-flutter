import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// One use case per variant, so a reviewer can see the four side by side in
/// the nav tree without touching knobs.
@widgetbook.UseCase(name: 'Primary', type: Button)
Widget buttonPrimary(BuildContext context) =>
    Button(onPressed: () {}, child: const Text('Continue'));

@widgetbook.UseCase(name: 'Secondary', type: Button)
Widget buttonSecondary(BuildContext context) => Button(
  variant: ButtonVariant.secondary,
  onPressed: () {},
  child: const Text('Continue'),
);

@widgetbook.UseCase(name: 'Outline', type: Button)
Widget buttonOutline(BuildContext context) => Button(
  variant: ButtonVariant.outline,
  onPressed: () {},
  child: const Text('Continue'),
);

@widgetbook.UseCase(name: 'Disabled', type: Button)
Widget buttonDisabled(BuildContext context) =>
    const Button(disabled: true, child: Text('Continue'));

/// The three sizes stacked, which is the only way to judge that the padding
/// steps read as a scale.
@widgetbook.UseCase(name: 'Sizes', type: Button)
Widget buttonSizes(BuildContext context) => Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: [
    for (final size in ButtonSize.values)
      Button(buttonSize: size, onPressed: () {}, child: Text(size.name)),
  ],
);

/// How the screens actually use it: a pair of buttons stretched by the parent
/// `Row`, with an icon beside the label. `Button` never sets its own width, so
/// this is the only place the full-width look can be reviewed.
///
/// The right-hand one is disabled, which is the state the pay screen shows
/// until an amount is entered.
@widgetbook.UseCase(name: 'Full width pair', type: Button)
Widget buttonFullWidthPair(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Row(
      spacing: 12,
      children: [
        Expanded(
          child: Button(onPressed: () {}, child: const Text('Send')),
        ),
        Expanded(
          child: Button(
            disabled: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const Text('Show QR'),
                Icon(LucideIcons.nfc300, color: colors.textInactive, size: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: Button)
Widget buttonPlayground(BuildContext context) => Button(
  variant: context.knobs.object.dropdown(
    label: 'Variant',
    options: ButtonVariant.values,
    labelBuilder: (v) => v.name,
  ),
  buttonSize: context.knobs.object.dropdown(
    label: 'Size',
    options: ButtonSize.values,
    labelBuilder: (s) => s.name,
  ),
  disabled: context.knobs.boolean(label: 'Disabled'),
  onPressed: () {},
  child: Text(
    context.knobs.string(label: 'Label', initialValue: 'Continue'),
  ),
);
