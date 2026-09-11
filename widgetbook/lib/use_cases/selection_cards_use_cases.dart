import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:bitcr_ui_widgetbook/use_cases/selection_drawer_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Again, the app's copy — the component only knows the icons are icons.
const _themes = [
  SelectionCardOption(
    value: 'system',
    icon: LucideIcons.settings300,
    label: 'System',
  ),
  SelectionCardOption(value: 'light', icon: LucideIcons.sun300, label: 'Light'),
  SelectionCardOption(value: 'dark', icon: LucideIcons.moon300, label: 'Dark'),
];

/// The theme drawer, which is the reason this component exists: three cards
/// side by side rather than a list.
@widgetbook.UseCase(name: 'In a drawer', type: SelectionCards)
Widget selectionCardsInDrawer(BuildContext context) {
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
      child: SelectionHarness<String>(
        initial: 'system',
        builder: (selected, onSelect) => BottomDrawer(
          title: 'Theme',
          closeSemanticLabel: 'Close',
          child: SelectionCards<String>(
            options: _themes,
            selected: selected,
            onSelect: onSelect,
          ),
        ),
      ),
    ),
  );
}

/// On its own, to check the selected card's heavier border against the resting
/// ones.
@widgetbook.UseCase(name: 'Default', type: SelectionCards)
Widget selectionCardsDefault(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: SelectionHarness<String>(
    initial: 'light',
    builder: (selected, onSelect) => SelectionCards<String>(
      options: _themes,
      selected: selected,
      onSelect: onSelect,
    ),
  ),
);

/// Nothing selected — every card at its resting border, which is what shows
/// while the stored preference loads.
@widgetbook.UseCase(name: 'Nothing selected', type: SelectionCards)
Widget selectionCardsNothingSelected(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: SelectionCards<String>(
    options: _themes,
    selected: null,
    onSelect: (_) {},
  ),
);

@widgetbook.UseCase(name: 'Playground', type: SelectionCards)
Widget selectionCardsPlayground(BuildContext context) {
  final count = context.knobs.int
      .slider(label: 'Cards', initialValue: 3, min: 2, max: 3)
      .toInt();

  return Padding(
    padding: const EdgeInsets.all(24),
    child: SelectionHarness<String>(
      initial: 'system',
      builder: (selected, onSelect) => SelectionCards<String>(
        options: _themes.take(count).toList(),
        selected: selected,
        onSelect: onSelect,
        spacing: context.knobs.double.slider(
          label: 'Spacing',
          initialValue: 16,
          max: 32,
        ),
      ),
    ),
  );
}
