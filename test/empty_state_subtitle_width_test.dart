// The subtitle wraps at a narrow fixed width, so a sentence that fits a phone
// in one or two lines took three. subtitleWidth lets a screen widen it.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _subtitle = 'Start creating a bill and distribute it to your contacts';

Future<void> _pumpSubtitle(
  WidgetTester tester, {
  double width = EmptyState.defaultSubtitleWidth,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: EmptyState(
          illustration: const Icon(Icons.inbox),
          title: 'No notifications',
          subtitle: _subtitle,
          subtitleWidth: width,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('by default the subtitle wraps at the narrow width', (
    tester,
  ) async {
    await _pumpSubtitle(tester);

    expect(tester.getSize(find.text(_subtitle)).width, lessThanOrEqualTo(216));
  });

  testWidgets('an infinite subtitleWidth takes the full width', (tester) async {
    await _pumpSubtitle(tester, width: double.infinity);

    // 390 wide, minus EmptyState's 24px horizontal padding on each side.
    expect(tester.getSize(find.text(_subtitle)).width, 342);
  });
}
