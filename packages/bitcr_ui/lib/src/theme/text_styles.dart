import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// The type scale. Every style defaults its color to [BitcrColors.text300],
/// so call sites only pass `color:` when they want a different token.
///
/// Read it off the context: `context.bitcrText.textLgMedium()`.
class BitcrTextStyles {
  const BitcrTextStyles(this.colors);

  final BitcrColors colors;

  TextStyle displayMdRegular({Color? color}) => TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    color: color ?? colors.text300,
    height: 1.25,
  );

  TextStyle displayXsMedium({Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: color ?? colors.text300,
    height: 32 / 24,
  );

  TextStyle textLgMedium({Color? color}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: color ?? colors.text300,
    height: 30 / 20,
  );

  TextStyle textMdMedium({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? colors.text300,
    height: 24 / 16,
  );

  TextStyle textMdRegular({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color ?? colors.text300,
    height: 24 / 16,
  );

  TextStyle textSmMedium({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color ?? colors.text300,
    height: 20 / 14,
  );

  TextStyle textSmRegular({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? colors.text300,
    height: 20 / 14,
  );

  TextStyle textXsMedium({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: color ?? colors.text300,
    height: 18 / 12,
  );

  TextStyle textXsRegular({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? colors.text300,
    height: 18 / 12,
  );
}

extension BitcrTextStylesContext on BuildContext {
  BitcrTextStyles get bitcrText => BitcrTextStyles(BitcrColors.of(this));
}
