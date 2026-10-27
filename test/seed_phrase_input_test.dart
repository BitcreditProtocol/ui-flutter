// The wallet (twice: settings recovery and onboarding restore) and eBills each
// kept their own recovery-phrase grid. What made them hard to merge is the
// keyboard behaviour users rely on when typing twelve words on a phone: space
// jumps to the next word, backspace in an empty word goes back, and pasting
// the whole phrase into one field fills the grid instead of cramming twelve
// words into box one. These pin that behaviour, plus the `seed-word-N`
// identifiers the wallet's Appium suite types into.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  final controllers = List.generate(12, (_) => TextEditingController());
  final focusNodes = List.generate(12, (_) => FocusNode());
  var changes = 0;

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SeedPhraseInput(
            controllers: controllers,
            focusNodes: focusNodes,
            onChanged: () => changes++,
          ),
        ),
      ),
    ),
  );

  List<String> get words => controllers.map((c) => c.text).toList();
}

Finder _field(int index) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.identifier == 'seed-word-$index',
);

void main() {
  testWidgets('a trailing space trims the word and moves on', (tester) async {
    final h = _Harness();
    await h.pump(tester);

    await tester.enterText(find.byType(TextField).first, 'abandon ');
    await tester.pump();

    expect(h.controllers[0].text, 'abandon');
    expect(h.focusNodes[1].hasFocus, isTrue);
    expect(h.changes, greaterThan(0));
  });

  testWidgets('a pasted phrase spreads across the fields', (tester) async {
    final h = _Harness();
    await h.pump(tester);

    final phrase = List.generate(12, (i) => 'w$i').join(' ');
    await tester.enterText(find.byType(TextField).first, phrase);
    await tester.pump();

    expect(h.words, List.generate(12, (i) => 'w$i'));
    expect(h.focusNodes.any((f) => f.hasFocus), isFalse);
  });

  testWidgets('a paste mid-grid fills from there and stops at the end', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);

    await tester.enterText(
      find.byType(TextField).at(10),
      'ten eleven twelve thirteen',
    );
    await tester.pump();

    expect(h.words.sublist(10), ['ten', 'eleven']);
    expect(h.words.take(10).every((w) => w.isEmpty), isTrue);
  });

  testWidgets('backspace in an empty field goes back', (tester) async {
    final h = _Harness();
    await h.pump(tester);

    h.focusNodes[3].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(h.focusNodes[2].hasFocus, isTrue);
  });

  testWidgets('fields carry the seed-word identifiers', (tester) async {
    final h = _Harness();
    await h.pump(tester);

    expect(_field(0), findsOneWidget);
    expect(_field(11), findsOneWidget);
  });
}
