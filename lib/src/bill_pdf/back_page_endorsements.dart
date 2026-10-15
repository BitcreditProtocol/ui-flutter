import 'package:pdf/pdf.dart';

import 'package:bitcr_ui/src/bill_pdf/bill_pdf_endorsement.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_layout.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';

/// Draws this panel's share of [endorsements] as up to five rotated columns.
void renderBackPageEndorsements({
  required BillPdfPainter painter,
  required BillPdfLabels labels,
  required List<BillPdfEndorsement> endorsements,
  required int panelIndex,
  required double margin,
  required double top,
  required double contentOffsetY,
  required BillPdfFonts fonts,
  required PdfColor textColor,
}) {
  const perPanel = BillPdfLayout.endorsementsPerPanel;
  final start = panelIndex * perPanel;
  if (start >= endorsements.length) return;
  final end = start + perPanel > endorsements.length
      ? endorsements.length
      : start + perPanel;
  final panelEndorsements = endorsements.sublist(start, end);

  final columnTop = top - 28 + contentOffsetY;
  final columnBottom = margin + 24 + contentOffsetY;
  final columnHeight = columnTop - columnBottom;
  final maxTextLength = columnHeight - 12;
  const signatureSize = 24.0;
  final contentRight = BillPdfLayout.panelWidth - margin;
  final endorsementStartX = margin + 120;
  final columnWidth = (contentRight - endorsementStartX) / perPanel;

  const lineStartY = 39.0;
  const lineEndY = 39.0 + 181;
  const lineCenterY = (lineStartY + lineEndY) / 2;
  const textY = 39.0;
  const labelSize = 8.5;
  const nameSize = 10.0;
  const addressSize = 8.5;
  const placeSize = 8.5;
  const signatureNameSize = 10.0;
  final placeDividerColor = billPdfRgb255(0xd1, 0xcc, 0xc1);
  final signatureRuleColor = BillPdfColors.doubleRule;
  const accent = BillPdfColors.accent;
  final mono = fonts.geistMono;
  final monoMedium = fonts.geistMonoMedium;

  for (var i = 0; i < panelEndorsements.length; i++) {
    final endorsement = panelEndorsements[i];
    final signerName = endorsement.signerName.trim();
    final signatureName = endorsement.signatureName.trim();
    // A bearer signer keeps its column but prints nothing.
    if (signerName.toLowerCase() == 'bearer') continue;

    final columnShift = i * 12.0;
    final columnLeft = endorsementStartX + i * columnWidth;
    final labelX = columnLeft - 30 + columnShift;
    final nameX = columnLeft - 15 + columnShift;
    final addressLine1X = columnLeft - 1 + columnShift;
    final placeDividerX = columnLeft + 19 + columnShift;
    final signatureLineX = columnLeft + 86 + columnShift;
    final signatureLineInnerX = signatureLineX + 2;

    painter.drawText(
      endorsement.label.isEmpty ? labels.payToTheOrderOf : endorsement.label,
      x: labelX,
      y: textY,
      size: labelSize,
      font: mono,
      color: textColor,
      rotate90: true,
    );

    painter.drawText(
      truncatePdfTextToFit(
        monoMedium,
        nameSize,
        billPdfUpperCase(endorsement.payeeName),
        maxTextLength,
      ),
      x: nameX + 4,
      y: textY,
      size: nameSize,
      font: monoMedium,
      color: textColor,
      rotate90: true,
    );

    final addressLine1 = endorsement.payeeAddressLine1.trim();
    final addressLine2 = endorsement.payeeAddressLine2.trim();
    if (addressLine1.isNotEmpty && addressLine1 != '-') {
      painter.drawText(
        truncatePdfTextToFit(mono, addressSize, addressLine1, maxTextLength),
        x: addressLine1X + 2,
        y: textY,
        size: addressSize,
        font: mono,
        color: textColor,
        rotate90: true,
      );
    }
    final addressLine2X = addressLine1X + 10;
    if (addressLine2.isNotEmpty && addressLine2 != '-') {
      painter.drawText(
        truncatePdfTextToFit(mono, addressSize, addressLine2, maxTextLength),
        x: addressLine2X + 3,
        y: textY,
        size: addressSize,
        font: mono,
        color: textColor,
        rotate90: true,
      );
    }
    final placeDateX = addressLine2X + 10 + 18;

    painter.drawText(
      truncatePdfPlaceDateToFit(
        mono,
        placeSize,
        endorsement.signaturePlace,
        endorsement.signatureDate,
        maxTextLength,
      ),
      x: placeDateX - 4,
      y: textY,
      size: placeSize,
      font: mono,
      color: textColor,
      rotate90: true,
    );

    painter.drawLine(
      placeDividerX,
      lineStartY,
      placeDividerX,
      lineEndY,
      thickness: 1,
      color: placeDividerColor,
    );

    final signatureText = truncatePdfTextToFit(
      fonts.malvinas,
      signatureSize,
      signatureName,
      maxTextLength,
    );
    final signatureLength = fonts.malvinas.widthOfTextAtSize(
      signatureText.trim(),
      signatureSize,
    );
    final signatureY = lineCenterY - signatureLength / 2;

    final signerNameText = billPdfUpperCase(
      truncatePdfTextToFit(
        monoMedium,
        signatureNameSize,
        signerName,
        maxTextLength,
      ),
    );
    final signerNameLength = monoMedium.widthOfTextAtSize(
      signerNameText,
      signatureNameSize,
    );
    final signerNameY = lineCenterY - signerNameLength / 2;

    painter.drawText(
      signerNameText,
      x: columnLeft + 48 + columnShift + 2,
      y: signerNameY,
      size: signatureNameSize,
      font: monoMedium,
      color: accent,
      rotate90: true,
    );
    painter.drawText(
      signatureText,
      x: columnLeft + 74 + columnShift,
      y: signatureY,
      size: signatureSize,
      font: fonts.malvinas,
      color: accent,
      rotate90: true,
    );

    painter.drawLine(
      signatureLineX - 2,
      lineStartY,
      signatureLineX - 2,
      lineEndY,
      thickness: 1,
      color: signatureRuleColor,
    );
    painter.drawLine(
      signatureLineInnerX - 2,
      lineStartY,
      signatureLineInnerX - 2,
      lineEndY,
      thickness: 1,
      color: signatureRuleColor,
    );
  }
}
