import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Size> _buttonSize(WidgetTester tester, TargetPlatform platform) async {
  debugDefaultTargetPlatformOverride = platform;

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Center(
          child: Button(onPressed: () {}, child: const Text('Send')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final size = tester.getSize(find.byType(ElevatedButton));

  // Has to be cleared before the test body returns: the framework asserts all
  // foundation debug variables are unset, and it checks that before tearDowns.
  debugDefaultTargetPlatformOverride = null;

  return size;
}

void main() {
  testWidgets('Button is the same height on every host platform', (
    tester,
  ) async {
    final sizes = <TargetPlatform, Size>{};

    for (final platform in [
      TargetPlatform.iOS,
      TargetPlatform.android,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ]) {
      sizes[platform] = await _buttonSize(tester, platform);
    }

    debugPrint('measured: $sizes');

    // A design system can't have its controls change size with whatever
    // machine is rendering them.
    expect(
      sizes.values.map((s) => s.height).toSet(),
      hasLength(1),
      reason: 'Button height varies by host platform: $sizes',
    );
  });
}
