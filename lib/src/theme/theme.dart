import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/page_transitions.dart';
import 'package:flutter/material.dart';

/// Builds the [ThemeData] every Bitcredit app should use, so typography, the
/// [BitcrColors] extension and the page transition are wired up identically in
/// all of them.
///
/// App-specific additions (app bar overlay style, ...) stay in the app and go
/// on via `copyWith` — which is also how an app opts out of something set
/// here, e.g.
///
/// ```dart
/// MaterialApp(
///   theme: BitcrTheme.light.copyWith(pageTransitionsTheme: ...),
///   darkTheme: BitcrTheme.dark,
/// )
/// ```
abstract final class BitcrTheme {
  static const String fontFamily = 'packages/bitcr_ui/Geist';

  static ThemeData get light => of(BitcrColors.light, Brightness.light);

  static ThemeData get dark => of(BitcrColors.dark, Brightness.dark);

  static ThemeData of(BitcrColors colors, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
      // Every platform, so the motion is the design's rather than each OS's.
      // An app that wants the platform default back can `copyWith` it.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: BitcrPageTransitionsBuilder(),
          TargetPlatform.macOS: BitcrPageTransitionsBuilder(),
          TargetPlatform.android: BitcrPageTransitionsBuilder(),
          TargetPlatform.fuchsia: BitcrPageTransitionsBuilder(),
          TargetPlatform.linux: BitcrPageTransitionsBuilder(),
          TargetPlatform.windows: BitcrPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: colors.elevation50,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.brand200,
        brightness: brightness,
        surface: colors.elevation50,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.elevation50,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extensions: [colors],
    );
  }
}
