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

/// Runs the QR Reed-Solomon encode for [data] and returns a transferable
/// [QrMatrix], or null when [data] cannot be encoded at all.
///
/// Top-level so it can be passed to `compute` — the encode is CPU-heavy enough
/// for large payloads that running it on the UI isolate blocks frame rendering
/// (visible as jank/freezes during navigation).
///
/// Null rather than a throw for the one failure that is a property of the
/// input: past the largest QR version — somewhere between 2,000 and 3,000
/// characters at [qr.QrErrorCorrectLevel.low] — there is no code to draw. That
/// arrives as an [qr.InputTooLongException] out of the [qr.QrCode] construction,
/// which picks the version. Callers run this through `compute`, where a throw
/// becomes a rejected future that is easy to leave unhandled — and then the
/// widget waiting on it waits for ever.
QrMatrix? encodeQrMatrix(String data) {
  final qr.QrImage qrImage;
  try {
    qrImage = qr.QrImage(
      qr.QrCode(
        payload: qr.QrPayload.fromString(data),
        errorCorrectLevel: qr.QrErrorCorrectLevel.low,
      ),
    );
  } on Object {
    return null;
  }

  final n = qrImage.moduleCount;
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
    frames.map(encodeQrMatrix).toList();

/// Paints a [QrMatrix] as square modules, filling the shortest side of the
/// canvas. Anti-aliasing is off so module edges stay hard and scannable.
class QrMatrixPainter extends CustomPainter {
  const QrMatrixPainter({required this.matrix, required this.color});

  final QrMatrix matrix;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = matrix.moduleCount;
    if (moduleCount == 0) return;

    final side = size.shortestSide;
    final moduleSize = side / moduleCount;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    final path = Path();

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (!matrix.isDark(row, col)) continue;

        path.addRect(
          Rect.fromLTWH(
            col * moduleSize,
            row * moduleSize,
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
    return matrix != oldDelegate.matrix || color != oldDelegate.color;
  }
}
