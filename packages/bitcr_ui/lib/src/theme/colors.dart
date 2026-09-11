import 'package:flutter/material.dart';

/// Design-token color set.
///
/// Registered as a [ThemeExtension] by [BitcrTheme], so call sites read it
/// with `BitcrColors.of(context)`. Apps that need to deviate from a token can
/// [copyWith] a palette before handing it to `BitcrTheme.light`/`dark`.
class BitcrColors extends ThemeExtension<BitcrColors> {
  const BitcrColors._({
    required this.black,
    required this.white,
    required this.elevation0,
    required this.elevation50,
    required this.text50,
    required this.text100,
    required this.text200,
    required this.text300,
    required this.text400,
    required this.textActive,
    required this.textInactive,
    required this.divider50,
    required this.divider75,
    required this.divider100,
    required this.divider200,
    required this.divider300,
    required this.elevation100,
    required this.elevation200,
    required this.elevation250,
    required this.elevation300,
    required this.elevation350,
    required this.baseActive,
    required this.baseInactive,
    required this.brand50,
    required this.brand100,
    required this.brand200,
    required this.brandFill,
    required this.onBrandFill,
    required this.selectionFill,
    required this.onSelectionFill,
    required this.networkBadge,
    required this.signalError,
    required this.signalErrorAccent,
    required this.signalErrorLight,
    required this.signalSuccessLight,
    required this.signalSuccess,
    required this.signalAlert,
  });

  // --- fundaments ---
  final Color black;
  final Color white;

  // --- semantic tokens ---
  final Color elevation0;
  final Color elevation50;
  final Color text50;
  final Color text100;
  final Color text200;
  final Color text300;
  final Color text400;
  final Color textActive;
  final Color textInactive;
  final Color divider50;
  final Color divider75;
  final Color divider100;
  final Color divider200;
  final Color divider300;
  final Color elevation100;
  final Color elevation200;
  final Color elevation250;
  final Color elevation300;
  final Color elevation350;
  final Color baseActive;
  final Color baseInactive;
  final Color brand50;
  final Color brand100;
  final Color brand200;
  final Color brandFill;
  final Color onBrandFill;
  final Color selectionFill;
  final Color onSelectionFill;
  final Color networkBadge;
  final Color signalError;
  final Color signalErrorAccent;
  final Color signalErrorLight;
  final Color signalSuccessLight;
  final Color signalSuccess;
  final Color signalAlert;

  // --- light palette ---
  static const BitcrColors light = BitcrColors._(
    black: Color(0xFF000000),
    white: Color(0xFFFFFFFF),
    elevation0: Color(0xFFFFFDF8),
    elevation50: Color(0xFFFEFBF1),
    text50: Color(0xFFD6D2CA),
    text100: Color(0xFFC5C1B9),
    text200: Color(0xFF8D8579),
    text300: Color(0xFF1B0F00),
    text400: Color(0xFFF7931A),
    textActive: Color(0xFFFFFFFF),
    textInactive: Color(0xFFF1EDE4),
    divider50: Color(0xFFECE8DE),
    divider75: Color(0xFFD9D5CC),
    divider100: Color(0xFFD1CCC1),
    divider200: Color(0xFFBAB4A9),
    divider300: Color(0xFFA39D91),
    elevation100: Color(0xFFFAF7EF),
    elevation200: Color(0xFFF6F2E7),
    elevation250: Color(0xFFF2EDDF),
    elevation300: Color(0xFFD1CCC1),
    elevation350: Color(0xFFE3D9CA),
    baseActive: Color(0xFF1B0F00),
    baseInactive: Color(0xFFD1CCC1),
    brand50: Color(0xFFFFF2E2),
    brand100: Color(0xFFFBDBB0),
    brand200: Color(0xFFF7931A),
    brandFill: Color(0xFFFFF2E2),
    onBrandFill: Color(0xFF1B0F00),
    selectionFill: Color(0xFFFFF2E2),
    onSelectionFill: Color(0xFF1B0F00),
    networkBadge: Color(0xFFE8861C),
    signalError: Color(0xFFA32B16),
    signalErrorAccent: Color(0xFFE65E46),
    signalErrorLight: Color(0xFFFF2600),
    signalSuccessLight: Color(0xFF73F671),
    signalSuccess: Color(0xFF006F29),
    signalAlert: Color(0xFFAE5F00),
  );

