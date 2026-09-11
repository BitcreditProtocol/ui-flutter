import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// One radius step, drawn big enough that adjacent steps are distinguishable.
class _RadiusTile extends StatelessWidget {
  const _RadiusTile({
    required this.name,
    required this.radius,
    required this.usage,
  });

  final String name;
  final double radius;
  final String usage;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: colors.elevation200,
              border: Border.all(color: colors.divider300),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          Text(
            '$name · ${radius.round()}px',
            style: context.bitcrText.textSmMedium(),
          ),
          Text(
            usage,
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
        ],
      ),
    );
  }
}

/// The corner-radius scale, with what each step is for. Use these instead of
/// bare numbers so the steps stay a closed set.
@widgetbook.UseCase(name: 'Radius scale', type: BitcrRadius)
Widget radiiScale(BuildContext context) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Wrap(
    spacing: 16,
    runSpacing: 20,
    children: const [
      _RadiusTile(
        name: 'xxs',
        radius: BitcrRadius.xxs,
        usage: 'Hairline accents, thin progress bars',
      ),
      _RadiusTile(
        name: 'xs',
        radius: BitcrRadius.xs,
        usage: 'Index badges, small inner tiles',
      ),
      _RadiusTile(name: 'sm', radius: BitcrRadius.sm, usage: 'Compact chips'),
      _RadiusTile(
        name: 'md',
        radius: BitcrRadius.md,
        usage: 'Default: inputs, buttons, cards, list rows',
      ),
      _RadiusTile(
        name: 'lg',
        radius: BitcrRadius.lg,
        usage: 'Raised containers on a surface',
      ),
      _RadiusTile(
        name: 'xl',
        radius: BitcrRadius.xl,
        usage: 'Bottom sheets and drawers',
      ),
      _RadiusTile(name: 'xxl', radius: BitcrRadius.xxl, usage: 'Sheet top edge'),
      _RadiusTile(name: 'xxxl', radius: BitcrRadius.xxxl, usage: 'Largest step'),
    ],
  ),
);

/// The steps stacked at a shared width, which is the only way to judge whether
/// neighbours like `sm` (6) and `md` (8) are far enough apart to read as
/// separate steps.
@widgetbook.UseCase(name: 'Steps compared', type: BitcrRadius)
Widget radiiCompared(BuildContext context) {
  final colors = BitcrColors.of(context);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final (name, radius) in const [
          ('xxs', BitcrRadius.xxs),
          ('xs', BitcrRadius.xs),
          ('sm', BitcrRadius.sm),
          ('md', BitcrRadius.md),
          ('lg', BitcrRadius.lg),
          ('xl', BitcrRadius.xl),
          ('xxl', BitcrRadius.xxl),
          ('xxxl', BitcrRadius.xxxl),
        ])
          Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 44,
                child: Text(name, style: context.bitcrText.textSmMedium()),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.elevation200,
                    border: Border.all(color: colors.divider300),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

/// The shapes that deliberately stay literal at their call site, because
/// they're shape choices rather than scale steps — a pill is "half my height",
/// not "20px".
@widgetbook.UseCase(name: 'Not on the scale', type: BitcrRadius)
Widget radiiOffScale(BuildContext context) {
  final colors = BitcrColors.of(context);

  Widget box(String label, BorderRadius radius, double height) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 6,
    children: [
      Container(
        width: 150,
        height: height,
        decoration: BoxDecoration(
          color: colors.elevation200,
          border: Border.all(color: colors.divider300),
          borderRadius: radius,
        ),
      ),
      Text(label, style: context.bitcrText.textXsRegular()),
    ],
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      spacing: 16,
      runSpacing: 20,
      children: [
        box('circular(80) — IdentityChip pill', BorderRadius.circular(80), 40),
        box('circular(10) — SettingsSwitch track', BorderRadius.circular(10), 20),
        box(
          'vertical(top: xxl) — sheet top only',
          const BorderRadius.vertical(top: Radius.circular(BitcrRadius.xxl)),
          72,
        ),
        box('circular(1) — hairline bar', BorderRadius.circular(1), 6),
      ],
    ),
  );
}
