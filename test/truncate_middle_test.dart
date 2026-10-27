// truncateMiddle was private to TruncatedTextPopover, so the dashboard grew its
// own copy for ids it shortens outside a popover. The two had drifted: the
// copy split on UTF-16 code units, which can cut a surrogate pair in half and
// leave a broken glyph next to the ellipsis. Making this one public removes
// the copy; these cases pin the behaviour the dashboard now relies on.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short values pass through', () {
    expect(truncateMiddle('abc', 10), 'abc');
    expect(truncateMiddle('abcdefghij', 10), 'abcdefghij');
  });

  test('the head keeps the odd character', () {
    expect(truncateMiddle('abcdefghijkl', 8), 'abcd…jkl');
    expect(truncateMiddle('abcdefghijkl', 7), 'abc…jkl');
  });

  test('the result is exactly maxLength characters', () {
    final out = truncateMiddle('0123456789abcdef0123456789abcdef', 13);
    expect(out.runes.length, 13);
  });

  test('surrogate pairs are not split', () {
    final out = truncateMiddle('😀😀😀😀😀😀😀😀😀😀', 5);
    expect(out, '😀😀…😀😀');
  });
}
