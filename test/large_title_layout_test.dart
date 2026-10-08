// The large-title header: scrolling the body collapses it (the title settles
// centered, the collapsible section folds away), scrolling back expands it,
// and a body with too little to scroll never collapses, so the header can't
// fold away and leave nothing to bring it back with.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _width = 400;

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: _width, height: 600, child: child),
      ),
    ),
  ),
);

Widget _layout({
  int rows = 60,
  bool keepCollapsibleVisible = false,
  ScrollController? controller,
}) => LargeTitleLayout(
  title: 'Payments',
  actions: [
    TopbarActionButton(
      icon: LucideIcons.download300,
      semanticLabel: 'Export',
      onPressed: () {},
    ),
  ],
  pinned: TabSwitch(
    items: const [
      TabSwitchItem(label: 'Activity'),
      TabSwitchItem(label: 'Balances'),
    ],
    selectedIndex: 0,
    onTap: (_) {},
  ),
  collapsible: const Search(placeholder: 'Search...', size: SearchSize.topbar),
  keepCollapsibleVisible: keepCollapsibleVisible,
  body: ListView.builder(
    controller: controller,
    itemCount: rows,
    itemBuilder: (context, index) =>
        SizedBox(height: 50, child: Text('Row $index')),
  ),
);

double _titleCenterX(WidgetTester tester) =>
    tester.getCenter(find.text('Payments')).dx;

double _searchHeight(WidgetTester tester) => tester
    .getSize(
      find.ancestor(of: find.byType(Search), matching: find.byType(ClipRect)),
    )
    .height;

void main() {
  // The test surface is 800 wide, so the bar sits centered in it.
  final barLeft = (800 - _width) / 2;

  testWidgets('starts expanded: large title at the start, search shown', (
    tester,
  ) async {
    await pump(tester, _layout());

    final title = tester.getRect(find.text('Payments'));
    expect(title.left, barLeft + LargeTitleLayout.horizontalPadding);
    expect(title.height, 38);
    expect(_searchHeight(tester), greaterThan(0));
  });

  testWidgets('collapses once the body scrolls, and expands at the top', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pump(tester, _layout(controller: controller));

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(_titleCenterX(tester), barLeft + _width / 2);
    expect(tester.getSize(find.text('Payments')).height, 24);
    expect(_searchHeight(tester), 0);

    controller.jumpTo(0);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('Payments')).left,
      barLeft + LargeTitleLayout.horizontalPadding,
    );
    expect(_searchHeight(tester), greaterThan(0));
  });

  testWidgets('keeps the collapsible section while asked to', (tester) async {
    await pump(tester, _layout(keepCollapsibleVisible: true));

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(_titleCenterX(tester), barLeft + _width / 2);
    expect(_searchHeight(tester), greaterThan(0));
  });

  testWidgets('a body with little to scroll never collapses', (tester) async {
    await pump(tester, _layout(rows: 5));

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('Payments')).left,
      barLeft + LargeTitleLayout.horizontalPadding,
    );
  });

  testWidgets('horizontal scrolling leaves the header alone', (tester) async {
    await pump(
      tester,
      LargeTitleLayout(
        title: 'Payments',
        body: PageView(children: const [Text('One'), Text('Two')]),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('Payments')).left,
      barLeft + LargeTitleLayout.horizontalPadding,
    );
  });

  group('TabSwitch', () {
    testWidgets('reports taps on any tab, the selected one included', (
      tester,
    ) async {
      final taps = <int>[];
      await pump(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: TabSwitch(
            items: const [
              TabSwitchItem(label: 'History', showChevron: true),
              TabSwitchItem(label: 'Requests', showChevron: true),
            ],
            selectedIndex: 0,
            onTap: taps.add,
          ),
        ),
      );

      await tester.tap(find.text('History'));
      await tester.tap(find.text('Requests'));

      expect(taps, [0, 1]);
      expect(tester.getSize(find.byType(TabSwitch)).height, TabSwitch.height);
    });

    testWidgets('shows the chevron on the selected tab only', (tester) async {
      await pump(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: TabSwitch(
            items: const [
              TabSwitchItem(label: 'History', showChevron: true),
              TabSwitchItem(label: 'Requests', showChevron: true),
            ],
            selectedIndex: 1,
            onTap: (_) {},
          ),
        ),
      );

      final icons = tester.widgetList<AnimatedTrailingIcon>(
        find.byType(AnimatedTrailingIcon),
      );
      expect(icons.map((i) => i.visible), [false, true]);
    });
  });
}
