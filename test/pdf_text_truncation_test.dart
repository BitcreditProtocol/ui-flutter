// Measured with a fake monospace font where every character is exactly
// `size` points wide.

import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Mono implements BillPdfTextMeasure {
  const _Mono();

  @override
  double widthOfTextAtSize(String text, double size) => text.length * size;
}

void main() {
  const font = _Mono();

  group('truncatePdfTextToFit', () {
    test('text that fits is unchanged', () {
      expect(truncatePdfTextToFit(font, 1, 'hello', 10), 'hello');
    });

    test('empty stays empty', () {
      expect(truncatePdfTextToFit(font, 1, '', 10), '');
    });

    test('cuts with an ellipsis and leaves 6 points of slack', () {
      // 26 chars into 20: shrink until "<n chars>..." <= 20 - 6.
      expect(
        truncatePdfTextToFit(font, 1, 'abcdefghijklmnopqrstuvwxyz', 20),
        'abcdefghijk...',
      );
    });

    test('never cuts below one character', () {
      expect(truncatePdfTextToFit(font, 1, 'abcdef', 2), 'a...');
    });
  });

  group('truncatePdfLeadingSegmentToFit', () {
    test('keeps the last two segments whole', () {
      expect(
        truncatePdfLeadingSegmentToFit(
          font,
          1,
          'Very Long Street Name 123, Vienna, Austria',
          30,
        ),
        'Very..., Vienna, Austria',
      );
    });

    test('a trailing count of one keeps only the last segment', () {
      expect(
        truncatePdfLeadingSegmentToFit(font, 1, 'Vienna, Austria', 10, 1),
        'V..., Austria',
      );
    });

    test('a single segment truncates like plain text', () {
      expect(
        truncatePdfLeadingSegmentToFit(
          font,
          1,
          'abcdefghijklmnopqrstuvwxyz',
          20,
        ),
        'abcdefghijk...',
      );
    });

    test('when the tail alone is too wide, the tail is truncated', () {
      expect(
        truncatePdfLeadingSegmentToFit(font, 1, 'A, Vienna, Austria', 12),
        'Vie...',
      );
    });
  });

  group('truncatePdfPlaceDateToFit', () {
    test('fits whole', () {
      expect(
        truncatePdfPlaceDateToFit(font, 1, ' Vienna ', '12 Mar 2026', 30),
        'Vienna, 12 Mar 2026',
      );
    });

    test('shortens the place, keeps the date', () {
      expect(
        truncatePdfPlaceDateToFit(font, 1, 'Vienna', '12 Mar 2026', 15),
        'V..., 12 Mar 2026',
      );
    });

    test('no room for a place: only the (truncated) date', () {
      expect(
        truncatePdfPlaceDateToFit(font, 1, 'Vienna', '12 Mar 2026', 10),
        '1...',
      );
    });

    test('a missing half prints the other', () {
      expect(truncatePdfPlaceDateToFit(font, 1, '', '12 Mar', 30), '12 Mar');
      expect(truncatePdfPlaceDateToFit(font, 1, 'Wien', ' ', 30), 'Wien');
    });
  });

  group('splitToTwoLines', () {
    test('a short address stays on one line', () {
      final lines = splitToTwoLines(font, 1, ' bc1q ', 10);
      expect(lines.line1, 'bc1q');
      expect(lines.line2, '');
    });

    test('breaks at words', () {
      final lines = splitToTwoLines(font, 1, 'bc1qxyz abc def', 9);
      expect(lines.line1, 'bc1qxyz');
      expect(lines.line2, 'abc def');
    });

    test('hard-splits a first word that is too long', () {
      final lines = splitToTwoLines(font, 1, 'abcdefghijkl', 5);
      expect(lines.line1, 'abcde');
      expect(lines.line2, 'f...');
    });
  });

  test(
    'truncateFirstSegmentToWidth keeps everything after the first comma',
    () {
      expect(
        truncateFirstSegmentToWidth(
          font,
          1,
          'Vienna Innere Stadt, Austria 1010',
          25,
        ),
        'V..., Austria 1010',
      );
    },
  );

  test('billPdfUpperCase expands like JavaScript', () {
    expect(billPdfUpperCase('Kärntner Straße'), 'KÄRNTNER STRASSE');
    expect(billPdfUpperCase('ﬁne'), 'FINE');
  });
}
