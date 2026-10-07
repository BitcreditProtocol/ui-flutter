import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BitcreditLogo extends StatelessWidget {
  const BitcreditLogo({super.key, this.semanticLabel = 'Bitcredit'});

  final String semanticLabel;

  static const double width = 132;
  static const double height = 22;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 1.1, bottom: 2.0174),
        child: SvgPicture.asset(
          'assets/logo/bitcredit_wordmark.svg',
          package: 'bitcr_ui',
          semanticsLabel: semanticLabel,
          colorMapper: isDark
              ? _DarkLettering(BitcrColors.of(context).text300)
              : null,
        ),
      ),
    );
  }
}

@immutable
class _DarkLettering extends ColorMapper {
  const _DarkLettering(this.lettering);

  static const Color _exported = Color(0xFF4D4D4D);

  final Color lettering;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => color == _exported ? lettering : color;

  @override
  bool operator ==(Object other) =>
      other is _DarkLettering && other.lettering == lettering;

  @override
  int get hashCode => lettering.hashCode;
}
