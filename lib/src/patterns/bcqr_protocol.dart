/// The BCQR chunked-QR format, both halves in one place: [buildChunkedQrFrames]
/// writes the frames an [AnimatedQrCode] displays, and [parseBcqrChunk] plus
/// [BcqrAssembler] read them back on the scanning side. Keeping the writer and
/// the reader together is the point — a change to the format that only lands on
/// one side is a silent scan failure.
///
/// Frame format: `BCQR:<totalChunks>:<chunkIndex>:<payload>`
library;

/// Maximum characters per chunk payload. Kept conservative so each chunk's QR
/// code stays small and quick to scan.
const int kBcqrChunkSize = 500;

/// Splits [data] into chunked QR payloads with the BCQR protocol header.
///
/// Data short enough for one chunk still gets a header, so the scanner has a
/// single code path.
List<String> buildChunkedQrFrames(String data) {
  final totalChunks = (data.length / kBcqrChunkSize).ceil();

  if (totalChunks <= 1) {
    return ['BCQR:1:0:$data'];
  }

  final baseSize = data.length ~/ totalChunks;
  final remainder = data.length % totalChunks;

  var start = 0;

  return List.generate(totalChunks, (i) {
    final size = baseSize + (i < remainder ? 1 : 0);
    final end = start + size;
    final payload = data.substring(start, end);
    start = end;

    return 'BCQR:$totalChunks:$i:$payload';
  });
}

/// Parsed representation of a single BCQR chunk frame.
class BcqrChunk {
  const BcqrChunk({
    required this.totalChunks,
    required this.index,
    required this.payload,
  });

  final int totalChunks;
  final int index;
  final String payload;
}

/// Returns `true` if [value] looks like a BCQR chunked QR frame.
bool isBcqrChunk(String value) => value.startsWith('BCQR:');

/// Parses a BCQR frame string. Returns `null` if the format is invalid.
BcqrChunk? parseBcqrChunk(String value) {
  if (!isBcqrChunk(value)) return null;

  final firstColon = value.indexOf(':', 0); // after BCQR
  if (firstColon == -1) return null;

  final secondColon = value.indexOf(':', firstColon + 1);
  if (secondColon == -1) return null;

  final thirdColon = value.indexOf(':', secondColon + 1);
  if (thirdColon == -1) return null;

  final totalChunks = int.tryParse(
    value.substring(firstColon + 1, secondColon),
  );
  final index = int.tryParse(value.substring(secondColon + 1, thirdColon));

  if (totalChunks == null || index == null) return null;
  if (totalChunks <= 0 || index < 0 || index >= totalChunks) return null;

  final payload = value.substring(thirdColon + 1);

  return BcqrChunk(totalChunks: totalChunks, index: index, payload: payload);
}

/// Accumulates BCQR chunks and reassembles the original data.
class BcqrAssembler {
  int? _expectedTotal;
  final Map<int, String> _chunks = {};

  /// Resets the assembler state.
  void reset() {
    _expectedTotal = null;
    _chunks.clear();
  }

  /// Adds a chunk. If the chunk belongs to a different sequence (different
  /// totalChunks), the buffer is reset first.
  ///
  /// Returns the reassembled full data string when all chunks have been
  /// received, or `null` if more chunks are still needed.
  String? addChunk(BcqrChunk chunk) {
    // if we were collecting for a different total, start over
    if (_expectedTotal != null && _expectedTotal != chunk.totalChunks) {
      reset();
    }

    _expectedTotal = chunk.totalChunks;
    _chunks[chunk.index] = chunk.payload;

    if (_chunks.length == _expectedTotal) {
      final buffer = StringBuffer();
      for (var i = 0; i < _expectedTotal!; i++) {
        buffer.write(_chunks[i]);
      }
      final result = buffer.toString();
      reset();
      return result;
    }

    return null;
  }

  /// Number of unique chunks received so far.
  int get receivedCount => _chunks.length;

  /// Total chunks expected, or `null` if no chunks added yet.
  int? get expectedTotal => _expectedTotal;

  /// Set of chunk indices already received.
  Set<int> get receivedIndices => _chunks.keys.toSet();
}
