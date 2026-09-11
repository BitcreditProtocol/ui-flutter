import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// The in-page screen title, one line and ellipsised, with an optional
/// trailing action pushed to the far edge.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.bitcrText.displayXsMedium(
        color: BitcrColors.of(context).text300,
      ),
    );

    if (trailing == null) return titleText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Flexible(child: titleText), trailing!],
    );
  }
}
