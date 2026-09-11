import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// One cell of a recovery phrase: a 1-based position badge next to the word.
///
/// When [revealed] is false the word is replaced by a filler bar rather than
/// removed, so the grid doesn't reflow as it's shown and hidden.
class SeedWord extends StatelessWidget {
  const SeedWord({
    super.key,
    required this.index,
    required this.word,
    this.revealed = true,
    this.onTap,
  });

  final int index;
  final String word;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final textStyle = context.bitcrText.textSmMedium(color: colors.text300);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 16),
        decoration: BoxDecoration(
          color: colors.elevation200,
          borderRadius: BorderRadius.circular(BitcrRadius.md),
          border: Border.all(color: colors.divider50),
        ),
        child: Row(
          spacing: 8,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.elevation300,
                borderRadius: BorderRadius.circular(BitcrRadius.xs),
              ),
              child: Text('${index + 1}', style: textStyle),
            ),
            Text(revealed ? word : '', style: textStyle),
            if (!revealed)
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.elevation300,
                    borderRadius: BorderRadius.circular(BitcrRadius.xs),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
