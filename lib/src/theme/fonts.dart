/// The bundle keys for the Geist font files, and the family name built from
/// them.
///
/// These read like file paths but are not. `packages/bitcr_ui/` is Flutter's
/// namespace for an asset owned by a dependency, and it is built from the
/// *package name* — not from where the package sits on disk, and not from the
/// `fonts/` directory these files actually live in. Flattening or nesting the
/// repo does not change them; renaming the package does.
///
/// They are constants because apps read the TTFs directly: the wallet's PDF
/// export loads [regular] and [medium] through `rootBundle` to embed Geist in
/// the document. A missed key throws, and that call site catches the throw to
/// fall back to Helvetica — so a stale string costs the export its typeface
/// with nothing logged. Importing the key instead of retyping it turns that
/// silent regression into a compile error.
abstract final class BitcrFonts {
  /// The asset namespace. Every key below is built from it, so a package
  /// rename is one edit here rather than ten scattered strings.
  static const String _package = 'packages/bitcr_ui';

  /// The family name to hand to `ThemeData.fontFamily` or
  /// [TextStyle.fontFamily]. Prefer the theme — this is for the rare widget
  /// that builds a `TextStyle` outside it.
  static const String family = '$_package/Geist';

  static const String thin = '$_package/fonts/Geist-Thin.ttf';
  static const String extraLight = '$_package/fonts/Geist-ExtraLight.ttf';
  static const String light = '$_package/fonts/Geist-Light.ttf';
  static const String regular = '$_package/fonts/Geist-Regular.ttf';
  static const String medium = '$_package/fonts/Geist-Medium.ttf';
  static const String semiBold = '$_package/fonts/Geist-SemiBold.ttf';
  static const String bold = '$_package/fonts/Geist-Bold.ttf';
  static const String extraBold = '$_package/fonts/Geist-ExtraBold.ttf';
  static const String black = '$_package/fonts/Geist-Black.ttf';
}
