import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/countries.dart';

Widget _app(TextEditingController controller, {required bool scrolls}) {
  final field = CountrySelector(
    controller: controller,
    label: 'Country',
    countries: testCountries,
    searchPlaceholder: 'Search for a country...',
    noResultsLabel: 'No country found.',
  );

  return MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: scrolls
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 620),
                    field,
                    const SizedBox(height: 300),
                  ],
                ),
              )
            : Column(
                children: [const Spacer(), field, const SizedBox(height: 60)],
              ),
      ),
    ),
  );
}

void main() {
  for (final scrolls in [false, true]) {
    testWidgets('a picker near the bottom stays usable above the keyboard '
        '(scrolling: $scrolls)', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller, scrolls: scrolls));
      await tester.tap(find.text('Country'));
      await tester.pump();

      tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final search = find.byType(TextField).last;
      final keyboardTop = 812 - 336.0;

      expect(tester.getRect(search).top, greaterThanOrEqualTo(0));
      expect(tester.getRect(search).bottom, lessThanOrEqualTo(keyboardTop));

      await tester.enterText(search, 'Portu');
      await tester.pump();
      await tester.pump();
      expect(
        tester.getRect(find.text('Portugal')).bottom,
        lessThanOrEqualTo(keyboardTop),
      );

      await tester.tap(find.text('Portugal'));
      await tester.pump();

      expect(controller.text, 'PT');
    });
  }

  testWidgets(
    'on a phone the list opens below the field, clear of the keyboard',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller, scrolls: true));
      await tester.tap(find.text('Country'));
      await tester.pump();

      tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final trigger = tester.getRect(find.text('Country'));
      final search = tester.getRect(find.byType(TextField).last);
      final keyboardTop = 812 - 336.0;

      expect(search.top, greaterThan(trigger.bottom));
      expect(search.bottom, lessThanOrEqualTo(keyboardTop));
      expect(
        tester.getRect(find.text('Albania')).bottom,
        lessThanOrEqualTo(keyboardTop),
      );

      debugDefaultTargetPlatformOverride = null;
    },
  );
}
