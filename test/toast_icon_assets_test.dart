// The toast badges are the one piece of artwork this package does not draw
// itself: they are SVGs exported from the design file, and `ToastIcon`
// recolours them by matching the exact hex values the export bakes in. A
// re-export that changes a fill — or an asset that silently stops being
// bundled — leaves the badge rendering light-palette colours in the dark
// theme, and nothing at the call site would say so. These pin both halves of
// that contract.

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Deliberately literals rather than reads off `ToastIcon`: a test that took
  // them from the widget could not catch the widget and the artwork drifting
  // apart, which is the whole failure this guards.
  const mark = '#F6F2E7';
  const badges = <String, String>{
    'info': '#1B0F00',
    'success': '#006F29',
    'warning': '#AE5F00',
    'error': '#A32B16',
  };

  for (final MapEntry(key: variant, value: badge) in badges.entries) {
    group('toast_$variant.svg', () {
      late String svg;

      setUpAll(() async {
        svg = (await rootBundle.loadString(
          'packages/bitcr_ui/assets/icons/toast_$variant.svg',
        )).toUpperCase();
      });

      test('is bundled', () {
        expect(svg, isNotEmpty);
      });

      test('still carries the badge fill ToastIcon remaps', () {
        expect(svg, contains(badge));
      });

      test('still knocks its mark out in the exported mark colour', () {
        expect(svg, contains(mark));
      });
    });
  }
}
