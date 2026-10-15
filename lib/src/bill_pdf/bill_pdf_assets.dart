/// The bundle keys for the files the bill PDF embeds.
///
/// Raw bytes loaded through `rootBundle`, not Flutter fonts. Like the Geist
/// keys, `packages/bitcr_ui/` is built from the package name.
abstract final class BillPdfAssets {
  static const String _root = 'packages/bitcr_ui/assets/bill_pdf';

  /// Bitcoin logo on the front panel.
  static const String logo = '$_root/bitcoin_logo_billprint.png';

  /// Titles ("INTERNATIONAL BILL OF EXCHANGE", "ENDORSEMENTS").
  static const String morionRegular = '$_root/Morion-Beta-Regular.ttf';

  /// "Accepted:" and "Amount in words" captions, drawn in the variable font's
  /// default (Regular) instance.
  static const String interRegular = '$_root/Inter-VariableFont.ttf';

  /// Field captions.
  static const String interSemiBold = '$_root/Inter-SemiBold.ttf';

  /// Filled-in values.
  static const String geistMonoRegular = '$_root/GeistMono-Regular.ttf';

  /// Names.
  static const String geistMonoMedium = '$_root/GeistMono-Medium.ttf';

  /// Signatures.
  static const String malvinasSignature =
      '$_root/Malvinas-Signature-Regular.otf';

  static const List<String> all = [
    logo,
    morionRegular,
    interRegular,
    interSemiBold,
    geistMonoRegular,
    geistMonoMedium,
    malvinasSignature,
  ];
}
