import 'package:bitcr_ui/src/patterns/seed_word.dart';
import 'package:flutter/material.dart';

/// The two-column recovery-phrase grid, shared by every screen that shows a
/// mnemonic (onboarding backup, wallet creation, and the settings backup and
/// save-phrase screens).
class SeedPhraseGrid extends StatelessWidget {
  const SeedPhraseGrid({
    super.key,
    required this.words,
    required this.revealed,
    this.onTap,
    this.wordCount = 12,
    this.placeholder = '----',
  });

  final List<String> words;
  final bool revealed;
  final VoidCallback? onTap;
  final int wordCount;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final ready = words.length == wordCount;

    return GridView(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 16,
        mainAxisExtent: 46,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        wordCount,
        (index) => SeedWord(
          index: index,
          word: ready ? words[index] : placeholder,
          revealed: revealed,
          onTap: onTap,
        ),
      ),
    );
  }
}
