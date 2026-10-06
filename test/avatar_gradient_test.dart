// The wallet tells its wallets apart by colour, which a single solid
// backgroundColor could not express. A gradient fill is opt-in, so every
// other avatar (ebills, dashboard) keeps the neutral bordered look.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _gradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1E9EFF), Color(0xFF0080F8)],
);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(Avatar),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('a gradient fills, drops the border, whitens the initials', (
    tester,
  ) async {
    await _pump(
      tester,
      const Avatar(name: 'Ada Lovelace', gradient: _gradient),
    );

    final decoration = _decoration(tester);
    final initials = tester.widget<Text>(find.text('AL'));

    expect(decoration.gradient, _gradient);
    expect(decoration.color, isNull);
    expect(decoration.border, isNull);
    expect(initials.style!.color, BitcrColors.light.white);
  });

  testWidgets('without one, the avatar stays neutral and bordered', (
    tester,
  ) async {
    await _pump(tester, const Avatar(name: 'Ada Lovelace'));

    final decoration = _decoration(tester);

    expect(decoration.gradient, isNull);
    expect(decoration.color, BitcrColors.light.elevation50);
    expect(decoration.border, isNotNull);
  });

  testWidgets('the chip and the menu rows pass their gradient through', (
    tester,
  ) async {
    await _pump(
      tester,
      IdentitySwitcher<String>(
        name: 'Wallet 1',
        avatarGradient: _gradient,
        selected: 'w1',
        onSelect: (_) {},
        options: const [
          IdentityOption(
            value: 'w1',
            name: 'Wallet 1',
            avatarGradient: _gradient,
          ),
          IdentityOption(value: 'w2', name: 'Wallet 2'),
        ],
      ),
    );

    await tester.tap(find.byType(IdentityChip));
    await tester.pumpAndSettle();

    final gradients = tester
        .widgetList<Avatar>(find.byType(Avatar))
        .map((a) => a.gradient)
        .toList();

    expect(gradients, [_gradient, _gradient, null]);
  });
}
