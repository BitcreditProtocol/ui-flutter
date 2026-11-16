import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: StepIndicator)
Widget stepIndicatorPlayground(BuildContext context) {
  final steps = context.knobs.int.slider(
    label: 'Steps',
    initialValue: 4,
    min: 1,
    max: 8,
  );
  final current = context.knobs.int.slider(
    label: 'Current',
    initialValue: 1,
    min: 0,
    max: 7,
  );

  return Center(
    child: StepIndicator(
      steps: steps,
      current: current,
      semanticLabel: 'Step ${current + 1} of $steps',
    ),
  );
}

class _Dots extends StatefulWidget {
  const _Dots({required this.steps});

  final int steps;

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> {
  var _current = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: DotIndicator(
      steps: widget.steps,
      current: _current.clamp(0, widget.steps - 1),
      onTap: (index) => setState(() => _current = index),
      semanticLabelBuilder: (index) => 'Go to page ${index + 1}',
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: DotIndicator)
Widget dotIndicatorPlayground(BuildContext context) => _Dots(
  steps: context.knobs.int.slider(
    label: 'Steps',
    initialValue: 3,
    min: 1,
    max: 8,
  ),
);

@widgetbook.UseCase(name: 'States', type: NetworkTag)
Widget networkTagStates(BuildContext context) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      const NetworkTag(label: 'Mainnet'),
      const NetworkTag(label: 'Mainnet. Offline', isOffline: true),
      NetworkTag(
        label: 'Testnet 4. Coins have no value',
        onTap: () {},
        semanticHint: 'Switch network',
      ),
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: NetworkTag)
Widget networkTagPlayground(BuildContext context) => Center(
  child: NetworkTag(
    label: context.knobs.string(label: 'Label', initialValue: 'Mainnet'),
    isOffline: context.knobs.boolean(label: 'Offline'),
    onTap: context.knobs.boolean(label: 'Switchable') ? () {} : null,
  ),
);

@widgetbook.UseCase(name: 'States', type: EmailBadge)
Widget emailBadgeStates(BuildContext context) => const Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      EmailBadge(
        isVerified: true,
        verifiedLabel: 'Email verified',
        notVerifiedLabel: 'Email not verified',
      ),
      EmailBadge(
        isVerified: false,
        verifiedLabel: 'Email verified',
        notVerifiedLabel: 'Email not verified',
      ),
    ],
  ),
);
