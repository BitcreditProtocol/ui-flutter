// The BCQR reader takes frames straight from the camera, so it has to turn
// away anything the writer would never produce.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';

String? assemble(List<String> frames) {
  final assembler = BcqrAssembler();
  String? result;
  for (final frame in frames) {
    result = assembler.addChunk(parseBcqrChunk(frame)!) ?? result;
  }
  return result;
}

void main() {
  group('parseBcqrChunk', () {
    test('reads back every frame the writer produces', () {
      final data = 'cashuB${'Ab0-_' * 700}';
      final frames = buildChunkedQrFrames(data);

      expect(frames.length, greaterThan(1));
      expect(assemble(frames), data);
    });

    test('returns null for malformed frames instead of throwing', () {
      for (final frame in [
        'BCQR',
        'BCQR:',
        'BCQR:1',
        'BCQR:1:0',
        'BCQR:x:0:data',
        'BCQR:1:y:data',
        'BCQR:0:0:data',
        'BCQR:-1:0:data',
        'BCQR:2:2:data',
        'BCQR:2:-1:data',
        'bcqr:1:0:data',
      ]) {
        expect(parseBcqrChunk(frame), isNull, reason: frame);
      }
    });

    test('rejects a sequence longer than kBcqrMaxChunks', () {
      expect(parseBcqrChunk('BCQR:$kBcqrMaxChunks:0:data'), isNotNull);
      expect(parseBcqrChunk('BCQR:${kBcqrMaxChunks + 1}:0:data'), isNull);
      expect(parseBcqrChunk('BCQR:999999999999:0:data'), isNull);
    });

    test('rejects a frame with more payload than the writer puts in one', () {
      expect(parseBcqrChunk('BCQR:1:0:${'x' * kBcqrChunkSize}'), isNotNull);
      expect(parseBcqrChunk('BCQR:1:0:${'x' * (kBcqrChunkSize + 1)}'), isNull);
    });

    test('keeps colons inside the payload', () {
      expect(parseBcqrChunk('BCQR:1:0:bitcoin:bc1q')?.payload, 'bitcoin:bc1q');
    });
  });

  group('BcqrAssembler', () {
    test('does not stitch together two codes with the same chunk count', () {
      final first = buildChunkedQrFrames('a' * 1500);
      final second = buildChunkedQrFrames('b' * 1500);
      expect(first.length, 3);

      // The camera moves from one code to the other mid-scan. The old
      // assembler overwrote index 1 and completed on second[2] with "a", "b",
      // "b"; now the conflicting index 1 starts the sequence over.
      final assembler = BcqrAssembler();
      final results = [
        for (final frame in [first[0], first[1], second[1], second[2]])
          assembler.addChunk(parseBcqrChunk(frame)!),
        for (final frame in second) assembler.addChunk(parseBcqrChunk(frame)!),
      ].nonNulls;

      expect(results, ['b' * 1500]);
    });

    test('ignores a repeated identical frame', () {
      final frames = buildChunkedQrFrames('c' * 1000);

      expect(assemble([frames[0], frames[0], frames[1]]), 'c' * 1000);
    });
  });
}
