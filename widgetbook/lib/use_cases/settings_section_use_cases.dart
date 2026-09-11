import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// All labels here stand in for the app's translations, and all values for the
// preferences it has resolved.

Widget _page(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: child,
);

/// A row with its current setting on the right — the shape the localisation
/// screen uses for every entry.
@widgetbook.UseCase(name: 'With a value', type: SettingsSectionItem)
Widget settingsSectionItemWithValue(BuildContext context) => _page(
  SettingsSectionItem(
    icon: LucideIcons.languages300,
    label: 'Language',
    value: 'EN',
    onTap: () {},
  ),
);

@widgetbook.UseCase(name: 'Label only', type: SettingsSectionItem)
Widget settingsSectionItemLabelOnly(BuildContext context) => _page(
  SettingsSectionItem(
    icon: LucideIcons.info300,
    label: 'About',
    onTap: () {},
  ),
);

/// The dot marks a setting that needs attention — an unbacked wallet, a PIN
/// that was never set up.
@widgetbook.UseCase(name: 'Needs attention', type: SettingsSectionItem)
Widget settingsSectionItemWithDot(BuildContext context) => _page(
  SettingsSectionItem(
    icon: LucideIcons.walletMinimal300,
    label: 'Wallets',
    showDot: true,
    onTap: () {},
  ),
);

/// Disabled dims the label and the chevron and drops the tap; `color`
/// overrides both for a destructive row.
@widgetbook.UseCase(name: 'Disabled and destructive', type: SettingsSectionItem)
Widget settingsSectionItemStates(BuildContext context) => _page(
  Column(
    spacing: 12,
    children: [
      const SettingsSectionItem(
        icon: LucideIcons.shieldCheck300,
        label: 'Security',
        value: 'Unavailable',
        enabled: false,
      ),
      SettingsSectionItem(
        icon: LucideIcons.trash2300,
        label: 'Reset app',
        color: BitcrColors.of(context).signalError,
        showChevron: false,
        onTap: () {},
      ),
    ],
  ),
);

/// `leading` replaces the bordered icon tile, and `trailing` takes a real
/// widget where [SettingsSectionItem.value] would only take text — here a
/// switch and a spinner for a setting that's still loading.
@widgetbook.UseCase(name: 'Custom leading and trailing', type: SettingsSectionItem)
Widget settingsSectionItemCustomSlots(BuildContext context) => _page(
  Column(
    spacing: 12,
    children: [
      SettingsSectionItem(
        leading: const Avatar(name: 'Wallet 1'),
        label: 'Wallet 1',
        value: '12 500 sat',
        onTap: () {},
      ),
      SettingsSectionItem(
        icon: LucideIcons.bell300,
        label: 'Notifications',
        showChevron: false,
        trailing: SettingsSwitch(value: true, onChanged: (_) {}),
      ),
      SettingsSectionItem(
        icon: LucideIcons.coins300,
        label: 'Currency',
        trailing: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        onTap: () {},
      ),
    ],
  ),
);

/// Grouped rows: the card draws one surface, the rows pass `bordered: false`,
/// and the divider is inset to start under the labels.
@widgetbook.UseCase(name: 'Grouped rows', type: SettingsSectionCard)
Widget settingsSectionCardGrouped(BuildContext context) => _page(
  SettingsSectionCard(
    children: [
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.earth300,
        label: 'Localisation',
        onTap: () {},
      ),
      const SettingsSectionDivider(),
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.walletMinimal300,
        label: 'Wallets',
        showDot: true,
        onTap: () {},
      ),
      const SettingsSectionDivider(),
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.shieldCheck300,
        label: 'Security',
        onTap: () {},
      ),
    ],
  ),
);

/// The localisation screen: four rows, each showing the preference it opens a
/// [SelectionDrawer] for.
@widgetbook.UseCase(name: 'Localisation screen', type: SettingsSectionCard)
Widget settingsSectionCardLocalisation(BuildContext context) => _page(
  SettingsSectionCard(
    children: [
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.languages300,
        label: 'Language',
        value: 'EN',
        onTap: () {},
      ),
      const SettingsSectionDivider(),
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.coins300,
        label: 'Currency',
        value: 'EUR',
        onTap: () {},
      ),
      const SettingsSectionDivider(),
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.calendarDays300,
        label: 'Date format',
        value: '10/09/2026',
        onTap: () {},
      ),
      const SettingsSectionDivider(),
      SettingsSectionItem(
        bordered: false,
        icon: LucideIcons.hash300,
        label: 'Decimal separator',
        value: '1,000.00',
        onTap: () {},
      ),
    ],
  ),
);

/// The whole settings menu: a card of grouped rows, then a standalone row,
/// each block spaced 24px apart.
@widgetbook.UseCase(name: 'Full settings menu', type: SettingsSectionList)
Widget settingsSectionListFull(BuildContext context) => _page(
  SettingsSectionList(
    children: [
      SettingsSectionCard(
        children: [
          SettingsSectionItem(
            bordered: false,
            icon: LucideIcons.earth300,
            label: 'Localisation',
            onTap: () {},
          ),
          const SettingsSectionDivider(),
          SettingsSectionItem(
            bordered: false,
            icon: LucideIcons.walletMinimal300,
            label: 'Wallets',
            showDot: true,
            onTap: () {},
          ),
          const SettingsSectionDivider(),
          SettingsSectionItem(
            bordered: false,
            icon: LucideIcons.shieldCheck300,
            label: 'Security',
            showDot: true,
            onTap: () {},
          ),
        ],
      ),
      SettingsSectionItem(
        icon: LucideIcons.info300,
        label: 'About',
        onTap: () {},
      ),
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: SettingsSectionItem)
Widget settingsSectionItemPlayground(BuildContext context) {
  final grouped = context.knobs.boolean(label: 'Inside a card');
  final item = SettingsSectionItem(
    bordered: !grouped,
    icon: LucideIcons.languages300,
    label: context.knobs.string(label: 'Label', initialValue: 'Language'),
    value: context.knobs.stringOrNull(label: 'Value'),
    enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    showDot: context.knobs.boolean(label: 'Attention dot'),
    showChevron: context.knobs.boolean(label: 'Chevron', initialValue: true),
    onTap: () {},
  );

  return _page(grouped ? SettingsSectionCard(children: [item]) : item);
}
