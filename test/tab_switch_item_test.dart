// eBills kept its own tab control only because TabSwitch had no way to show a
// tab that can't be picked (paying an anonymous contact "by name") or a count
// next to a label ("Docs 3"). A disabled tab still renders, so the user sees
// the option exists, but swallows the tap — the caller's onTap must never see
// it, or the selection would jump to a tab the screen can't show.

import 'dart:ui' show Tristate;

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<int>> _pump(WidgetTester tester, List<TabSwitchItem> items) async {
  final taps = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: TabSwitch(items: items, selectedIndex: 0, onTap: taps.add),
      ),
    ),
  );
  return taps;
}

void main() {
  testWidgets('a disabled tab ignores taps and is dimmed', (tester) async {
    final taps = await _pump(tester, const [
      TabSwitchItem(label: 'Bearer'),
      TabSwitchItem(label: 'Name', enabled: false),
    ]);

    await tester.tap(find.text('Name'));
    await tester.tap(find.text('Bearer'));

    expect(taps, [0]);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Name'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.5);
  });

  // The contact picker must not preselect "bearer" or "name" — the user has
  // to choose, and the Select button stays disabled until they do.
  testWidgets('a null selectedIndex selects nothing', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: TabSwitch(
            items: const [
              TabSwitchItem(label: 'Bearer'),
              TabSwitchItem(label: 'Name'),
            ],
            selectedIndex: null,
            onTap: taps.add,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedAlign), findsNothing);
    for (final label in ['Bearer', 'Name']) {
      final semantics = tester.getSemantics(find.text(label));
      expect(semantics.flagsCollection.isSelected, Tristate.isFalse);
    }
    await tester.tap(find.text('Name'));
    expect(taps, [1]);
  });

  testWidgets('badge and icon render after the label', (tester) async {
    await _pump(tester, const [
      TabSwitchItem(label: 'Front'),
      TabSwitchItem(label: 'Docs', badge: '3', icon: Icons.close),
    ]);

    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('3')).dx,
      greaterThan(tester.getTopRight(find.text('Docs')).dx),
    );
  });
}
