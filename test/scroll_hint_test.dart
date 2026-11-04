import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ScrollController> _pump(WidgetTester tester, {int lines = 60}) async {
  final controller = ScrollController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: ScrollHint(
          semanticLabel: 'Scroll to the end',
          child: ListView(
            controller: controller,
            children: [for (var i = 0; i < lines; i++) Text('line $i')],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(ScrollHint.duration);

  return controller;
}

double _arrowOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.byIcon(LucideIcons.chevronDown),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    )
    .opacity;

void main() {
  testWidgets('content that shrinks to fit drops the hint at once', (
    tester,
  ) async {
    final lines = ValueNotifier(60);
    addTearDown(lines.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: ScrollHint(
            child: SizedBox.expand(
              child: SingleChildScrollView(
                child: ValueListenableBuilder(
                  valueListenable: lines,
                  builder: (context, count, _) => Column(
                    children: [for (var i = 0; i < count; i++) Text('line $i')],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(ScrollHint.duration);
    }

    List<double> painted() => [
      for (final opacity in tester.renderObjectList<RenderAnimatedOpacity>(
        find.descendant(
          of: find.byType(ScrollHint),
          matching: find.byType(AnimatedOpacity),
        ),
      ))
        opacity.opacity.value,
    ];

    expect(painted().skip(1), everyElement(1));

    lines.value = 2;
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    // a fade-out over the shrunken page flashed the band and the arrow
    expect(painted(), everyElement(0));
  });

  testWidgets('the arrow shows while there is more below', (tester) async {
    await _pump(tester);

    expect(_arrowOpacity(tester), 1);
  });

  testWidgets('content that fits shows no arrow', (tester) async {
    await _pump(tester, lines: 2);

    expect(_arrowOpacity(tester), 0);
  });

  testWidgets('the arrow scrolls to the end and then goes', (tester) async {
    final controller = await _pump(tester);

    await tester.tap(find.byIcon(LucideIcons.chevronDown));
    await tester.pumpAndSettle();

    expect(controller.offset, controller.position.maxScrollExtent);
    expect(_arrowOpacity(tester), 0);
  });

  testWidgets('the band under the fade covers the full width', (tester) async {
    await _pump(tester);

    final band = tester.getSize(
      find
          .descendant(
            of: find.byType(ScrollHint),
            matching: find.byType(ColoredBox),
          )
          .last,
    );

    expect(band.width, tester.getSize(find.byType(ScrollHint)).width);
    expect(band.height, greaterThan(0));
  });

  testWidgets('a fixed button below the scroll view stays clear', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BitcrTheme.light,
        home: Scaffold(
          body: ScrollHint(
            bottom: 20,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [for (var i = 0; i < 60; i++) Text('line $i')],
                  ),
                ),
                const SizedBox(key: Key('button'), height: 60),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(ScrollHint.duration);

    final button = tester.getRect(find.byKey(const Key('button')));
    final arrow = tester.getRect(find.byIcon(LucideIcons.chevronDown));
    final band = tester.getRect(
      find
          .descendant(
            of: find.byType(ScrollHint),
            matching: find.byType(ColoredBox),
          )
          .last,
    );

    expect(arrow.bottom, lessThanOrEqualTo(button.top));
    expect(band.bottom, lessThanOrEqualTo(button.top));
  });

  testWidgets('a swapped scroll view is followed, not read when gone', (
    tester,
  ) async {
    Widget page(String key) => MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: ScrollHint(
          child: ListView(
            key: Key(key),
            children: [for (var i = 0; i < 60; i++) Text('$key $i')],
          ),
        ),
      ),
    );

    await tester.pumpWidget(page('loading'));
    await tester.pumpWidget(page('content'));
    await tester.pump();
    await tester.pump(ScrollHint.duration);

    expect(tester.takeException(), isNull);
    expect(_arrowOpacity(tester), 1);
  });
}
