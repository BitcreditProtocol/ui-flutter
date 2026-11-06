import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpInApp(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);
