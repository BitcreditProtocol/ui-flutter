import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:qr/qr.dart' as qr;

/// A plain, isolate-transferable snapshot of an encoded QR code's module
/// grid, decoupled from qr's QrCode/QrImage so it can safely cross
/// isolate boundaries when encoded via `compute`.
class QrMatrix {
  const QrMatrix._(this.moduleCount, this._modules);

  final int moduleCount;
  final Uint8List _modules;

  bool isDark(int row, int col) => _modules[row * moduleCount + col] != 0;
}

const Color kQrModuleColor = Color(0xFF000000);
const Color kQrBackgroundColor = Color(0xFFFFFFFF);
const int kQrQuietZoneModules = 4;
const int kQrMediumEccMaxLength = 1000;

/// Runs the QR Reed-Solomon encode for [data] and returns a transferable
/// [QrMatrix], or null when [data] cannot be encoded at all.
///
/// Top-level so it can be passed to `compute` — the encode is CPU-heavy enough
/// for large payloads that running it on the UI isolate blocks frame rendering
/// (visible as jank/freezes during navigation).
///
/// Null rather than a throw for the one failure that is a property of the
/// input: past the largest QR version — somewhere between 2,000 and 3,000
/// characters at [qr.QrErrorCorrectLevel.L] — there is no code to draw. That
/// arrives as an [qr.InputTooLongException] out of [qr.QrCode.fromData], which
/// picks the version. Callers run this through `compute`, where a throw
/// becomes a rejected future that is easy to leave unhandled — and then the
/// widget waiting on it waits for ever.
QrMatrix? encodeQrMatrix(String data) => _encode(
  data,
  data.length <= kQrMediumEccMaxLength
      ? qr.QrErrorCorrectLevel.M
      : qr.QrErrorCorrectLevel.L,
);

QrMatrix? _encode(String data, int errorCorrectLevel) {
  final qr.QrCode qrCode;
  final qr.QrImage qrImage;
  try {
    qrCode = qr.QrCode.fromData(
      data: data,
      errorCorrectLevel: errorCorrectLevel,
    );
    qrImage = qr.QrImage(qrCode);
  } on Object {
    return null;
  }

  final n = qrCode.moduleCount;
  final modules = Uint8List(n * n);

  for (var row = 0; row < n; row++) {
    for (var col = 0; col < n; col++) {
      if (qrImage.isDark(row, col)) modules[row * n + col] = 1;
    }
  }

  return QrMatrix._(n, modules);
}

/// Same as [encodeQrMatrix] but for a whole set of chunked frames in one
/// `compute` call, so an animated QR only pays the isolate-spawn cost once.
List<QrMatrix?> encodeQrMatrices(List<String> frames) =>
    frames.map((frame) => _encode(frame, qr.QrErrorCorrectLevel.L)).toList();

class QrMatrixPainter extends CustomPainter {
  const QrMatrixPainter({required this.matrix});

  final QrMatrix matrix;

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = matrix.moduleCount;
    if (moduleCount == 0) return;

    final side = size.shortestSide;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, side, side),
      Paint()..color = kQrBackgroundColor,
    );

    final moduleSize = side / (moduleCount + 2 * kQrQuietZoneModules);
    final offset = kQrQuietZoneModules * moduleSize;
    final paint = Paint()
      ..color = kQrModuleColor
      ..isAntiAlias = false;
    final path = Path();

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (!matrix.isDark(row, col)) continue;

        path.addRect(
          Rect.fromLTWH(
            offset + col * moduleSize,
            offset + row * moduleSize,
            moduleSize,
            moduleSize,
          ),
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant QrMatrixPainter oldDelegate) {
    return matrix != oldDelegate.matrix;
  }
}
