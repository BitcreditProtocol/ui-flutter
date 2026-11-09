import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Next to a label', type: FieldInfoButton)
Widget fieldInfoButtonDefault(BuildContext context) => Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [
      Text(
        'Invoice',
        style: context.bitcrText.textSmMedium(
          color: BitcrColors.of(context).text300,
        ),
      ),
      FieldInfoButton(
        message: context.knobs.string(
          label: 'Message',
          initialValue: 'PDF, PNG or JPG, up to 10 MB.',
        ),
      ),
    ],
  ),
);

@widgetbook.UseCase(name: 'Outline and small styles', type: Button)
Widget buttonHelperStyles(BuildContext context) => Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      Button(
        variant: ButtonVariant.outline,
        onPressed: () {},
        child: const Text('Outline (default border)'),
      ),
      Button(
        variant: ButtonVariant.outline,
        style: outlineButtonStyle(context),
        onPressed: () {},
        child: const Text('Outline with outlineButtonStyle'),
      ),
      FilledButton(
        style: smallButtonStyle,
        onPressed: () {},
        child: const Text('Filled with smallButtonStyle'),
      ),
      OutlinedButton(
        style: smallButtonStyle,
        onPressed: () {},
        child: const Text('Outlined with smallButtonStyle'),
      ),
    ],
  ),
);

@widgetbook.UseCase(name: 'Around an empty state', type: HuggingOutlinedButtons)
Widget huggingOutlinedButtonsDefault(BuildContext context) {
  final theme = Theme.of(context);
  final hug = context.knobs.boolean(label: 'Hug', initialValue: true);

  final emptyState = EmptyState(
    title: 'No contacts yet',
    subtitle: 'Add a contact to send them bills.',
    buttonLabel: 'Add contact',
    buttonIcon: LucideIcons200.plus,
    onTap: () {},
  );

  return Theme(
    data: theme.copyWith(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      ),
    ),
    child: Builder(
      builder: (context) => Center(
        child: hug ? HuggingOutlinedButtons(child: emptyState) : emptyState,
      ),
    ),
  );
}
