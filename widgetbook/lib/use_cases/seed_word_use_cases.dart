import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Sized like a real grid cell — the component stretches to its slot, so an
/// unconstrained one tells you nothing about the layout.
Widget _cell(Widget child) => Center(
  child: SizedBox(width: 160, height: 46, child: child),
);

@widgetbook.UseCase(name: 'Revealed', type: SeedWord)
Widget seedWordRevealed(BuildContext context) =>
    _cell(const SeedWord(index: 0, word: 'abandon'));

@widgetbook.UseCase(name: 'Hidden', type: SeedWord)
Widget seedWordHidden(BuildContext context) =>
    _cell(const SeedWord(index: 0, word: 'abandon', revealed: false));

/// Two-digit position: the badge is fixed at 30px, so this is where it would
/// crowd if the number outgrew it.
@widgetbook.UseCase(name: 'Two-digit index', type: SeedWord)
Widget seedWordTwoDigit(BuildContext context) =>
    _cell(const SeedWord(index: 11, word: 'zoo'));

@widgetbook.UseCase(name: 'Playground', type: SeedWord)
Widget seedWordPlayground(BuildContext context) => _cell(
  SeedWord(
    index: context.knobs.int
        .slider(label: 'Index (0-based)', initialValue: 0, max: 23)
        .toInt(),
    word: context.knobs.string(label: 'Word', initialValue: 'abandon'),
    revealed: context.knobs.boolean(label: 'Revealed', initialValue: true),
    onTap: () {},
  ),
);
