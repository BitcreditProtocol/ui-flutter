import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// One step of the scale: its name, a specimen, and the metrics read back off
/// the [TextStyle] itself — so this page can't drift from the tokens.
class _Specimen extends StatelessWidget {
  const _Specimen({
    required this.name,
    required this.style,
    required this.sample,
  });

  final String name;
  final TextStyle style;
  final String sample;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final size = style.fontSize;
    final weight = style.fontWeight?.value;
    final height = style.height;
    final lineHeight = (size != null && height != null)
        ? (size * height).round()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(name, style: context.bitcrText.textSmMedium()),
            Text(
              [
                if (size != null) '${size.round()}px',
                if (weight != null) 'w$weight',
                if (lineHeight != null) 'line $lineHeight',
              ].join(' · '),
              style: context.bitcrText.textXsRegular(color: colors.text200),
            ),
          ],
        ),
        Text(sample, style: style),
      ],
    );
  }
}

/// The whole type scale, largest first. Every style defaults its color to
/// [BitcrColors.text300], so call sites only pass `color:` to deviate.
///
/// The text-scale addon multiplies all of these — worth pushing to 2× to see
/// which steps start colliding.
@widgetbook.UseCase(name: 'Type scale', type: BitcrTextStyles)
Widget textStylesScale(BuildContext context) {
  final t = context.bitcrText;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 28,
      children: [
        _Specimen(
          name: 'displayMdRegular',
          style: t.displayMdRegular(),
          sample: '12 500',
        ),
        _Specimen(
          name: 'displayXsMedium',
          style: t.displayXsMedium(),
          sample: 'Screen title',
        ),
        _Specimen(
          name: 'textLgMedium',
          style: t.textLgMedium(),
          sample: 'Empty state title',
        ),
        _Specimen(
          name: 'textMdMedium',
          style: t.textMdMedium(),
          sample: 'List row label',
        ),
        _Specimen(
          name: 'textMdRegular',
          style: t.textMdRegular(),
          sample: 'Body copy at the default size',
        ),
        _Specimen(
          name: 'textSmMedium',
          style: t.textSmMedium(),
          sample: 'Button label',
        ),
        _Specimen(
          name: 'textSmRegular',
          style: t.textSmRegular(),
          sample: 'Secondary line under a label',
        ),
        _Specimen(
          name: 'textXsMedium',
          style: t.textXsMedium(),
          sample: 'Helper and error text',
        ),
        _Specimen(
          name: 'textXsRegular',
          style: t.textXsRegular(),
          sample: 'Field label, smallest step',
        ),
      ],
    ),
  );
}

/// The same paragraph at each step, to compare rhythm rather than glyphs —
/// this is where a line height that's too tight shows up.
@widgetbook.UseCase(name: 'Paragraphs', type: BitcrTextStyles)
Widget textStylesParagraphs(BuildContext context) {
  final t = context.bitcrText;
  const copy =
      'Requests you send or receive will show up here, newest first. '
      'Nothing has come in yet.';

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        for (final (name, style) in [
          ('textMdRegular', t.textMdRegular()),
          ('textSmRegular', t.textSmRegular()),
          ('textXsRegular', t.textXsRegular()),
        ])
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(name, style: t.textSmMedium()),
              SizedBox(width: 320, child: Text(copy, style: style)),
            ],
          ),
      ],
    ),
  );
}

/// Each step against the text color tokens it's actually paired with, so a
/// combination that goes muddy in one theme is visible.
@widgetbook.UseCase(name: 'Against color tokens', type: BitcrTextStyles)
Widget textStylesColors(BuildContext context) {
  final t = context.bitcrText;
  final c = BitcrColors.of(context);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final (name, color) in [
          ('text300 — body', c.text300),
          ('text200 — secondary', c.text200),
          ('text100 — on elevation', c.text100),
          ('text400 — accent', c.text400),
          ('signalError', c.signalError),
        ])
          Text('textMdMedium · $name', style: t.textMdMedium(color: color)),
      ],
    ),
  );
}