  // --- dark palette ---
  static const BitcrColors dark = BitcrColors._(
    black: Color(0xFFFFFFFF),
    white: Color(0xFF000000),
    elevation0: Color(0xFF050200),
    elevation50: Color(0xFF0B0600),
    text50: Color(0xFF6C757D),
    text100: Color(0xFF4D4D4D),
    text200: Color(0xFF808080),
    text300: Color(0xFFFFF2E2),
    text400: Color(0xFFFFFFFF),
    textActive: Color(0xFF000000),
    textInactive: Color(0xFF3A3A3A),
    divider50: Color(0xFF232221),
    divider75: Color(0xFF282625),
    divider100: Color(0xFF272726),
    divider200: Color(0xFF2C2B2A),
    divider300: Color(0xFF434241),
    elevation100: Color(0xFF141414),
    elevation200: Color(0xFF1A1A1A),
    elevation250: Color(0xFF1F1F1F),
    elevation300: Color(0xFF242424),
    elevation350: Color(0xFF292929),
    baseActive: Color(0xFFFFF2E2),
    baseInactive: Color(0xFF606060),
    brand50: Color(0xFFFFF2E2),
    brand100: Color(0xFFFBDBB0),
    brand200: Color(0xFFF7931A),
    brandFill: Color(0xFFF7931A),
    onBrandFill: Color(0xFF000000),
    selectionFill: Color(0xFF242424),
    onSelectionFill: Color(0xFFFFF2E2),
    networkBadge: Color(0xFFE8861C),
    signalError: Color(0xFFCF371C),
    signalErrorAccent: Color(0xFFE65E46),
    signalErrorLight: Color(0xFFFF2600),
    signalSuccessLight: Color(0xFF73F671),
    signalSuccess: Color(0xFF4DAA4E),
    signalAlert: Color(0xFFE07B00),
  );

  static BitcrColors of(BuildContext context) =>
      Theme.of(context).extension<BitcrColors>() ?? light;

  @override
  BitcrColors copyWith({
    Color? black,
    Color? white,
    Color? elevation0,
    Color? elevation50,
    Color? text50,
    Color? text100,
    Color? text200,
    Color? text300,
    Color? text400,
    Color? textActive,
    Color? textInactive,
    Color? divider50,
    Color? divider75,
    Color? divider100,
    Color? divider200,
    Color? divider300,
    Color? elevation100,
    Color? elevation200,
    Color? elevation250,
    Color? elevation300,
    Color? elevation350,
    Color? baseActive,
    Color? baseInactive,
    Color? brand50,
    Color? brand100,
    Color? brand200,
    Color? brandFill,
    Color? onBrandFill,
    Color? selectionFill,
    Color? onSelectionFill,
    Color? networkBadge,
    Color? signalError,
    Color? signalErrorAccent,
    Color? signalErrorLight,
    Color? signalSuccessLight,
    Color? signalSuccess,
    Color? signalAlert,
  }) => BitcrColors._(
    black: black ?? this.black,
    white: white ?? this.white,
    elevation0: elevation0 ?? this.elevation0,
    elevation50: elevation50 ?? this.elevation50,
    text50: text50 ?? this.text50,
    text100: text100 ?? this.text100,
    text200: text200 ?? this.text200,
    text300: text300 ?? this.text300,
    text400: text400 ?? this.text400,
    textActive: textActive ?? this.textActive,
    textInactive: textInactive ?? this.textInactive,
    divider50: divider50 ?? this.divider50,
    divider75: divider75 ?? this.divider75,
    divider100: divider100 ?? this.divider100,
    divider200: divider200 ?? this.divider200,
    divider300: divider300 ?? this.divider300,
    elevation100: elevation100 ?? this.elevation100,
    elevation200: elevation200 ?? this.elevation200,
    elevation250: elevation250 ?? this.elevation250,
    elevation300: elevation300 ?? this.elevation300,
    elevation350: elevation350 ?? this.elevation350,
    baseActive: baseActive ?? this.baseActive,
    baseInactive: baseInactive ?? this.baseInactive,
    brand50: brand50 ?? this.brand50,
    brand100: brand100 ?? this.brand100,
    brand200: brand200 ?? this.brand200,
    brandFill: brandFill ?? this.brandFill,
    onBrandFill: onBrandFill ?? this.onBrandFill,
    selectionFill: selectionFill ?? this.selectionFill,
    onSelectionFill: onSelectionFill ?? this.onSelectionFill,
    networkBadge: networkBadge ?? this.networkBadge,
    signalError: signalError ?? this.signalError,
    signalErrorAccent: signalErrorAccent ?? this.signalErrorAccent,
    signalErrorLight: signalErrorLight ?? this.signalErrorLight,
    signalSuccessLight: signalSuccessLight ?? this.signalSuccessLight,
    signalSuccess: signalSuccess ?? this.signalSuccess,
    signalAlert: signalAlert ?? this.signalAlert,
  );

