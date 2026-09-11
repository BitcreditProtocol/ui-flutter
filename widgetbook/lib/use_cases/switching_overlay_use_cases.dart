import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// The copy below stands in for the app's translations — the component has no
// strings of its own, so every use case has to supply them.

@widgetbook.UseCase(name: 'Switching wallet', type: SwitchingOverlay)
Widget switchingOverlayWallet(BuildContext context) => const SwitchingOverlay(
  title: 'Switching wallet',
  subtitle: 'This only takes a moment.',
);

@widgetbook.UseCase(name: 'Long copy', type: SwitchingOverlay)
Widget switchingOverlayLongCopy(BuildContext context) => const SwitchingOverlay(
  title: 'Switching to the Bitcredit test network',
  subtitle:
      'Your wallet is being reloaded against the new network. Balances and '
      'payment history will reappear once this finishes.',
);

@widgetbook.UseCase(name: 'Playground', type: SwitchingOverlay)
Widget switchingOverlayPlayground(BuildContext context) => SwitchingOverlay(
  title: context.knobs.string(label: 'Title', initialValue: 'Switching wallet'),
  subtitle: context.knobs.string(
    label: 'Subtitle',
    initialValue: 'This only takes a moment.',
  ),
);

/// The same state inside an existing layout rather than as a whole screen.
@widgetbook.UseCase(name: 'Inside a card', type: SwitchingStatusContent)
Widget switchingStatusContentInCard(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.elevation100,
        border: Border.all(color: colors.divider50),
        borderRadius: BorderRadius.circular(BitcrRadius.lg),
      ),
      child: const SwitchingStatusContent(
        title: 'Switching network',
        subtitle: 'Reconnecting to the mint.',
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: SpinningLoader)
Widget spinningLoaderDefault(BuildContext context) => const Center(
  child: SpinningLoader(),
);
