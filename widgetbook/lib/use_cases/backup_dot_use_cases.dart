import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: BackupDot)
Widget backupDotDefault(BuildContext context) => const BackupDot();

/// On a label, which is how it actually appears — the dot alone says little
/// about whether the 8px default reads at the right weight next to text.
@widgetbook.UseCase(name: 'On a settings row', type: BackupDot)
Widget backupDotOnRow(BuildContext context) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: [
    Text('Recovery phrase', style: context.bitcrText.textMdRegular()),
    const BackupDot(),
  ],
);

@widgetbook.UseCase(name: 'Playground', type: BackupDot)
Widget backupDotPlayground(BuildContext context) {
  final colors = BitcrColors.of(context);

  return BackupDot(
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 8,
      min: 4,
      max: 24,
    ),
    color: context.knobs.object.dropdown(
      label: 'Color',
      options: [
        colors.signalErrorLight,
        colors.signalSuccess,
        colors.signalAlert,
        colors.brand200,
      ],
      labelBuilder: (c) => switch (c) {
        _ when c == colors.signalErrorLight => 'signalErrorLight (default)',
        _ when c == colors.signalSuccess => 'signalSuccess',
        _ when c == colors.signalAlert => 'signalAlert',
        _ => 'brand200',
      },
    ),
  );
}
