// showBottomDrawer spans the full width, which is right on a phone but leaves
// a desktop window with a sheet as wide as the screen. The dashboard capped
// its own drawers at 480px and kept a private copy of the function to do it;
// the constraints parameter lets it use this one. The default must stay full
// width, or every wallet drawer would shrink to material's 640px cap.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _content = Key('drawer-content');

Future<double> _openWidth(
  WidgetTester tester, {
  BoxConstraints? constraints,
}) async {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showBottomDrawer<void>(
                context,
                constraints: constraints,
                builder: (_) => const SizedBox(
                  key: _content,
                  width: double.infinity,
                  height: 100,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return tester.getSize(find.byKey(_content)).width;
}

void main() {
  testWidgets('spans the full width by default', (tester) async {
    expect(await _openWidth(tester), 1400);
  });

  testWidgets('honours a max width', (tester) async {
    expect(
      await _openWidth(
        tester,
        constraints: const BoxConstraints(maxWidth: 480),
      ),
      480,
    );
  });
}
