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
  buttonIcon: LucideIcons.plus,
  onTap: () {},
);

/// The case the anchor exists for, and the one that is invisible without a
/// header above it: two screens whose headers are different heights, whose
/// illustrations still line up. Drag the header knob and watch them stay level
/// with each other while the space below them changes.
@widgetbook.UseCase(name: 'Anchored under a header', type: EmptyState)
Widget emptyStateAnchored(BuildContext context) {
  final extraHeader = context.knobs.double.slider(
    label: 'Extra header height',
    initialValue: 0,
    max: 160,
  );

  return LayoutBuilder(
    builder: (context, constraints) => EmptyStateAnchor(
      bodyHeight: constraints.maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ScreenHeader(title: 'Payments'),
          ),
          // Stands in for a search field or a row of filter badges appearing.
          SizedBox(height: extraHeader),
          const Expanded(
            child: EmptyState(
              asset: 'assets/images/no_payments.png',
              title: 'No payments yet',
              subtitle: 'Your payments will be listed here once you make one.',
            ),
          ),
        ],
      ),
    ),
  );
}

/// The knobbed variant — this is the one to reach for when you're building or
/// changing the component and want to poke at its edges (long copy, a missing
/// button, an illustration pushed down) without editing code.
///
/// It has no anchor above it, so it centres. That is the fallback path.
@widgetbook.UseCase(name: 'Playground', type: EmptyState)
Widget emptyStatePlayground(BuildContext context) {
  final hasButton = context.knobs.boolean(
    label: 'Show action button',
    initialValue: true,
  );

  return EmptyState(
    asset: context.knobs.object.dropdown<String>(
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
    buttonIcon: hasButton && context.knobs.boolean(label: 'Button icon')
        ? LucideIcons.refreshCw
        : null,
    onTap: hasButton ? () {} : null,
  );
}
