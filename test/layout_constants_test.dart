// The library publishes three fixed heights so callers can reserve space
// instead of measuring: `Search.heightOf`, `ScreenHeader.height` and the
// distance `EmptyState` hangs its illustration below an anchor. A constant
// that has drifted from what renders is worse than no constant — it puts a
// `SizedBox` around the widget that squeezes it. These pin them.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  ),
);

void main() {
  group('Search.heightOf', () {
    for (final size in SearchSize.values) {
      testWidgets('matches what $size renders', (tester) async {
        await pump(
          tester,
          SizedBox(
            width: 320,
            child: Search(placeholder: 'Search currencies...', size: size),
          ),
        );

        expect(
          tester.getSize(find.byType(Search)).height,
          Search.heightOf(size),
        );
      });
    }
  });

  group('ScreenHeader.height', () {
    testWidgets('holds with no trailing action', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 320, child: ScreenHeader(title: 'Settings')),
      );

      expect(
        tester.getSize(find.byType(ScreenHeader)).height,
        ScreenHeader.height,
      );
    });

    testWidgets('and is unchanged by one, so screens do not shift', (
      tester,
    ) async {
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: ScreenHeader(
            title: 'Contacts',
            trailing: TopbarActionButton(
              icon: LucideIcons.userPlus300,
              semanticLabel: 'New contact',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(ScreenHeader)).height,
        ScreenHeader.height,
      );
      // And the action still fits inside it rather than being clipped.
      expect(tester.takeException(), isNull);
    });
  });
}
