// The TextField inside AppTextField only spans the text line; the label row
// and the padding around it used to swallow taps, so the top of the box did
// nothing and the field felt unreliable.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<FocusNode> pumpField(
    WidgetTester tester, {
    bool enabled = true,
  }) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final controller = TextEditingController(text: 'Lunch');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: Center(
            child: AppTextField(
              controller: controller,
              focusNode: focusNode,
              label: 'Note',
              enabled: enabled,
              minLines: 1,
              maxLines: 3,
            ),
          ),
        ),
      ),
    );
    return focusNode;
  }

  Rect fieldBox(WidgetTester tester) => tester.getRect(
    find
        .descendant(
          of: find.byType(AppTextField),
          matching: find.byType(Container),
        )
        .first,
  );

  final probes = <String, Offset Function(Rect)>{
    'top padding': (r) => r.topCenter + const Offset(0, 2),
    'label row': (r) => r.topLeft + const Offset(20, 12),
    'left padding': (r) => r.centerLeft + const Offset(4, 0),
    'bottom padding': (r) => r.bottomCenter - const Offset(0, 2),
  };

  for (final MapEntry(key: name, value: at) in probes.entries) {
    testWidgets('tapping the $name focuses the field', (tester) async {
      final focusNode = await pumpField(tester);
      expect(focusNode.hasFocus, isFalse);

      await tester.tapAt(at(fieldBox(tester)));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
    });
  }

  testWidgets('tapping the label row keeps an already focused field focused', (
    tester,
  ) async {
    final focusNode = await pumpField(tester);
    focusNode.requestFocus();
    await tester.pump();

    await tester.tapAt(fieldBox(tester).topLeft + const Offset(20, 12));
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('a disabled field stays unfocused', (tester) async {
    final focusNode = await pumpField(tester, enabled: false);

    await tester.tapAt(fieldBox(tester).topCenter + const Offset(0, 2));
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });
}
