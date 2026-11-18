// A wallet named "Wallet -" showed "W-" in its avatar: initials took each
// word's first character, whatever it was. They now come only from letters and
// digits.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final (name, initials) in [
    ('Wallet 2', 'W2'),
    ('Ada Lovelace', 'AL'),
    ('Wallet -', 'W'),
    ('Wallet - test', 'WT'),
    ('(Savings) #1', 'S1'),
    ('-Main', 'M'),
    ('  ', ''),
    ('- _ !', ''),
    ('Кошелёк один', 'КО'),
    ('ärzte kasse', 'ÄK'),
  ]) {
    test('"$name" -> "$initials"', () {
      expect(avatarInitials(name), initials);
    });
  }

  testWidgets('a name with no letters or digits shows the placeholder icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: const Scaffold(
          body: Center(
            child: Avatar(name: '- -', placeholderIcon: Icons.add_a_photo),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
  });
}
