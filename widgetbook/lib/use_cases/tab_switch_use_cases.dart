import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Tap the other tab to slide the pill; the selected tab shows its chevron.
@widgetbook.UseCase(name: 'Default', type: TabSwitch)
Widget tabSwitchDefault(BuildContext context) => const _TabSwitchDemo();

class _TabSwitchDemo extends StatefulWidget {
  const _TabSwitchDemo();

  @override
  State<_TabSwitchDemo> createState() => _TabSwitchDemoState();
}

class _TabSwitchDemoState extends State<_TabSwitchDemo> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: Alignment.topCenter,
      child: TabSwitch(
        items: const [
          TabSwitchItem(label: 'History', showChevron: true),
          TabSwitchItem(label: 'Requests', showChevron: true),
        ],
        selectedIndex: _selected,
        onTap: (index) => setState(() => _selected = index),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: FilterBadge)
Widget filterBadgeDefault(BuildContext context) => Padding(
  padding: const EdgeInsets.all(20),
  child: Align(
    alignment: Alignment.topLeft,
    child: FilterBadge(label: 'Unpaid', onRemove: () {}),
  ),
);
