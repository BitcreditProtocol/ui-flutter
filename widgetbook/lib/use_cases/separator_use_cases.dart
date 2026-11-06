import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: Separator)
Widget separatorDefault(BuildContext context) =>
    const Padding(padding: EdgeInsets.all(20), child: Separator());

@widgetbook.UseCase(name: 'Between rows', type: Separator)
Widget separatorBetweenRows(BuildContext context) => Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 1; i <= 5; i++) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('Row $i', style: context.bitcrText.textMdRegular()),
        ),
        if (i < 5) const Separator(),
      ],
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: Separator)
Widget separatorPlayground(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Separator(
      indent: context.knobs.double.slider(
        label: 'Indent',
        initialValue: 0,
        min: 0,
        max: 120,
      ),
      color: context.knobs.object.dropdown(
        label: 'Color',
        options: [colors.divider75, colors.divider50, colors.divider200],
        labelBuilder: (c) => switch (c) {
          _ when c == colors.divider75 => 'divider75 (default)',
          _ when c == colors.divider50 => 'divider50',
          _ => 'divider200',
        },
      ),
    ),
  );
}
