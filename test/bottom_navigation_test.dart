import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orange = Color(0xFFF7931A);

  Future<void> pump(WidgetTester tester, {required int currentIndex}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: BitcrTheme.light,
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: currentIndex,
              onTap: (_) {},
              items: const [
                NavItem(label: 'Home', icon: LucideIcons300.house),
                NavItem(
                  label: 'New',
                  icon: LucideIcons300.circlePlus,
                  color: orange,
                ),
              ],
            ),
          ),
        ),
      );

  Color? iconColor(WidgetTester tester, IconData icon) =>
      tester.widget<Icon>(find.byIcon(icon)).color;

  Color? labelColor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style?.color;

  testWidgets('a colored tab keeps its color while inactive', (tester) async {
    await pump(tester, currentIndex: 0);

    expect(iconColor(tester, LucideIcons300.circlePlus), orange);
    expect(labelColor(tester, 'New'), orange);
  });

  testWidgets('a colored tab keeps its color while active', (tester) async {
    await pump(tester, currentIndex: 1);

    expect(iconColor(tester, LucideIcons300.circlePlus), orange);
    expect(labelColor(tester, 'New'), orange);
  });

  testWidgets('tabs without a color follow the active state', (tester) async {
    await pump(tester, currentIndex: 0);
    final colors = BitcrColors.light;

    expect(iconColor(tester, LucideIcons300.house), colors.text300);

    await pump(tester, currentIndex: 1);

    expect(iconColor(tester, LucideIcons300.house), colors.text200);
  });
}
