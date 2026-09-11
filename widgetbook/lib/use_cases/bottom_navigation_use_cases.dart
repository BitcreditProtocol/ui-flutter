import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// The labels stand in for the app's translations, and the badges for whatever
// state it decided needs attention.

const _walletTabs = [
  NavItem(label: 'Home', icon: LucideIcons.house300),
  NavItem(label: 'Contacts', icon: LucideIcons.contactRound300),
  NavItem(label: 'Payments', icon: LucideIcons.arrowRightLeft300),
  NavItem(label: 'Notifications', icon: LucideIcons.bell300),
  NavItem(label: 'Settings', icon: LucideIcons.settings300),
];

/// Pinned to the bottom, because that's the only place its safe-area handling
/// and top border make sense.
Widget _atBottom(Widget child) =>
    Align(alignment: Alignment.bottomCenter, child: child);

/// Tracks the selected tab so tapping actually moves the highlight.
class _NavHarness extends StatefulWidget {
  const _NavHarness({required this.items});

  final List<NavItem> items;

  @override
  State<_NavHarness> createState() => _NavHarnessState();
}

class _NavHarnessState extends State<_NavHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => _atBottom(
    BottomNavigation(
      items: widget.items,
      currentIndex: _index,
      onTap: (next) => setState(() => _index = next),
    ),
  );
}

/// The wallet's five tabs.
@widgetbook.UseCase(name: 'Five tabs', type: BottomNavigation)
Widget bottomNavigationFiveTabs(BuildContext context) =>
    const _NavHarness(items: _walletTabs);

/// Badges on two destinations — unread notifications and an unfinished setup
/// step. The dot is the same [BackupDot] used elsewhere.
@widgetbook.UseCase(name: 'With badges', type: BottomNavigation)
Widget bottomNavigationWithBadges(BuildContext context) => const _NavHarness(
  items: [
    NavItem(label: 'Home', icon: LucideIcons.house300),
    NavItem(label: 'Contacts', icon: LucideIcons.contactRound300),
    NavItem(label: 'Payments', icon: LucideIcons.arrowRightLeft300),
    NavItem(
      label: 'Notifications',
      icon: LucideIcons.bell300,
      showBadge: true,
    ),
    NavItem(label: 'Settings', icon: LucideIcons.settings300, showBadge: true),
  ],
);

/// `currentIndex: -1` — nothing active. Full-screen flows on top of the shell
/// show the bar this way.
@widgetbook.UseCase(name: 'No active tab', type: BottomNavigation)
Widget bottomNavigationNoActive(BuildContext context) => _atBottom(
  BottomNavigation(
    items: _walletTabs,
    currentIndex: -1,
    onTap: (_) {},
  ),
);

/// Three tabs, to check the labels don't look stranded when the row is less
/// crowded.
@widgetbook.UseCase(name: 'Three tabs', type: BottomNavigation)
Widget bottomNavigationThreeTabs(BuildContext context) => const _NavHarness(
  items: [
    NavItem(label: 'Balances', icon: LucideIcons.coins300),
    NavItem(label: 'Quotes', icon: LucideIcons.arrowRightLeft300),
    NavItem(label: 'Settings', icon: LucideIcons.settings300),
  ],
);

/// Long labels at the narrowest viewport: each one is capped to a single
/// ellipsised line, which is why the label style sits at 10px.
@widgetbook.UseCase(name: 'Long labels', type: BottomNavigation)
Widget bottomNavigationLongLabels(BuildContext context) => const _NavHarness(
  items: [
    NavItem(label: 'Home', icon: LucideIcons.house300),
    NavItem(label: 'Contacts', icon: LucideIcons.contactRound300),
    NavItem(label: 'Zahlungsverkehr', icon: LucideIcons.arrowRightLeft300),
    NavItem(label: 'Benachrichtigungen', icon: LucideIcons.bell300),
    NavItem(label: 'Einstellungen', icon: LucideIcons.settings300),
  ],
);

@widgetbook.UseCase(name: 'Playground', type: BottomNavigation)
Widget bottomNavigationPlayground(BuildContext context) {
  final count = context.knobs.int
      .slider(label: 'Tabs', initialValue: 5, min: 2, max: 5)
      .toInt();
  final badges = context.knobs.boolean(label: 'Badges');

  return _NavHarness(
    items: [
      for (final item in _walletTabs.take(count))
        NavItem(label: item.label, icon: item.icon, showBadge: badges),
    ],
  );
}
