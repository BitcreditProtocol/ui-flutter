import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stand-in for an ecash token: the real payloads that need chunking are long
/// opaque strings, and only the length changes what's rendered.
String _payload(int chars) =>
    List.filled(chars, 'A').join().substring(0, chars);

/// Under one chunk, so it renders as a plain static QR with no progress bar.
@widgetbook.UseCase(name: 'Single frame', type: AnimatedQrCode)
Widget animatedQrCodeSingleFrame(BuildContext context) =>
    AnimatedQrCode(data: _payload(200));

/// Tapping enlarges it, and the frames keep cycling at the bigger size.
///
/// Four chunks: the frames cycle and the progress bar tracks position. This is
/// the one to watch for the slowdown — it stays at 200ms for five full cycles,
/// then eases out toward 700ms.
@widgetbook.UseCase(name: 'Animating', type: AnimatedQrCode)
Widget animatedQrCodeAnimating(BuildContext context) =>
    AnimatedQrCode(data: _payload(kBcqrChunkSize * 4));

@widgetbook.UseCase(name: 'Playground', type: AnimatedQrCode)
Widget animatedQrCodePlayground(BuildContext context) {
  final chunks = context.knobs.int
      .slider(label: 'Chunks', initialValue: 4, min: 1, max: 12)
      .toInt();

  return AnimatedQrCode(
    // One char short of the next chunk boundary, so the slider value is the
    // frame count.
    data: _payload(kBcqrChunkSize * chunks),
    backgroundColor: context.knobs.boolean(label: 'Light surface')
        ? BitcrColors.of(context).white
        : null,
    enlargeOnTap: context.knobs.boolean(
      label: 'Enlarge on tap',
      initialValue: true,
    ),
  );
}
