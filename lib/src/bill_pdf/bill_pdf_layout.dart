/// Geometry shared by every bill PDF panel and sheet, in PDF points.
///
/// A panel is one face of the bill (front, back, or a rider); two panels are
/// laid out per A4-landscape sheet.
abstract final class BillPdfLayout {
  static const double panelWidth = 804;
  static const double panelHeight = 259;

  /// Gap around each panel on its sheet.
  static const double panelPadding = 19;

  static const double sheetWidth = 842;
  static const double sheetHeight = 595;

  /// Endorsements that fit on one back panel.
  static const int endorsementsPerPanel = 5;

  /// Panels the document needs: the front plus at least one back panel, with a
  /// further back panel ("rider") for every started group of
  /// [endorsementsPerPanel].
  static int panelCount(int endorsementCount) {
    final backPanels = endorsementCount <= 0
        ? 1
        : (endorsementCount + endorsementsPerPanel - 1) ~/ endorsementsPerPanel;
    return 1 + backPanels;
  }

  /// Sheets the document prints on: two panels per sheet.
  static int sheetCount(int endorsementCount) =>
      (panelCount(endorsementCount) + 1) ~/ 2;
}
