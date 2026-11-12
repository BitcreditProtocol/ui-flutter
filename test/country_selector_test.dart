import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/countries.dart';

Future<TextEditingController> _pumpSelector(
  WidgetTester tester, {
  String initial = '',
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
}) async {
  final controller = TextEditingController(text: initial);
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: CountrySelector(
            controller: controller,
            label: 'Country',
            countries: testCountries,
            searchPlaceholder: 'Search for a country...',
            noResultsLabel: 'No country found.',
            clearLabel: 'Clear country',
            clearSearchLabel: 'Clear search',
            isRequired: true,
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );

  return controller;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Country*', findRichText: true));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('searching by code and picking writes the code', (tester) async {
    final changes = <String>[];
    final controller = await _pumpSelector(tester, onChanged: changes.add);

    await _open(tester);
    await tester.enterText(find.byType(TextField), 'ch');
    await tester.pumpAndSettle();

    expect(find.text('Switzerland'), findsOneWidget);
    expect(find.text('Chile'), findsOneWidget);
    expect(find.text('Albania'), findsNothing);

    await tester.tap(find.text('Switzerland'));
    await tester.pumpAndSettle();

    expect(controller.text, 'CH');
    expect(changes, ['CH']);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Switzerland'), findsOneWidget);
  });

  testWidgets('search terms match as well as the name', (tester) async {
    await _pumpSelector(tester);

    await _open(tester);
    await tester.enterText(find.byType(TextField), 'österr');
    await tester.pumpAndSettle();

    expect(find.text('Austria'), findsOneWidget);
    expect(find.text('Germany'), findsNothing);
  });

  testWidgets('an unmatched search says so', (tester) async {
    await _pumpSelector(tester);

    await _open(tester);
    await tester.enterText(find.byType(TextField), 'atlantis');
    await tester.pumpAndSettle();

    expect(find.text('No country found.'), findsOneWidget);
  });

  testWidgets('clearing the search shows every country again', (tester) async {
    await _pumpSelector(tester);

    await _open(tester);
    await tester.enterText(find.byType(TextField), 'atlantis');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('No country found.'), findsNothing);
    expect(find.text('Albania'), findsOneWidget);
  });

  testWidgets('tapping outside closes the list', (tester) async {
    await _pumpSelector(tester);

    await _open(tester);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tapAt(const Offset(400, 500));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('escape closes the list', (tester) async {
    await _pumpSelector(tester);

    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('the selected country is checked in the list', (tester) async {
    await _pumpSelector(tester, initial: 'at');

    await _open(tester);

    final checked = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((semantics) => semantics.properties.selected == true);

    expect(checked, hasLength(1));
    expect(
      find.descendant(
        of: find.byWidget(checked.single),
        matching: find.text('Austria'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('clearing empties the field and runs the validator', (
    tester,
  ) async {
    final controller = await _pumpSelector(
      tester,
      initial: 'de',
      validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
    );

    expect(find.text('Germany'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Clear country'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(find.text('Germany'), findsNothing);
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('a code set from outside shows its name', (tester) async {
    final controller = await _pumpSelector(tester);

    controller.text = 'AT';
    await tester.pump();

    expect(find.text('Austria'), findsOneWidget);
  });
}
