// Search and PasscodeForm both draw their own surface and lay a bare TextField
// over it. An InputDecoration leaves `filled` and the per-state borders null
// unless they are set, and InputDecoration.applyDefaults then fills them from
// the host app's InputDecorationTheme — painting a second filled, bordered box
// inside the search field, and one straight across the passcode dots.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A host theme like an app that fills and outlines every input by default.
ThemeData _hostTheme() => BitcrTheme.light.copyWith(
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFEEEEEE),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF7A00)),
    ),
  ),
);

Future<InputDecoration> _decorationOf(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _hostTheme(),
      home: Scaffold(body: child),
    ),
  );
  await tester.pump(const Duration(seconds: 1));

  return tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
}

void main() {
  testWidgets('Search ignores the host input theme', (tester) async {
    final decoration = await _decorationOf(
      tester,
      const Search(placeholder: 'Name, address, email...'),
    );

    expect(decoration.filled, isFalse);
    expect(decoration.enabledBorder, InputBorder.none);
    expect(decoration.focusedBorder, InputBorder.none);
  });

  testWidgets('PasscodeForm ignores the host input theme', (tester) async {
    final decoration = await _decorationOf(
      tester,
      PasscodeForm(value: '', onChanged: (_, _) {}),
    );

    expect(decoration.filled, isFalse);
    expect(decoration.enabledBorder, InputBorder.none);
    expect(decoration.focusedBorder, InputBorder.none);
  });
}
