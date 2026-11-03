// EmptyState stretched its content to the full height and then added 24px of
// padding below it, so it could always scroll by 24px and a ScrollHint around
// it showed its arrow on every empty page, however much room there was.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ScrollPosition> _pump(
  WidgetTester tester, {
  required double height,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: height,
            child: const EmptyState(
              illustration: Icon(Icons.inbox),
              title: 'No bills',
              subtitle: 'Bills you issue or receive show up here.',
            ),
          ),
        ),
      ),
    ),
  );

  return tester.state<ScrollableState>(find.byType(Scrollable)).position;
}

void main() {
  testWidgets('it does not scroll when the content fits', (tester) async {
    final position = await _pump(tester, height: 500);

    expect(position.maxScrollExtent, 0);
  });

  testWidgets('it still scrolls when the content does not fit', (tester) async {
    final position = await _pump(tester, height: 120);

    expect(position.maxScrollExtent, greaterThan(0));
  });
}
