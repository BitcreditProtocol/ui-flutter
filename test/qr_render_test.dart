// How a QR is drawn: dark modules on a light ground with a quiet zone in
// either theme, and which error-correction level a payload gets.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart' as qr;

/// Paints [matrix] into a [side]-pixel square and returns its RGBA bytes.
Future<ByteData> paintMatrix(QrMatrix matrix, int side) async {
  final recorder = ui.PictureRecorder();
  QrMatrixPainter(matrix: matrix)
      .paint(Canvas(recorder), Size.square(side.toDouble()));
  final image = await recorder.endRecording().toImage(side, side);

  return (await image.toByteData())!;
}

Color pixelAt(ByteData bytes, int side, int x, int y) {
  final i = (y * side + x) * 4;

  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

void main() {
  group('QrMatrixPainter', () {
    testWidgets('draws black modules on white inside a quiet zone', (
      tester,
    ) async {
      // Light modules on a dark ground (what the dark theme used to give)
      // are skipped by many scanners and bloom on a bright screen.
      final matrix = encodeQrMatrix('bcrt1qexample')!;
      final n = matrix.moduleCount;
      final unit = 10;
      final side = (n + 2 * kQrQuietZoneModules) * unit;

      final bytes = (await tester.runAsync(() => paintMatrix(matrix, side)))!;

      // Corner of the quiet zone, and the module right before the code.
      expect(pixelAt(bytes, side, 0, 0), kQrBackgroundColor);
      final edge = kQrQuietZoneModules * unit - unit ~/ 2;
      expect(pixelAt(bytes, side, edge, edge), kQrBackgroundColor);

      // The finder pattern's outer corner module is always dark.
      final first = kQrQuietZoneModules * unit + unit ~/ 2;
      expect(matrix.isDark(0, 0), isTrue);
      expect(pixelAt(bytes, side, first, first), kQrModuleColor);
    });
  });

  group('error correction', () {
    int modulesAt(String data, int level) =>
        qr.QrCode.fromData(data: data, errorCorrectLevel: level).moduleCount;

    test('short payloads get level M', () {
      final data = 'x' * kQrMediumEccMaxLength;

      expect(
        encodeQrMatrix(data)!.moduleCount,
        modulesAt(data, qr.QrErrorCorrectLevel.M),
      );
    });

    test('longer payloads stay at level L', () {
      final data = 'x' * (kQrMediumEccMaxLength + 1);

      expect(
        encodeQrMatrix(data)!.moduleCount,
        modulesAt(data, qr.QrErrorCorrectLevel.L),
      );
    });

    test('animated frames stay at level L however short', () {
      const frame = 'BCQR:2:0:short';

      expect(
        encodeQrMatrices([frame]).single!.moduleCount,
        modulesAt(frame, qr.QrErrorCorrectLevel.L),
      );
    });
  });
}
