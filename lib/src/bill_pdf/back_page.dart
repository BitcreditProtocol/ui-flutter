import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';
import 'package:bitcr_ui/src/bill_pdf/back_page_endorsements.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_endorsement.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_layout.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';

/// Draws back panel [panelIndex] (0 = "Back", then "Rider 1", …) into
/// [painter], whose origin is the panel's bottom-left corner.
void renderBackPage({
  required BillPdfPainter painter,
  required BillPdfLabels labels,
  required List<BillPdfEndorsement> endorsements,
  required int panelIndex,
  required int pageNumber,
  required int totalPages,
  required BillPdfFonts fonts,
}) {
  const margin = 16.0;
  const backWidth = BillPdfLayout.panelWidth;
  const backHeight = BillPdfLayout.panelHeight;
  const top = backHeight - margin;
  const contentOffsetY = 24.0;

  painter.fillRect(0, 0, backWidth, backHeight, BillPdfColors.panelBackground);

  final backLabel = pageNumber >= 3 ? 'Rider ${pageNumber - 2}' : labels.back;
  painter.drawText(
    backLabel,
    x: 5,
    y: top + 3,
    size: 8,
    font: fonts.geistMono,
    color: BillPdfColors.textMuted,
  );

  final endorsementsColor = billPdfRgb255(0x1b, 0x0f, 0x00);
  final endorsementsLabel = billPdfUpperCase(labels.endorsements);
  const endorsementsSize = 18.0;
  const endorsementsTracking = endorsementsSize * 0.03;
  final endorsementsTrackedWidth = measureTrackedWidth(
    endorsementsLabel,
    fonts.morion,
    endorsementsSize,
    endorsementsTracking,
  );
  const endorsementsTopInset = 46.0;
  const endorsementsBottomInset = 46.0;
  const endorsementsTitleLeft = 45.0;
  const endorsementsBandHeight =
      backHeight - endorsementsTopInset - endorsementsBottomInset;
  final endorsementsY =
      endorsementsBottomInset +
      (endorsementsBandHeight - endorsementsTrackedWidth) / 2;
  final endorsementsX =
      endorsementsTitleLeft + fonts.morion.heightAtSize(endorsementsSize);
  painter.drawTrackedRotatedText(
    endorsementsLabel,
    x: endorsementsX - 3,
    y: endorsementsY,
    size: endorsementsSize,
    font: fonts.morion,
    color: endorsementsColor,
    tracking: endorsementsTracking,
  );

  renderBackPageEndorsements(
    painter: painter,
    labels: labels,
    endorsements: endorsements,
    panelIndex: panelIndex,
    margin: margin,
    top: top,
    contentOffsetY: contentOffsetY,
    fonts: fonts,
    textColor: endorsementsColor,
  );

  painter.drawPageNumber(
    labels.pageNumber(pageNumber, totalPages),
    right: backWidth - 5,
    y: 5,
    font: fonts.geistMono,
    color: BillPdfColors.textMuted,
  );
}
