import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _phrase = [
  'abandon',
  'ability',
  'able',
  'about',
  'above',
  'absent',
  'absorb',
  'abstract',
  'absurd',
  'abuse',
  'access',
  'accident',
];

Widget _page(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: child,
);

@widgetbook.UseCase(name: 'Revealed', type: SeedPhraseGrid)
Widget seedPhraseGridRevealed(BuildContext context) =>
    _page(const SeedPhraseGrid(words: _phrase, revealed: true));

@widgetbook.UseCase(name: 'Hidden', type: SeedPhraseGrid)
Widget seedPhraseGridHidden(BuildContext context) =>
    _page(const SeedPhraseGrid(words: _phrase, revealed: false));

/// Nothing loaded yet: the grid keeps its 12 cells and shows placeholders, so
/// the page doesn't jump when the phrase arrives.
@widgetbook.UseCase(name: 'Loading', type: SeedPhraseGrid)
Widget seedPhraseGridLoading(BuildContext context) =>
    _page(const SeedPhraseGrid(words: [], revealed: true));

@widgetbook.UseCase(name: 'Playground', type: SeedPhraseGrid)
Widget seedPhraseGridPlayground(BuildContext context) {
  final wordCount = context.knobs.object.dropdown(
    label: 'Word count',
    options: const [12, 24],
    labelBuilder: (count) => '$count words',
  );

  return _page(
    SeedPhraseGrid(
      // 24-word phrases repeat the sample list; only the layout is under review.
      words: context.knobs.boolean(label: 'Loaded', initialValue: true)
          ? [for (var i = 0; i < wordCount; i++) _phrase[i % _phrase.length]]
          : const [],
      revealed: context.knobs.boolean(label: 'Revealed', initialValue: true),
      wordCount: wordCount,
      onTap: () {},
    ),
  );
}
