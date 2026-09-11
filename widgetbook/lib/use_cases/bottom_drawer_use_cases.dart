import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:bitcr_ui_widgetbook/use_cases/app_text_field_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Renders the drawer body in place, which is how you review its layout — the
/// real thing is inside a modal sheet and only reachable by opening it.
Widget _inSheet(BuildContext context, Widget drawer) {
  final colors = BitcrColors.of(context);

  return Align(
    alignment: Alignment.bottomCenter,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.elevation50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(BitcrRadius.xxl),
        ),
      ),
      child: drawer,
    ),
  );
}

@widgetbook.UseCase(name: 'Short content', type: BottomDrawer)
Widget bottomDrawerShort(BuildContext context) => _inSheet(
  context,
  BottomDrawer(
    title: 'Remove wallet',
    closeSemanticLabel: 'Close',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(
          'This removes the wallet from this device. Your recovery phrase '
          'still restores it.',
          textAlign: TextAlign.center,
          style: context.bitcrText.textSmRegular(
            color: BitcrColors.of(context).text200,
          ),
        ),
        Button(onPressed: () {}, child: const Text('Remove')),
      ],
    ),
  ),
);

/// A trailing action in the topbar slot, beside the close button.
@widgetbook.UseCase(name: 'With trailing action', type: BottomDrawer)
Widget bottomDrawerWithTrail(BuildContext context) => _inSheet(
  context,
  BottomDrawer(
    title: 'Payment note',
    closeSemanticLabel: 'Close',
    trail: TopbarActionButton(
      icon: LucideIcons.check300,
      semanticLabel: 'Save',
      onPressed: () {},
    ),
    child: FieldHarness(
      initialText: 'Dinner, split three ways',
      builder: (context, controller) => AppTextField(
        controller: controller,
        label: 'Note',
        clearSemanticLabel: 'Clear',
      ),
    ),
  ),
);

/// Long content: the body is `Flexible`, so it should scroll inside the sheet
/// rather than push the topbar off.
@widgetbook.UseCase(name: 'Scrolling content', type: BottomDrawer)
Widget bottomDrawerScrolling(BuildContext context) => _inSheet(
  context,
  BottomDrawer(
    title: 'Select currency',
    closeSemanticLabel: 'Close',
    child: SingleChildScrollView(
      child: Column(
        children: [
          for (final currency in const [
            'USD',
            'EUR',
            'GBP',
            'CHF',
            'SEK',
            'NOK',
            'DKK',
            'JPY',
            'AUD',
            'CAD',
            'NZD',
            'PLN',
          ])
            ListTile(
              title: Text(currency, style: context.bitcrText.textMdRegular()),
              onTap: () {},
            ),
        ],
      ),
    ),
  ),
);

/// Opens the real modal sheet through [showBottomDrawer], so the entrance
/// animation, the scrim and the rounded top edge are all the actual ones.
@widgetbook.UseCase(name: 'Open as a modal sheet', type: BottomDrawer)
Widget bottomDrawerModal(BuildContext context) => Center(
  child: Button(
    onPressed: () => showBottomDrawer<void>(
      context,
      builder: (_) => BottomDrawer(
        title: 'Remove wallet',
        closeSemanticLabel: 'Close',
        child: Button(
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    ),
    child: const Text('Open drawer'),
  ),
);
