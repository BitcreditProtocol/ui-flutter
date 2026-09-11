import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _nodeId = 'bitcr1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4qejxtdg4y5r3z';
const _prose =
    'A payment description long enough that it cannot fit on a single line '
    'inside the row it is placed in.';

Widget _row(BuildContext context, Widget child) => Padding(
  padding: const EdgeInsets.all(24),
  child: Align(alignment: Alignment.topCenter, child: child),
);

/// A node ID in `auto` mode: recognised by the `bitcr1` heuristic and
/// truncated in the middle, so both ends stay checkable against a source.
@widgetbook.UseCase(name: 'Node ID', type: TruncatedTextPopover)
Widget truncatedNodeId(BuildContext context) => _row(
  context,
  TruncatedTextPopover(
    text: _nodeId,
    style: context.bitcrText.textSmMedium(),
  ),
);

/// Prose with an explicit `maxLength`: truncated at the end instead.
@widgetbook.UseCase(name: 'Truncated at the end', type: TruncatedTextPopover)
Widget truncatedEnd(BuildContext context) => _row(
  context,
  TruncatedTextPopover(
    text: _prose,
    maxLength: 32,
    truncationMode: TruncationMode.end,
    style: context.bitcrText.textSmMedium(),
  ),
);

/// Short enough to fit, so nothing is truncated: no dashed underline, and
/// tapping does nothing.
@widgetbook.UseCase(name: 'Not truncated', type: TruncatedTextPopover)
Widget truncatedNotTruncated(BuildContext context) => _row(
  context,
  TruncatedTextPopover(
    text: 'Alice',
    maxLength: 32,
    style: context.bitcrText.textSmMedium(),
  ),
);

/// With the copy button. The widget writes the clipboard and calls back — the
/// snackbar here stands in for the app's own confirmation.
@widgetbook.UseCase(name: 'With copy button', type: TruncatedTextPopover)
Widget truncatedWithCopy(BuildContext context) => _row(
  context,
  TruncatedTextPopover(
    text: _nodeId,
    showCopyButton: true,
    copyLabel: 'Copy',
    onCopied: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    ),
    style: context.bitcrText.textSmMedium(),
  ),
);

/// In a narrow slot with no `maxLength`: truncation is detected from the
/// layout, so the dialog only opens once the text really overflows. Drag the
/// width down to watch it flip.
@widgetbook.UseCase(name: 'Layout overflow', type: TruncatedTextPopover)
Widget truncatedLayoutOverflow(BuildContext context) => _row(
  context,
  SizedBox(
    width: context.knobs.double.slider(
      label: 'Available width',
      initialValue: 200,
      min: 60,
      max: 400,
    ),
    child: TruncatedTextPopover(
      text: _prose,
      style: context.bitcrText.textSmMedium(),
    ),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: TruncatedTextPopover)
Widget truncatedPlayground(BuildContext context) {
  final showCopyButton = context.knobs.boolean(label: 'Copy button');

  return _row(
    context,
    SizedBox(
      width: context.knobs.double.slider(
        label: 'Available width',
        initialValue: 280,
        min: 60,
        max: 400,
      ),
      child: TruncatedTextPopover(
        text: context.knobs.string(label: 'Text', initialValue: _nodeId),
        maxLength: context.knobs.int
            .slider(label: 'Max length', initialValue: 24, min: 4, max: 80)
            .toInt(),
        truncationMode: context.knobs.object.dropdown(
          label: 'Mode',
          options: TruncationMode.values,
          labelBuilder: (m) => m.name,
        ),
        maxLines: context.knobs.int
            .slider(label: 'Max lines', initialValue: 1, min: 1, max: 3)
            .toInt(),
        underlineOnTruncate: context.knobs.boolean(
          label: 'Underline when truncated',
          initialValue: true,
        ),
        showCopyButton: showCopyButton,
        copyLabel: showCopyButton ? 'Copy' : null,
        style: context.bitcrText.textSmMedium(),
      ),
    ),
  );
}
