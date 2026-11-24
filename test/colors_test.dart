import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Values are the Light/Dark modes of the "Primitives" collection in the
// Nodes Figma library, as used by the Wallet file's Colors sheet. These are
// the tokens that drifted before; a change here should start from Figma.
void main() {
  test('light tokens match the Nodes library', () {
    const c = BitcrColors.light;
    expect(c.text200, const Color(0xFF766D60));
    expect(c.divider75, const Color(0xFFDCD8CD));
    expect(c.elevation300, const Color(0xFFE8E4D9));
    expect(c.elevation400, const Color(0xFFD1CCC1));
  });

  test('dark tokens match the Nodes library', () {
    const c = BitcrColors.dark;
    expect(c.text200, const Color(0xFF808080));
    expect(c.divider75, const Color(0xFF282625));
    expect(c.elevation300, const Color(0xFF242424));
    expect(c.elevation400, const Color(0xFF2E2E2E));
  });

  // Design inserted a lighter elevation300 and moved the old one up a step.
  // The seed chips are drawn with Elevation/400 in Figma, so they must not
  // follow elevation300 to the lighter value.
  testWidgets('seed word chips use elevation400', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: const Scaffold(
          body: SeedWord(index: 0, word: 'abandon', revealed: false),
        ),
      ),
    );
    final fills = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>();
    expect(fills, contains(BitcrColors.light.elevation400));
    expect(fills, isNot(contains(BitcrColors.light.elevation300)));
  });
}
