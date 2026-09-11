import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// One token, drawn as a filled square with its name. The border is always
/// [BitcrColors.divider300] so near-page-colored swatches stay visible.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: colors.divider300),
              borderRadius: BorderRadius.circular(BitcrRadius.sm),
            ),
          ),
          Text(name, style: context.bitcrText.textXsRegular()),
        ],
      ),
    );
  }
}

/// A fill token beside the content color that belongs on it, so an unreadable
/// pairing is obvious.
class _FillPair extends StatelessWidget {
  const _FillPair({
    required this.name,
    required this.fill,
    required this.onFill,
  });

  final String name;
  final Color fill;
  final Color onFill;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: colors.divider300),
        borderRadius: BorderRadius.circular(BitcrRadius.sm),
      ),
      child: Text(
        name,
        style: context.bitcrText.textSmMedium(color: onFill),
      ),
    );
  }
}

Widget _group(BuildContext context, String title, List<Widget> children) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(title, style: context.bitcrText.textMdMedium()),
        Wrap(spacing: 12, runSpacing: 12, children: children),
      ],
    );

/// Every token in the palette. Flip the theme addon to check both sets — a few
/// tokens deliberately don't move (the brand ramp) and a few invert
/// (`baseActive`, `text300`).
@widgetbook.UseCase(name: 'All tokens', type: BitcrColors)
Widget colorsAllTokens(BuildContext context) {
  final c = BitcrColors.of(context);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _group(context, 'Fundaments', [
          _Swatch(name: 'black', color: c.black),
          _Swatch(name: 'white', color: c.white),
        ]),
        _group(context, 'Elevation', [
          _Swatch(name: 'elevation0', color: c.elevation0),
          _Swatch(name: 'elevation50', color: c.elevation50),
          _Swatch(name: 'elevation100', color: c.elevation100),
          _Swatch(name: 'elevation200', color: c.elevation200),
          _Swatch(name: 'elevation250', color: c.elevation250),
          _Swatch(name: 'elevation300', color: c.elevation300),
          _Swatch(name: 'elevation350', color: c.elevation350),
        ]),
        _group(context, 'Text', [
          _Swatch(name: 'text50', color: c.text50),
          _Swatch(name: 'text100', color: c.text100),
          _Swatch(name: 'text200', color: c.text200),
          _Swatch(name: 'text300', color: c.text300),
          _Swatch(name: 'text400', color: c.text400),
          _Swatch(name: 'textActive', color: c.textActive),
          _Swatch(name: 'textInactive', color: c.textInactive),
        ]),
        _group(context, 'Divider', [
          _Swatch(name: 'divider50', color: c.divider50),
          _Swatch(name: 'divider75', color: c.divider75),
          _Swatch(name: 'divider100', color: c.divider100),
          _Swatch(name: 'divider200', color: c.divider200),
          _Swatch(name: 'divider300', color: c.divider300),
        ]),
        _group(context, 'Base', [
          _Swatch(name: 'baseActive', color: c.baseActive),
          _Swatch(name: 'baseInactive', color: c.baseInactive),
        ]),
        _group(context, 'Brand', [
          _Swatch(name: 'brand50', color: c.brand50),
          _Swatch(name: 'brand100', color: c.brand100),
          _Swatch(name: 'brand200', color: c.brand200),
          _Swatch(name: 'networkBadge', color: c.networkBadge),
        ]),
        _group(context, 'Signal', [
          _Swatch(name: 'signalSuccess', color: c.signalSuccess),
          _Swatch(name: 'signalSuccessLight', color: c.signalSuccessLight),
          _Swatch(name: 'signalAlert', color: c.signalAlert),
          _Swatch(name: 'signalError', color: c.signalError),
          _Swatch(name: 'signalErrorAccent', color: c.signalErrorAccent),
          _Swatch(name: 'signalErrorLight', color: c.signalErrorLight),
        ]),
      ],
    ),
  );
}

/// The fill / on-fill pairs. These resolve differently per brightness — in
/// light a brand fill is the warm tint with dark text, in dark it's the brand
/// orange with black text — so switch the theme to see why they can't be
/// aliases of [BitcrColors.brand50] or [BitcrColors.elevation300].
@widgetbook.UseCase(name: 'Fill pairs', type: BitcrColors)
Widget colorsFillPairs(BuildContext context) {
  final c = BitcrColors.of(context);

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        _FillPair(
          name: 'brandFill / onBrandFill',
          fill: c.brandFill,
          onFill: c.onBrandFill,
        ),
        _FillPair(
          name: 'selectionFill / onSelectionFill',
          fill: c.selectionFill,
          onFill: c.onSelectionFill,
        ),
      ],
    ),
  );
}
