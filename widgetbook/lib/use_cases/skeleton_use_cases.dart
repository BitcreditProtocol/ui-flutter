import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: Skeleton)
Widget skeletonDefault(BuildContext context) =>
    const Padding(padding: EdgeInsets.all(20), child: Skeleton(height: 16));

/// A loading list row, which is how skeletons actually appear: an avatar, a
/// title line and a shorter subtitle line, with a separator under the row.
@widgetbook.UseCase(name: 'List row', type: Skeleton)
Widget skeletonListRow(BuildContext context) => const Padding(
  padding: EdgeInsets.all(20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        spacing: 12,
        children: [
          Skeleton(width: 40, height: 40, radius: 20),
          Expanded(
            child: Column(
              spacing: 8,
              children: [
                Skeleton(height: 14, widthFactor: 0.6),
                Skeleton(height: 12, widthFactor: 0.4),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      Separator(),
    ],
  ),
);

@widgetbook.UseCase(name: 'Playground', type: Skeleton)
Widget skeletonPlayground(BuildContext context) => Padding(
  padding: const EdgeInsets.all(20),
  child: Skeleton(
    height: context.knobs.double.slider(
      label: 'Height',
      initialValue: 16,
      min: 4,
      max: 120,
    ),
    widthFactor: context.knobs.double.slider(
      label: 'Width factor',
      initialValue: 1,
      min: 0.1,
      max: 1,
    ),
    radius: context.knobs.double.slider(
      label: 'Radius',
      initialValue: 6,
      min: 0,
      max: 32,
    ),
  ),
);
