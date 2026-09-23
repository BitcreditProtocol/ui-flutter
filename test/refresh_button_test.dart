// The spin only runs while loading, and a loading button swallows taps.

import 'dart:ui' show Tristate;

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpButton(WidgetTester tester, Widget button) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: Center(child: button)),
  ),
);

/// The button's own spinning icon — `MaterialApp` puts other
/// [RotationTransition]s in the tree, so this has to be scoped.
final spinFinder = find.descendant(
  of: find.byType(RefreshButton),
  matching: find.byType(RotationTransition),
);

/// The turns the icon is currently rotated by.
double turnsOf(WidgetTester tester) =>
    tester.widget<RotationTransition>(spinFinder).turns.value;

void main() {
  testWidgets('taps through when idle', (tester) async {
    var taps = 0;
    await pumpButton(tester, RefreshButton(onPressed: () => taps++));

    await tester.tap(find.byType(RefreshButton));
    expect(taps, 1);
  });

  testWidgets('swallows taps while loading, so a refresh cannot double-fire', (
    tester,
  ) async {
    var taps = 0;
    await pumpButton(
      tester,
      RefreshButton(isLoading: true, onPressed: () => taps++),
    );

    await tester.tap(find.byType(RefreshButton));
    expect(taps, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('the spin', () {
    testWidgets('does not run when idle', (tester) async {
      await pumpButton(tester, const RefreshButton());

      expect(turnsOf(tester), 0);
      await tester.pump(const Duration(milliseconds: 500));
      expect(turnsOf(tester), 0);
    });

    testWidgets('runs while loading', (tester) async {
      await pumpButton(tester, const RefreshButton(isLoading: true));

      expect(turnsOf(tester), 0);
      await tester.pump(const Duration(milliseconds: 500));
      expect(turnsOf(tester), closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 250));
      expect(turnsOf(tester), closeTo(0.75, 0.01));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('starts when isLoading flips on', (tester) async {
      await pumpButton(tester, const RefreshButton());
      await tester.pump(const Duration(milliseconds: 300));
      expect(turnsOf(tester), 0);

      await pumpButton(tester, const RefreshButton(isLoading: true));
      await tester.pump(const Duration(milliseconds: 500));
      expect(turnsOf(tester), closeTo(0.5, 0.01));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('finishes its turn when isLoading flips off', (tester) async {
      await pumpButton(tester, const RefreshButton(isLoading: true));
      await tester.pump(const Duration(milliseconds: 500));
      expect(turnsOf(tester), closeTo(0.5, 0.01));

      // Stopping mid-turn animates on to a full turn rather than snapping.
      await pumpButton(tester, const RefreshButton());
      await tester.pump(const Duration(milliseconds: 250));
      expect(turnsOf(tester), closeTo(0.75, 0.01));

      await tester.pumpAndSettle();
      expect(turnsOf(tester), 0);
    });
  });

  group('the label', () {
    testWidgets('renders before the icon when given', (tester) async {
      await pumpButton(tester, const RefreshButton(label: 'Refresh'));

      expect(find.text('Refresh'), findsOneWidget);
      final label = tester.getCenter(find.text('Refresh'));
      final icon = tester.getCenter(spinFinder);
      expect(label.dx, lessThan(icon.dx));
    });

    testWidgets('is icon-only when omitted', (tester) async {
      await pumpButton(tester, const RefreshButton());

      expect(find.byType(Text), findsNothing);
    });
  });

  group('the tooltip', () {
    testWidgets('is attached only when given', (tester) async {
      await pumpButton(tester, const RefreshButton());
      expect(find.byType(Tooltip), findsNothing);

      await pumpButton(tester, const RefreshButton(tooltip: 'Check for news'));
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('disabled', () {
    testWidgets('swallows taps', (tester) async {
      var taps = 0;
      await pumpButton(
        tester,
        RefreshButton(disabled: true, onPressed: () => taps++),
      );

      await tester.tap(find.byType(RefreshButton));
      expect(taps, 0);
    });

    testWidgets('dims the icon', (tester) async {
      await pumpButton(tester, const RefreshButton());
      final enabled = tester.widget<Icon>(find.byType(Icon)).color!;

      await pumpButton(tester, const RefreshButton(disabled: true));
      final greyed = tester.widget<Icon>(find.byType(Icon)).color!;

      expect(greyed.a, lessThan(enabled.a));
    });
  });

  group('size', () {
    testWidgets('drives the icon size', (tester) async {
      for (final size in RefreshButtonSize.values) {
        await pumpButton(tester, RefreshButton(size: size));
        expect(
          tester.widget<Icon>(find.byType(Icon)).size,
          RefreshButton.iconSizeOf(size),
          reason: size.name,
        );
      }
    });

    testWidgets('md matches the reference — 24px icon, xs text', (
      tester,
    ) async {
      await pumpButton(tester, const RefreshButton(label: 'Refresh'));

      expect(tester.widget<Icon>(find.byType(Icon)).size, 24);
      expect(tester.widget<Text>(find.text('Refresh')).style!.fontSize, 12);
    });

    testWidgets('iconSize overrides it', (tester) async {
      await pumpButton(
        tester,
        const RefreshButton(size: RefreshButtonSize.xs, iconSize: 40),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).size, 40);
    });
  });

  group('color', () {
    testWidgets('applies to both the icon and the label', (tester) async {
      await pumpButton(
        tester,
        const RefreshButton(label: 'Refresh', color: Colors.teal),
      );

      expect(tester.widget<Icon>(find.byType(Icon)).color, Colors.teal);
      expect(
        tester.widget<Text>(find.text('Refresh')).style!.color,
        Colors.teal,
      );
    });

    testWidgets('labelStyle merges over the size style, keeping the color', (
      tester,
    ) async {
      await pumpButton(
        tester,
        const RefreshButton(
          label: 'Refresh',
          color: Colors.teal,
          labelStyle: TextStyle(fontWeight: FontWeight.w700),
        ),
      );

      final style = tester.widget<Text>(find.text('Refresh')).style!;
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, Colors.teal);
      expect(style.fontSize, 12);
    });
  });

  group('spinDuration', () {
    testWidgets('sets how long one turn takes', (tester) async {
      await pumpButton(
        tester,
        const RefreshButton(
          isLoading: true,
          spinDuration: Duration(milliseconds: 400),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(turnsOf(tester), closeTo(0.5, 0.01));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('semantics', () {
    testWidgets('names an icon-only button that has no label or tooltip', (
      tester,
    ) async {
      await pumpButton(tester, const RefreshButton());
      expect(find.bySemanticsLabel('Refresh'), findsNothing);

      await pumpButton(tester, const RefreshButton(semanticLabel: 'Refresh'));
      expect(find.bySemanticsLabel('Refresh'), findsOneWidget);
    });

    testWidgets('reports disabled to the accessibility tree', (tester) async {
      await pumpButton(
        tester,
        const RefreshButton(semanticLabel: 'Refresh', disabled: true),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Refresh'));
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
    });
  });
}
