// Three gaps that only show up with a pointer or a long string: a settings
// value that pushed its own label out, a drawer close button with no hover
// label, and a search field that could not take focus on open.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('SettingsSectionItem value', () {
    testWidgets('a long one truncates instead of pushing the label out', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pump(
        tester,
        SettingsSectionItem(
          icon: LucideIcons.banknote300,
          label: 'Display currency',
          // A real currency name, and the case that broke this.
          value: 'Netherlands Antillean Guilder',
          onTap: () {},
        ),
      );

      expect(tester.takeException(), isNull);
      // The label is still whole; it is the value that gives way.
      expect(find.text('Display currency'), findsOneWidget);
      final label = tester.renderObject<RenderParagraph>(
        find.text('Display currency'),
      );
      expect(label.didExceedMaxLines, isFalse);
    });

    testWidgets('a short one still sits against the chevron', (tester) async {
      tester.view.physicalSize = const Size(400, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pump(
        tester,
        SettingsSectionItem(
          icon: LucideIcons.banknote300,
          label: 'Display currency',
          value: 'CHF',
          onTap: () {},
        ),
      );

      // Bounding the value must not have pulled it off the right-hand edge:
      // it belongs beside the chevron, not adrift in the middle of the row.
      final value = tester.getRect(find.text('CHF'));
      final chevron = tester.getRect(find.byIcon(LucideIcons.chevronRight300));
      expect(chevron.left - value.right, lessThan(16));
    });
  });

  group('SettingsSectionItem is a control, not text', () {
    testWidgets('answers a pointer with an ink response', (tester) async {
      var taps = 0;
      await pump(
        tester,
        SettingsSectionItem(
          icon: LucideIcons.banknote300,
          label: 'Display currency',
          onTap: () => taps++,
        ),
      );

      // A bare `GestureDetector` gave a desktop no hover and no press: the row
      // read as text until you clicked it and the screen changed.
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(SettingsSectionItem));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('a disabled row still refuses the tap', (tester) async {
      var taps = 0;
      await pump(
        tester,
        SettingsSectionItem(
          icon: LucideIcons.banknote300,
          label: 'Display currency',
          enabled: false,
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(SettingsSectionItem));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('the card clips, so ink cannot square its corners', (
      tester,
    ) async {
      await pump(
        tester,
        SettingsSectionCard(
          children: <Widget>[
            SettingsSectionItem(
              icon: LucideIcons.banknote300,
              label: 'Display currency',
              bordered: false,
              onTap: () {},
            ),
          ],
        ),
      );

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SettingsSectionCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(card.clipBehavior, Clip.antiAlias);
    });
  });

  group('BottomDrawer close button', () {
    testWidgets('carries the semantic label as its hover label', (
      tester,
    ) async {
      await pump(
        tester,
        const BottomDrawer(
          title: 'Display currency',
          closeSemanticLabel: 'Close',
          child: SizedBox.shrink(),
        ),
      );

      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('closeTooltip overrides it', (tester) async {
      await pump(
        tester,
        const BottomDrawer(
          title: 'Display currency',
          closeSemanticLabel: 'Close this drawer',
          closeTooltip: 'Close',
          child: SizedBox.shrink(),
        ),
      );

      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.byTooltip('Close this drawer'), findsNothing);
    });

    testWidgets('and none at all when the app supplies neither', (
      tester,
    ) async {
      await pump(
        tester,
        const BottomDrawer(title: 'Display currency', child: SizedBox.shrink()),
      );

      expect(find.byType(Tooltip), findsNothing);
    });
  });

  group('Search', () {
    testWidgets('takes focus on open when asked', (tester) async {
      await pump(
        tester,
        const Search(placeholder: 'Search currencies...', autofocus: true),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode?.hasFocus, isTrue);
    });

    testWidgets('and does not by default', (tester) async {
      await pump(tester, const Search(placeholder: 'Search currencies...'));
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode?.hasFocus, isFalse);
    });
  });
}
