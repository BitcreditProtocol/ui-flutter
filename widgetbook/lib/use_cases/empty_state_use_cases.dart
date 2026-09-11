import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// The three shipped variants, as the list screens use them. Static use cases
/// like these are what you want in review: they show the real copy, and a
/// reviewer can't accidentally look at a state that doesn't exist.
@widgetbook.UseCase(name: 'No requests', type: EmptyState)
Widget emptyStateNoRequests(BuildContext context) => const EmptyState(
  asset: 'assets/images/no_requests.png',
  title: 'No requests yet',
  subtitle: 'Requests you send or receive will show up here.',
);

@widgetbook.UseCase(name: 'No notifications', type: EmptyState)
Widget emptyStateNoNotifications(BuildContext context) => const EmptyState(
  asset: 'assets/images/no_notifications.png',
  title: 'No notifications yet',
  subtitle: "We'll let you know when something needs your attention.",
);

@widgetbook.UseCase(name: 'No payments', type: EmptyState)
Widget emptyStateNoPayments(BuildContext context) => EmptyState(
  asset: 'assets/images/no_payments.png',
  title: 'No payments yet',
  subtitle: 'Your payments will be listed here once you make one.',
  buttonLabel: 'Make a payment',
  onTap: () {},
);

/// The knobbed variant — this is the one to reach for when you're building or
/// changing the component and want to poke at its edges (long copy, missing
/// button, a large top inset) without editing code.
@widgetbook.UseCase(name: 'Playground', type: EmptyState)
Widget emptyStatePlayground(BuildContext context) {
  final hasButton = context.knobs.boolean(
    label: 'Show action button',
    initialValue: true,
  );

  return EmptyState(
    asset: context.knobs.object.dropdown(
      label: 'Illustration',
      options: const [
        'assets/images/no_requests.png',
        'assets/images/no_notifications.png',
        'assets/images/no_payments.png',
      ],
      labelBuilder: (path) => path.split('/').last,
    ),
    title: context.knobs.string(
      label: 'Title',
      initialValue: 'No requests yet',
    ),
    subtitle: context.knobs.string(
      label: 'Subtitle',
      initialValue: 'Requests you send or receive will show up here.',
    ),
    buttonLabel: hasButton
        ? context.knobs.string(label: 'Button label', initialValue: 'Refresh')
        : null,
    onTap: hasButton ? () {} : null,
    topInset: context.knobs.double.slider(
      label: 'Top inset',
      initialValue: 0,
      max: 120,
    ),
  );
}
