/// Measures text in a given font. The renderer measures with the embedded
/// TTF; tests can measure with anything.
abstract interface class BillPdfTextMeasure {
  /// Advance width of [text] at [size] points.
  double widthOfTextAtSize(String text, double size);
}

/// Shortens [text] with a trailing `...` until it fits [maxWidth], leaving
/// [slack] points of air once truncation starts. Text that already fits is
/// returned as is.

String truncateTextToWidth(
  BillPdfTextMeasure font,
  double size,
  String text,
  double maxWidth, {
  double slack = 6,
}) {
  var output = text;
  var width = font.widthOfTextAtSize(output, size);
  if (width <= maxWidth) {
    return output;
  }
  while (width > maxWidth - slack && output.length > 1) {
    output = output.substring(0, output.length - 1);
    width = font.widthOfTextAtSize('$output...', size);
  }
  return '$output...';
}

/// `truncatePdfTextToFit`: [truncateTextToWidth] with 6 points of slack, and
/// empty in, empty out.
String truncatePdfTextToFit(
  BillPdfTextMeasure font,
  double size,
  String text,
  double maxWidth,
) {
  if (text.isEmpty) {
    return '';
  }
  return truncateTextToWidth(font, size, text, maxWidth);
}

/// Truncates the leading comma-separated segments of [text] so the last
/// [trailingSegmentCount] survive whole — "Long Street 1, Vienna, Austria"
/// keeps "Vienna, Austria" and shortens the street.
String truncatePdfLeadingSegmentToFit(
  BillPdfTextMeasure font,
  double size,
  String text,
  double maxWidth, [
  int trailingSegmentCount = 2,
]) {
  if (text.isEmpty || font.widthOfTextAtSize(text, size) <= maxWidth) {
    return text;
  }

  final parts = text
      .split(', ')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length <= 1) {
    return truncatePdfTextToFit(font, size, text, maxWidth);
  }

  final safeTrailingCount = trailingSegmentCount.clamp(1, parts.length - 1);
  final trailingParts = parts.sublist(parts.length - safeTrailingCount);
  final leadingCount = parts.length - trailingParts.length;
  final leadingParts = parts.sublist(0, leadingCount < 1 ? 1 : leadingCount);
  final trailingText = trailingParts.join(', ');
  const separator = ', ';
  final reservedTrailingWidth = font.widthOfTextAtSize(
    '$separator$trailingText',
    size,
  );

  if (reservedTrailingWidth >= maxWidth) {
    return truncatePdfTextToFit(font, size, trailingText, maxWidth);
  }

  final leadingText = truncatePdfTextToFit(
    font,
    size,
    leadingParts.join(', '),
    maxWidth - reservedTrailingWidth,
  );
  return '$leadingText$separator$trailingText';
}

/// Fits "Place, Date" into [maxWidth], always keeping the date whole and
/// shortening the place.
String truncatePdfPlaceDateToFit(
  BillPdfTextMeasure font,
  double size,
  String place,
  String date,
  double maxWidth,
) {
  final trimmedPlace = place.trim();
  final trimmedDate = date.trim();

  if (trimmedPlace.isEmpty) {
    return truncatePdfTextToFit(font, size, trimmedDate, maxWidth);
  }
  if (trimmedDate.isEmpty) {
    return truncatePdfTextToFit(font, size, trimmedPlace, maxWidth);
  }

  final fullText = '$trimmedPlace, $trimmedDate';
  if (font.widthOfTextAtSize(fullText, size) <= maxWidth) {
    return fullText;
  }

  const separator = ', ';
  final remainingWidth =
      maxWidth -
      font.widthOfTextAtSize(trimmedDate, size) -
      font.widthOfTextAtSize(separator, size);
  if (remainingWidth <= 0) {
    return truncatePdfTextToFit(font, size, trimmedDate, maxWidth);
  }

  return '${truncatePdfTextToFit(font, size, trimmedPlace, remainingWidth)}'
      '$separator$trimmedDate';
}

/// The parties block's variant of [truncatePdfLeadingSegmentToFit]: trims
/// first, keeps everything after the first segment, and uses 10 points of
/// slack.
String truncateFirstSegmentToWidth(
  BillPdfTextMeasure font,
  double size,
  String text,
  double maxWidth,
) {
  final normalized = text.trim();
  if (normalized.isEmpty ||
      font.widthOfTextAtSize(normalized, size) <= maxWidth) {
    return normalized;
  }

  final parts = normalized
      .split(', ')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length <= 1) {
    return truncateTextToWidth(font, size, normalized, maxWidth, slack: 10);
  }

  final trailingText = parts.sublist(1).join(', ');
  const separator = ', ';
  final reservedWidth = font.widthOfTextAtSize('$separator$trailingText', size);
  if (reservedWidth >= maxWidth) {
    return truncateTextToWidth(font, size, trailingText, maxWidth, slack: 10);
  }

  final leadingText = truncateTextToWidth(
    font,
    size,
    parts.first,
    maxWidth - reservedWidth,
    slack: 10,
  );
  return '$leadingText$separator$trailingText';
}

/// Breaks [text] at word boundaries into at most two lines of [maxWidth]; the
/// second line is truncated. A first word too long for a line is hard-split.
({String line1, String line2}) splitToTwoLines(
  BillPdfTextMeasure font,
  double size,
  String text,
  double maxWidth,
) {
  final normalized = text.trim();
  if (normalized.isEmpty) {
    return (line1: '', line2: '');
  }
  if (font.widthOfTextAtSize(normalized, size) <= maxWidth) {
    return (line1: normalized, line2: '');
  }

  final words = normalized.split(RegExp(r'\s+'));
  var line1 = '';
  var index = 0;
  while (index < words.length) {
    final candidate = line1.isEmpty ? words[index] : '$line1 ${words[index]}';
    if (font.widthOfTextAtSize(candidate, size) > maxWidth) break;
    line1 = candidate;
    index++;
  }

  if (line1.isEmpty) {
    var first = normalized;
    while (first.length > 1 && font.widthOfTextAtSize(first, size) > maxWidth) {
      first = first.substring(0, first.length - 1);
    }
    final rest = normalized.substring(first.length).trimLeft();
    return (
      line1: first,
      line2: truncateTextToWidth(font, size, rest, maxWidth, slack: 10),
    );
  }
  return (
    line1: line1,
    line2: truncateTextToWidth(
      font,
      size,
      words.sublist(index).join(' '),
      maxWidth,
      slack: 10,
    ),
  );
}

// Unicode SpecialCasing expansions that JavaScript's toUpperCase applies and
// Dart's leaves alone ("Straße" -> "STRASSE" in the web client).
const _upperExpansions = <String, String>{
  'ß': 'SS',
  'ŉ': 'ʼN',
  'ﬀ': 'FF',
  'ﬁ': 'FI',
  'ﬂ': 'FL',
  'ﬃ': 'FFI',
  'ﬄ': 'FFL',
  'ﬅ': 'ST',
  'ﬆ': 'ST',
};
final _upperExpansionPattern = RegExp('[${_upperExpansions.keys.join()}]');

/// Uppercases like JavaScript's `String.prototype.toUpperCase`, so names and
/// titles measure and print the same as in the web client.
String billPdfUpperCase(String text) => text
    .replaceAllMapped(_upperExpansionPattern, (m) => _upperExpansions[m[0]]!)
    .toUpperCase();
