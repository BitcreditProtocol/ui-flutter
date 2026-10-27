// The wallet's contact form kept its own ContactAvatar only so it could show a
// glyph before the user has typed a name. A blank name otherwise renders an
// empty circle, so the placeholder applies exactly while the name is blank and
// gives way to initials as soon as there is something to take them from.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Avatar avatar) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: Center(child: avatar)),
  ),
);

void main() {
  testWidgets('a blank name shows the placeholder icon', (tester) async {
    await _pump(
      tester,
      const Avatar(name: '  ', placeholderIcon: Icons.add_a_photo),
    );

    expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
  });

  testWidgets('a name wins over the placeholder icon', (tester) async {
    await _pump(
      tester,
      const Avatar(name: 'Ada Lovelace', placeholderIcon: Icons.add_a_photo),
    );

    expect(find.byIcon(Icons.add_a_photo), findsNothing);
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('an anon avatar keeps its glyph without a placeholder', (
    tester,
  ) async {
    await _pump(tester, const Avatar(name: '', kind: AvatarKind.anon));

    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
