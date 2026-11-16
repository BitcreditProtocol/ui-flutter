import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 300, child: child),
      ),
    ),
  ),
);

void main() {
  group('Skeleton', () {
    testWidgets('fills the width it is given', (tester) async {
      await pump(tester, const Skeleton(height: 12));

      expect(tester.getSize(find.byType(Skeleton)), const Size(300, 12));
    });

    testWidgets('takes a fixed width', (tester) async {
      await pump(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: Skeleton(width: 80, height: 12),
        ),
      );

      expect(tester.getSize(find.byType(Container)).width, 80);
    });

    testWidgets('stops short at a width factor, from the start', (
      tester,
    ) async {
      await pump(tester, const Skeleton(height: 12, widthFactor: 0.5));

      final block = tester.getRect(find.byType(Container));

      expect(block.width, 150);
      expect(block.left, 0);
    });

    testWidgets('is hidden from semantics', (tester) async {
      await pump(tester, const Skeleton(height: 12));

      expect(
        find.descendant(
          of: find.byType(Skeleton),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('pulses its opacity', (tester) async {
      await pump(tester, const Skeleton(height: 12));

      double opacity() => tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;

      expect(opacity(), 1);

      await tester.pump(const Duration(milliseconds: 500));

      expect(opacity(), lessThan(1));

      await tester.pump(const Duration(milliseconds: 500));

      expect(opacity(), closeTo(0.5, 0.01));
    });

    testWidgets('uses elevation200 unless given a color', (tester) async {
      await pump(tester, const Skeleton(height: 12));

      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration!
              as BoxDecoration;

      expect(decoration.color, BitcrColors.light.elevation200);
    });
  });
}
