import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SuccessLayout)
Widget successLayoutDefault(BuildContext context) {
  final hasSecondary = context.knobs.boolean(
    label: 'Secondary button',
    initialValue: true,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SuccessLayout(
      title: context.knobs.string(
        label: 'Title',
        initialValue: 'Identity created',
      ),
      description: context.knobs.string(
        label: 'Description',
        initialValue: 'You can now issue and receive bills.',
      ),
      illustration: Image.asset('assets/images/success-illustration.png'),
      primaryLabel: 'Finish',
      onPrimary: () {},
      secondaryLabel: hasSecondary ? 'Share identity' : null,
      secondaryIcon: hasSecondary ? LucideIcons200.scanQrCode : null,
      onSecondary: hasSecondary ? () {} : null,
    ),
  );
}

@widgetbook.UseCase(name: 'With retry', type: AppErrorView)
Widget appErrorViewWithRetry(BuildContext context) => AppErrorView(
  message: context.knobs.string(
    label: 'Message',
    initialValue: 'Could not load your bills.',
  ),
  retryLabel: 'Try again',
  onRetry: () => Future<void>.delayed(const Duration(seconds: 2)),
);

@widgetbook.UseCase(name: 'With details', type: AppErrorView)
Widget appErrorViewWithDetails(BuildContext context) => AppErrorView(
  message: 'Could not load your bills.',
  details: Text(
    context.knobs.string(
      label: 'Details',
      initialValue: 'The node did not answer in time.',
    ),
    textAlign: TextAlign.center,
    style: context.bitcrText.textSmRegular(
      color: BitcrColors.of(context).text200,
    ),
  ),
  retryLabel: 'Try again',
  onRetry: () => Future<void>.delayed(const Duration(seconds: 2)),
);

@widgetbook.UseCase(name: 'Without retry', type: AppErrorView)
Widget appErrorViewWithoutRetry(BuildContext context) =>
    const AppErrorView(message: 'Could not load your bills.');

@widgetbook.UseCase(name: 'Forward and back', type: StepTransition)
Widget stepTransitionDefault(BuildContext context) => const _StepDemo();

class _StepDemo extends StatefulWidget {
  const _StepDemo();

  @override
  State<_StepDemo> createState() => _StepDemoState();
}

class _StepDemoState extends State<_StepDemo> {
  var _step = 0;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Column(
      children: [
        Expanded(
          child: StepTransition(
            step: _step,
            child: ColoredBox(
              color: colors.elevation50,
              child: Center(
                child: Text(
                  'Step ${_step + 1}',
                  style: context.bitcrText.textLgMedium(color: colors.text300),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.outline,
                  onPressed: _step == 0 ? null : () => setState(() => _step--),
                  child: const Text('Back'),
                ),
              ),
              Expanded(
                child: Button(
                  onPressed: _step == 2 ? null : () => setState(() => _step++),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