  @override
  BitcrColors lerp(BitcrColors? other, double t) {
    if (other == null) return this;
    return BitcrColors._(
      black: Color.lerp(black, other.black, t)!,
      white: Color.lerp(white, other.white, t)!,
      elevation0: Color.lerp(elevation0, other.elevation0, t)!,
      elevation50: Color.lerp(elevation50, other.elevation50, t)!,
      text50: Color.lerp(text50, other.text50, t)!,
      text100: Color.lerp(text100, other.text100, t)!,
      text200: Color.lerp(text200, other.text200, t)!,
      text300: Color.lerp(text300, other.text300, t)!,
      text400: Color.lerp(text400, other.text400, t)!,
      textActive: Color.lerp(textActive, other.textActive, t)!,
      textInactive: Color.lerp(textInactive, other.textInactive, t)!,
      divider50: Color.lerp(divider50, other.divider50, t)!,
      divider75: Color.lerp(divider75, other.divider75, t)!,
      divider100: Color.lerp(divider100, other.divider100, t)!,
      divider200: Color.lerp(divider200, other.divider200, t)!,
      divider300: Color.lerp(divider300, other.divider300, t)!,
      elevation100: Color.lerp(elevation100, other.elevation100, t)!,
      elevation200: Color.lerp(elevation200, other.elevation200, t)!,
      elevation250: Color.lerp(elevation250, other.elevation250, t)!,
      elevation300: Color.lerp(elevation300, other.elevation300, t)!,
      elevation350: Color.lerp(elevation350, other.elevation350, t)!,
      baseActive: Color.lerp(baseActive, other.baseActive, t)!,
      baseInactive: Color.lerp(baseInactive, other.baseInactive, t)!,
      brand50: Color.lerp(brand50, other.brand50, t)!,
      brand100: Color.lerp(brand100, other.brand100, t)!,
      brand200: Color.lerp(brand200, other.brand200, t)!,
      brandFill: Color.lerp(brandFill, other.brandFill, t)!,
      onBrandFill: Color.lerp(onBrandFill, other.onBrandFill, t)!,
      selectionFill: Color.lerp(selectionFill, other.selectionFill, t)!,
      onSelectionFill: Color.lerp(
        onSelectionFill,
        other.onSelectionFill,
        t,
      )!,
      networkBadge: Color.lerp(networkBadge, other.networkBadge, t)!,
      signalError: Color.lerp(signalError, other.signalError, t)!,
      signalErrorAccent: Color.lerp(
        signalErrorAccent,
        other.signalErrorAccent,
        t,
      )!,
      signalErrorLight: Color.lerp(
        signalErrorLight,
        other.signalErrorLight,
        t,
      )!,
      signalSuccessLight: Color.lerp(
        signalSuccessLight,
        other.signalSuccessLight,
        t,
      )!,
      signalSuccess: Color.lerp(signalSuccess, other.signalSuccess, t)!,
      signalAlert: Color.lerp(signalAlert, other.signalAlert, t)!,
    );
  }
}
