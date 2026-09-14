import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// The keys in [BitcrFonts] are strings, so nothing but a load proves they are
/// still right. They break on a package rename, and the wallet's PDF export
/// catches the resulting throw to fall back to Helvetica — meaning the only
/// symptom in production is a document in the wrong typeface. This test is the
/// signal that call site can't give.
void main() {
  const keys = <String, String>{
    'thin': BitcrFonts.thin,
    'extraLight': BitcrFonts.extraLight,
    'light': BitcrFonts.light,
    'regular': BitcrFonts.regular,
    'medium': BitcrFonts.medium,
    'semiBold': BitcrFonts.semiBold,
    'bold': BitcrFonts.bold,
    'extraBold': BitcrFonts.extraBold,
    'black': BitcrFonts.black,
  };

  TestWidgetsFlutterBinding.ensureInitialized();

  group('BitcrFonts keys resolve against the bundle', () {
    for (final MapEntry(key: name, value: assetKey) in keys.entries) {
      test(name, () async {
        final data = await rootBundle.load(assetKey);
        expect(data.lengthInBytes, greaterThan(0), reason: '$assetKey is empty');
      });
    }
  });

  test('family is namespaced, not a bare font name', () {
    expect(BitcrFonts.family, 'packages/bitcr_ui/Geist');
    expect(BitcrTheme.fontFamily, BitcrFonts.family);
  });
}
