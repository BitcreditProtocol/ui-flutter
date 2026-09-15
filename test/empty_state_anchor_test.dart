// `EmptyStateAnchor` exists because centring an empty state inside whatever
// space the list was left puts the illustration somewhere different on every
// screen — a screen whose header grows a search field pushes its illustration
// down, and two lists side by side don't line up. Anchored, the illustration
// hangs a fixed distance below the top of the body instead, and the header
// height stops mattering.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A screen body with a header of [headerHeight] above an anchored empty
/// state, or an unanchored one when [anchored] is false.
Future<void> pumpBody(
  WidgetTester tester, {
  required double headerHeight,
  bool anchored = true,
  double? illustrationTop,
}) async {
  final emptyState = EmptyState(
    asset: 'assets/images/no_payments.png',
    title: 'No payments yet',
    subtitle: 'Your payments will be listed here once you make one.',
    illustrationTop: illustrationTop ?? EmptyState.defaultIllustrationTop,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final column = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: headerHeight),
                Expanded(child: emptyState),
              ],
            );

            return anchored
                ? EmptyStateAnchor(
                    bodyHeight: constraints.maxHeight,
                    child: column,
                  )
                : column;
          },
        ),
      ),
    ),
  );

  // The illustration is app-owned and the test bundle has no copy of it. That
  // is not what any of this is measuring, and the failed load leaves the
  // layout alone.
  tester.takeException();
}

double illustrationTop(WidgetTester tester) =>
    tester.getTopLeft(find.byType(Image)).dy;

void main() {
  testWidgets('anchored, the illustration ignores the header height', (
    tester,
  ) async {
    await pumpBody(tester, headerHeight: 0);
    expect(illustrationTop(tester), EmptyState.defaultIllustrationTop);

    // A search field and a row of filter badges appearing above it.
    await pumpBody(tester, headerHeight: 140);
    expect(illustrationTop(tester), EmptyState.defaultIllustrationTop);
  });

  testWidgets('a screen may move it without moving the others', (tester) async {
    await pumpBody(tester, headerHeight: 48, illustrationTop: 260);
    expect(illustrationTop(tester), 260);
  });

  testWidgets(
    'a header taller than the inset pins it to the top rather than pushing '
    'it off-screen',
    (tester) async {
      await pumpBody(
        tester,
        headerHeight: EmptyState.defaultIllustrationTop + 80,
      );

      expect(
        illustrationTop(tester),
        EmptyState.defaultIllustrationTop + 80,
        reason: 'clamped to the top of the space the list was given',
      );
    },
  );

  testWidgets('without an anchor it centres, and so it drifts', (tester) async {
    await pumpBody(tester, headerHeight: 0, anchored: false);
    final withoutHeader = illustrationTop(tester);

    await pumpBody(tester, headerHeight: 140, anchored: false);
    final withHeader = illustrationTop(tester);

    // This is the drift the anchor exists to remove: centred in whatever the
    // list was left, the same empty state sits somewhere else on a screen with
    // a taller header. Anchored, the first test above shows it does not move.
    expect(withHeader, greaterThan(withoutHeader));
    expect(withoutHeader, isNot(EmptyState.defaultIllustrationTop));
  });
}
