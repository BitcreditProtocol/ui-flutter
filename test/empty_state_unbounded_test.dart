// EmptyState fills the height it is given so it can centre or anchor its
// illustration. As an item of a ListView that height is infinite, and the
// fill threw "BoxConstraints forces an infinite height" — the dashboard worked
// around it with fixed 320px boxes. With unbounded height it now shrinks to
// its content instead, so it can sit in a scrolling list as-is.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inside a ListView it sizes to its content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: ListView(
            children: const [
              EmptyState(
                illustration: Icon(Icons.inbox),
                title: 'No bills',
                subtitle: 'Bills you issue or receive show up here.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final height = tester.getSize(find.byType(EmptyState)).height;
    expect(height, greaterThan(EmptyState.imageHeight));
    expect(height, lessThan(300));
  });
}
