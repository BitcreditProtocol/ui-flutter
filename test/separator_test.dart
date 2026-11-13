import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  double devicePixelRatio = 1,
}) => tester.pumpWidget(
  MediaQuery(
    data: MediaQueryData(devicePixelRatio: devicePixelRatio),
    child: MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 200, child: child),
        ),
      ),
    ),
  ),
);

RenderObject rule(WidgetTester tester) => tester.renderObject(
  find.descendant(
    of: find.byType(Separator),
    matching: find.byType(CustomPaint),
  ),
);

void main() {
  group('Separator', () {
    testWidgets('is one logical pixel tall', (tester) async {
      await pump(tester, const Separator());

      expect(tester.getSize(find.byType(Separator)), const Size(200, 1));
    });

    testWidgets('paints divider75 unless given a color', (tester) async {
      await pump(tester, const Separator());

      expect(
        rule(tester),
        paints..rect(
          rect: const Rect.fromLTWH(0, 0, 200, 1),
          color: BitcrColors.light.divider75,
        ),
      );
    });

    testWidgets('covers whole device pixels at a fractional ratio', (
      tester,
    ) async {
      await pump(
        tester,
        const Separator(color: Color(0xFF000000)),
        devicePixelRatio: 2.625,
      );

      expect(
        rule(tester),
        paints..rect(
          rect: const Rect.fromLTWH(0, 0, 200, 3 / 2.625),
          color: const Color(0xFF000000),
        ),
      );
    });

    testWidgets('insets from the start edge', (tester) async {
      await pump(tester, const Separator(indent: 16));

      final painted = tester.getRect(
        find.descendant(
          of: find.byType(Separator),
          matching: find.byType(CustomPaint),
        ),
      );

      expect(painted.left, 16);
      expect(painted.width, 184);
    });
  });
}
