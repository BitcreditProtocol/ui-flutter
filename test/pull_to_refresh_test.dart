// `RefreshIndicator` only fires when a scrollable below it reports an
// overscroll at the top. That is fine for a long list, but a screen whose
// content fits the viewport has nothing to overscroll — wrap it and the
// gesture silently does nothing, which looks identical to a broken refresh.
// `childScrolls: false` is the way out, and these pin both halves: the pull
// works on a short screen with it, and genuinely does not without it.

import 'dart:async';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(body: child),
    ),
  );

  /// A pull far enough past the trigger distance to arm the indicator.
  Future<void> pullDown(WidgetTester tester) async {
    await tester.fling(find.byType(PullToRefresh), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('a pull on a scrolling child runs onRefresh', (tester) async {
    var refreshed = 0;

    await pump(
      tester,
      PullToRefresh(
        onRefresh: () async => refreshed++,
        child: ListView(
          children: [for (var i = 0; i < 40; i++) ListTile(title: Text('$i'))],
        ),
      ),
    );

    await pullDown(tester);

    expect(refreshed, 1);
  });

  testWidgets('a short screen refreshes when childScrolls is false', (
    tester,
  ) async {
    var refreshed = 0;

    await pump(
      tester,
      PullToRefresh(
        onRefresh: () async => refreshed++,
        childScrolls: false,
        child: const Center(child: Text('Nothing to scroll')),
      ),
    );

    await pullDown(tester);

    expect(refreshed, 1);
  });

  testWidgets('the same short screen does nothing on the default', (
    tester,
  ) async {
    var refreshed = 0;

    await pump(
      tester,
      PullToRefresh(
        onRefresh: () async => refreshed++,
        child: const Center(child: Text('Nothing to scroll')),
      ),
    );

    await pullDown(tester);

    // Not a bug being enshrined — this is why childScrolls exists, and the
    // failure is silent, so it is worth a test that names it.
    expect(refreshed, 0);
  });

  testWidgets('the spinner waits for the future to resolve', (tester) async {
    final completer = Completer<void>();

    await pump(
      tester,
      PullToRefresh(
        onRefresh: () => completer.future,
        child: ListView(
          children: [for (var i = 0; i < 40; i++) ListTile(title: Text('$i'))],
        ),
      ),
    );

    await tester.fling(find.byType(PullToRefresh), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });

  testWidgets('the spinner is tinted to the brand', (tester) async {
    await pump(
      tester,
      PullToRefresh(
        onRefresh: () async {},
        child: ListView(
          children: [for (var i = 0; i < 40; i++) ListTile(title: Text('$i'))],
        ),
      ),
    );

    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );

    expect(indicator.color, BitcrColors.light.brand200);
    expect(indicator.backgroundColor, BitcrColors.light.elevation100);
  });
}
