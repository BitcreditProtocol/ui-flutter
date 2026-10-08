// The bar's variants: the middle stays centered on the bar however wide the
// trailing side gets, several actions sit side by side, a text button fits
// the trail, the search variant fills the width, and the wallet chip and logo
// render at the sizes the design gives them.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _barWidth = 360;

Future<void> pump(WidgetTester tester, Widget child, {ThemeData? theme}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme ?? BitcrTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: _barWidth, child: child),
          ),
        ),
      ),
    );

Widget _back() => NavigateBackButton(onPressed: () {});

Widget _action(IconData icon) =>
    TopbarActionButton(icon: icon, onPressed: () {});

void main() {
  group('Topbar', () {
    testWidgets('is slotSize tall', (tester) async {
      await pump(tester, Topbar(lead: _back(), middle: const Text('Title')));

      expect(tester.getSize(find.byType(Topbar)).height, 44);
    });

    testWidgets('centers the middle on the bar with no trail', (tester) async {
      await pump(tester, Topbar(lead: _back(), middle: const Text('Title')));

      expect(tester.getCenter(find.text('Title')).dx, _barWidth / 2);
    });

    testWidgets('keeps the middle centered behind several actions', (
      tester,
    ) async {
      await pump(
        tester,
        Topbar(
          lead: _back(),
          middle: const Text('Title'),
          actions: [_action(LucideIcons.share), _action(LucideIcons.pencil)],
        ),
      );

      expect(tester.getCenter(find.text('Title')).dx, _barWidth / 2);
    });

    testWidgets('spaces actions by actionSpacing, flush to the end', (
      tester,
    ) async {
      await pump(
        tester,
        Topbar(
          lead: _back(),
          actions: [_action(LucideIcons.share), _action(LucideIcons.pencil)],
        ),
      );

      final buttons = find.byType(TopbarActionButton);
      final first = tester.getRect(buttons.at(0));
      final second = tester.getRect(buttons.at(1));

      expect(second.left - first.right, Topbar.actionSpacing);
      expect(second.right, _barWidth);
    });

    testWidgets('slides a long middle clear of the side slots', (tester) async {
      await pump(
        tester,
        Topbar(
          lead: _back(),
          middle: const Text(
            'A title long enough to run into the trailing actions',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [_action(LucideIcons.share), _action(LucideIcons.pencil)],
        ),
      );

      final title = tester.getRect(find.byType(Text));
      final firstAction = tester.getRect(find.byType(TopbarActionButton).first);

      expect(title.left, greaterThanOrEqualTo(44));
      expect(title.right, lessThanOrEqualTo(firstAction.left));
    });

    testWidgets('fits a text button in the trail at button height', (
      tester,
    ) async {
      var tapped = false;
      await pump(
        tester,
        Topbar(
          lead: _back(),
          trail: TopbarTextButton(
            label: 'Skip',
            onPressed: () => tapped = true,
          ),
        ),
      );

      final skip = tester.getRect(find.byType(TopbarTextButton));
      expect(skip.height, TopbarActionButton.buttonSize);
      expect(skip.right, _barWidth);

      await tester.tap(find.text('Skip'));
      expect(tapped, isTrue);
    });

    testWidgets('search fills the width 12 after the lead', (tester) async {
      await pump(
        tester,
        const Topbar.search(
          lead: Avatar(name: 'Alice', size: AvatarSize.nav),
          search: Search(placeholder: 'Search...', size: SearchSize.topbar),
        ),
      );

      final search = tester.getRect(find.byType(Search));
      expect(search.left, 44 + 12);
      expect(search.right, _barWidth);
      expect(search.height, Search.topbarHeight);
    });
  });

  group('IdentityChip', () {
    testWidgets('is height tall, with or without a chevron', (tester) async {
      for (final showChevron in [false, true]) {
        await pump(
          tester,
          Center(
            child: IdentityChip(name: 'Personal', showChevron: showChevron),
          ),
        );

        expect(
          tester.getSize(find.byType(IdentityChip)).height,
          IdentityChip.height,
        );
      }
    });

    testWidgets('holds a 24px avatar', (tester) async {
      await pump(tester, const Center(child: IdentityChip(name: 'Personal')));

      expect(tester.getSize(find.byType(Avatar)), const Size(24, 24));
    });
  });

  group('BitcreditLogo', () {
    for (final (name, theme) in [
      ('light', BitcrTheme.light),
      ('dark', BitcrTheme.dark),
    ]) {
      testWidgets('renders at the design size in $name mode', (tester) async {
        await pump(tester, const Topbar(middle: BitcreditLogo()), theme: theme);
        await tester.pumpAndSettle();

        expect(
          tester.getSize(find.byType(BitcreditLogo)),
          const Size(BitcreditLogo.width, BitcreditLogo.height),
        );
        expect(tester.getCenter(find.byType(BitcreditLogo)).dx, _barWidth / 2);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
