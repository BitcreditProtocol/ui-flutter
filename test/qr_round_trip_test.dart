// Every QR the library draws is decoded again by an independent reader before
// it is shown, so a code that would scan to something else is never drawn.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encodeQrMatrix round-trip', () {
    test('accepts payloads across sizes and both error-correction levels', () {
      for (final data in [
        'a',
        'bitcoin:bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq?amount=0.001',
        'creqA${'x' * 400}',
        // Above kQrMediumEccMaxLength, so encoded at level L.
        'cashuB${'Ab0+/' * 300}',
        'x' * kMaxStaticQrDataLength,
        'Zürich ✓ 日本',
      ]) {
        expect(encodeQrMatrix(data), isNotNull, reason: data);
      }
    });

    test('rejects a matrix that does not scan to the intended payload', () {
      final matrix = encodeQrMatrix('bc1qintended')!;

      expect(qrMatrixDecodesTo(matrix, 'bc1qintended'), isTrue);
      expect(qrMatrixDecodesTo(matrix, 'bc1qattacker'), isFalse);
    });

    test('checks every animated frame too', () {
      final frames = buildChunkedQrFrames('x' * 3000);
      final matrices = encodeQrMatrices(frames);

      expect(matrices, everyElement(isNotNull));
      for (var i = 0; i < frames.length; i++) {
        expect(qrMatrixDecodesTo(matrices[i]!, frames[i]), isTrue);
      }
    });

    test('stays fast enough for the background isolate', () {
      final stopwatch = Stopwatch()..start();
      encodeQrMatrix('x' * kMaxStaticQrDataLength);
      stopwatch.stop();

      // The largest static code; generous so a slow CI runner does not flake.
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
