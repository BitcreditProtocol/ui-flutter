import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// The in-page screen title, one line and ellipsised, with an optional
/// trailing action pushed to the far edge.
///
/// It always occupies [height], with or without a [trailing] action, so a
/// screen that gains or loses one doesn't shift everything below it — and so
/// a caller can reserve the space up front.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  static const double height = 48;

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

    return SizedBox(
      height: height,
      child: trailing == null
          ? Align(alignment: Alignment.centerLeft, child: titleText)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: titleText),
                trailing!,
              ],
            ),
    );
  }
}
