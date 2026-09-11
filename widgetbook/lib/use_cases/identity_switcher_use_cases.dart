import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _wallets = [
  IdentityOption(value: 'w1', name: 'Wallet 1'),
  IdentityOption(value: 'w3', name: 'Wallet 3'),
  IdentityOption(value: 'w2', name: 'Wallet 2'),
];

/// In a topbar, which is the only place the switcher's menu lands where it
/// should — the overlay hangs from below the bar.
Widget _inTopbar(BuildContext context, Widget middle) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  child: Align(
    alignment: Alignment.topCenter,
    child: Topbar(lead: NavigateBackButton(onPressed: () {}), middle: middle),
  ),
);

/// Holds the selected identity the way the app's provider would.
class _SwitcherHarness extends StatefulWidget {
  const _SwitcherHarness({
    this.initial = 'w3',
    this.loading = false,
    this.withFooter = true,
    this.options = _wallets,
  });

  final String initial;
  final bool loading;
  final bool withFooter;
  final List<IdentityOption<String>> options;

  @override
  State<_SwitcherHarness> createState() => _SwitcherHarnessState();
}

class _SwitcherHarnessState extends State<_SwitcherHarness> {
  late String _selected = widget.initial;

  String get _name =>
      widget.options
          .where((o) => o.value == _selected)
          .map((o) => o.name)
          .firstOrNull ??
      'Wallet';

  @override
  Widget build(BuildContext context) => _inTopbar(
    context,
    IdentitySwitcher<String>(
      name: _name,
      options: widget.options,
      selected: _selected,
      loading: widget.loading,
      footerLabel: widget.withFooter ? 'Manage wallets' : null,
      footerIcon: widget.withFooter ? LucideIcons.settings300 : null,
      onFooterTap: widget.withFooter ? () {} : null,
      onSelect: (next) => setState(() => _selected = next),
    ),
  );
}

/// Tap the chip to drop the menu, pick a wallet, or tap outside to dismiss.
@widgetbook.UseCase(name: 'Switchable', type: IdentitySwitcher)
Widget identitySwitcherDefault(BuildContext context) =>
    const _SwitcherHarness();

/// While the app is still resolving the list.
@widgetbook.UseCase(name: 'Loading options', type: IdentitySwitcher)
Widget identitySwitcherLoading(BuildContext context) =>
    const _SwitcherHarness(loading: true);

/// No footer: omit the three footer arguments and the action row and its
/// divider disappear.
@widgetbook.UseCase(name: 'Without footer action', type: IdentitySwitcher)
Widget identitySwitcherNoFooter(BuildContext context) =>
    const _SwitcherHarness(withFooter: false);

/// More entries than fit: the menu caps at 360px and scrolls, with the footer
/// staying put underneath.
@widgetbook.UseCase(name: 'Long list', type: IdentitySwitcher)
Widget identitySwitcherLongList(BuildContext context) => _SwitcherHarness(
  initial: 'w0',
  options: [
    for (var i = 0; i < 12; i++)
      IdentityOption(value: 'w$i', name: 'Wallet ${i + 1}'),
  ],
);

/// The chip on its own — no chevron, no tap. The wallet uses this mid-payment,
/// where switching wouldn't make sense.
@widgetbook.UseCase(name: 'Not switchable', type: IdentityChip)
Widget identityChipNotSwitchable(BuildContext context) =>
    _inTopbar(context, const IdentityChip(name: 'Wallet 3'));

/// Closed and open borders side by side — open darkens the border and flips
/// the chevron.
@widgetbook.UseCase(name: 'Closed and open', type: IdentityChip)
Widget identityChipStates(BuildContext context) => Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 16,
    children: [
      IdentityChip(name: 'Wallet 3', showChevron: true, onTap: () {}),
      IdentityChip(
        name: 'Wallet 3',
        showChevron: true,
        open: true,
        onTap: () {},
      ),
    ],
  ),
);

/// A name longer than the chip's 160px cap, so it ellipsises rather than
/// pushing the chevron out of the topbar.
@widgetbook.UseCase(name: 'Long name', type: IdentityChip)
Widget identityChipLongName(BuildContext context) => _inTopbar(
  context,
  IdentityChip(
    name: 'Bitcredit Company Treasury Wallet',
    showChevron: true,
    onTap: () {},
  ),
);

@widgetbook.UseCase(name: 'Playground', type: IdentityChip)
Widget identityChipPlayground(BuildContext context) => _inTopbar(
  context,
  IdentityChip(
    name: context.knobs.string(label: 'Name', initialValue: 'Wallet 3'),
    imageUrl: context.knobs.stringOrNull(label: 'Image URL'),
    showChevron: context.knobs.boolean(label: 'Chevron', initialValue: true),
    open: context.knobs.boolean(label: 'Open'),
    onTap: () {},
  ),
);
