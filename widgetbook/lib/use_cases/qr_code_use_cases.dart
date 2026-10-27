import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _address = 'bitcoin:bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

/// Tap it: a QR enlarges to fullscreen by default, because an inline one is
/// usually too small for another device to scan.
@widgetbook.UseCase(name: 'Default', type: QrCode)
Widget qrCodeDefault(BuildContext context) => const QrCode(data: _address);

/// `enlargeOnTap: false` for a QR that shouldn't grow — one already shown
/// fullscreen, or one whose screen handles the tap itself.
@widgetbook.UseCase(name: 'Enlarge disabled', type: QrCode)
Widget qrCodeNoEnlarge(BuildContext context) =>
    const QrCode(data: _address, enlargeOnTap: false);

/// A payload over `kMaxStaticQrDataLength`, so the fullscreen view falls back
/// to an animated chunked code rather than an unscannably dense static one.
@widgetbook.UseCase(name: 'Enlarges to animated', type: QrCode)
Widget qrCodeEnlargesToAnimated(BuildContext context) =>
    QrCode(data: 'A' * (kMaxStaticQrDataLength + 1));

/// A long payload, which encodes to a denser grid — worth looking at because
/// module rendering is where a QR stops being scannable.
@widgetbook.UseCase(name: 'Dense payload', type: QrCode)
Widget qrCodeDense(BuildContext context) => QrCode(data: _address * 8);

@widgetbook.UseCase(name: 'Playground', type: QrCode)
Widget qrCodePlayground(BuildContext context) {
  final repeats = context.knobs.int
      .slider(label: 'Payload repeats', initialValue: 1, min: 1, max: 20)
      .toInt();

  return QrCode(
    data: _address * repeats,
    enlargeOnTap: context.knobs.boolean(
      label: 'Enlarge on tap',
      initialValue: true,
    ),
  );
}

/// [ExactQrCode] fills its slot exactly, so it has to be reviewed inside a
/// sized box — that's the whole difference from [QrCode].
@widgetbook.UseCase(name: 'In a sized box', type: ExactQrCode)
Widget exactQrCodeSized(BuildContext context) {
  return Center(
    child: SizedBox.square(
      dimension: context.knobs.double.slider(
        label: 'Box size',
        initialValue: 220,
        min: 80,
        max: 320,
      ),
      child: const ExactQrCode(data: _address),
    ),
  );
}
