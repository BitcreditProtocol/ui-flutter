import 'package:pdf/pdf.dart';

import 'package:bitcr_ui/src/bill_pdf/bill_pdf_data.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_layout.dart';
import 'package:bitcr_ui/src/bill_pdf/front_page_header.dart';
import 'package:bitcr_ui/src/bill_pdf/front_page_parties.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';

/// Draws the front panel into [painter], whose origin is the panel's
/// bottom-left corner.
void renderFrontPage({
  required BillPdfPainter painter,
  required BillPdfContent content,
  required BillPdfLabels labels,
  required PdfImage logoImage,
  required BillPdfFonts fonts,
  required int pageNumber,
  required int totalPages,
}) {
  const width = BillPdfLayout.panelWidth;
  const height = BillPdfLayout.panelHeight;
  const leftPanelWidth = 140.0;
  const acceptancePanelWidth = 90.0;
  const contentLeft = leftPanelWidth + acceptancePanelWidth + 11;
  const contentRight = width;

  const lineColor = BillPdfColors.line;
  const textMuted = BillPdfColors.textMuted;
  const textPrimary = BillPdfColors.textPrimary;
  const accent = BillPdfColors.accent;
  final mono = fonts.geistMono;

  painter.fillRect(0, 0, width, height, BillPdfColors.panelBackground);

  final header = renderFrontPageHeader(
    painter: painter,
    height: height,
    labels: labels,
    content: content,
    logoImage: logoImage,
    fonts: fonts,
  );

  // Place and date of issue.
  final billInfoLeft = header.billInfoDividerX + 27;
  painter.drawText(
    truncatePdfLeadingSegmentToFit(mono, 8, content.issuingPlace, 312),
    x: billInfoLeft,
    y: 250,
    size: 8,
    font: mono,
    color: accent,
  );
  painter.drawLine(
    billInfoLeft,
    245,
    billInfoLeft + 314,
    245,
    thickness: 1,
    color: lineColor,
  );
  painter.drawText(
    labels.placeAndDateOfIssue,
    x: billInfoLeft,
    y: 235,
    size: 6,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  // Place of payment.
  final paymentPlaceX = header.billInfoDividerX + 363;
  painter.drawText(
    truncatePdfLeadingSegmentToFit(mono, 8, content.paymentPlace, 220, 1),
    x: paymentPlaceX,
    y: 250,
    size: 8,
    font: mono,
    color: accent,
  );
  painter.drawLine(
    billInfoLeft + 334,
    245,
    billInfoLeft + 334 + 220,
    245,
    thickness: 1,
    color: lineColor,
  );
  painter.drawText(
    labels.placeOfPayment,
    x: paymentPlaceX,
    y: 235,
    size: 6,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  // Against this bill of exchange pay on <maturity date>.
  final againstThisBillX = billInfoLeft;
  painter.drawText(
    labels.againstThisBill,
    x: againstThisBillX,
    y: 211,
    size: 14,
    font: fonts.interSemiBold,
    color: textPrimary,
  );
  painter.drawText(
    content.maturityDate,
    x: againstThisBillX + 253,
    y: 213,
    size: 8,
    font: mono,
    color: accent,
  );
  painter.drawLine(
    againstThisBillX + 253,
    207,
    againstThisBillX + 253 + 130,
    207,
    thickness: 1,
    color: lineColor,
  );

  // Amount box: a band of 11 hairlines with the amount centred on it.
  const placeOfPaymentTopLineY = 245.0;
  const amountBoxX = contentRight - 8 - 156;
  const amountBoxY = placeOfPaymentTopLineY - 7 - 22;
  const amountBoxWidth = 156.0;
  const amountBoxHeight = 22.0;
  for (var i = 0; i < 11; i++) {
    final y = amountBoxY + i * 2;
    painter.drawLine(
      amountBoxX,
      y,
      amountBoxX + amountBoxWidth,
      y,
      thickness: 1,
      color: BillPdfColors.amountBand,
    );
  }

  const amountTextSize = 8.0;
  final amountTextWidth = mono.widthOfTextAtSize(
    content.amountDisplay,
    amountTextSize,
  );
  final amountTextHeight = mono.heightAtSize(amountTextSize);
  painter.drawText(
    content.amountDisplay,
    x: amountBoxX + (amountBoxWidth - amountTextWidth) / 2,
    y: amountBoxY + (amountBoxHeight - amountTextHeight) / 2,
    size: amountTextSize,
    font: mono,
    color: accent,
  );

  const amountLabelSize = 6.0;
  final amountLabelWidth = fonts.interSemiBold.widthOfTextAtSize(
    labels.amount,
    amountLabelSize,
  );
  const amountLabelY = amountBoxY - 9;
  painter.drawText(
    labels.amount,
    x: amountBoxX + (amountBoxWidth - amountLabelWidth) / 2,
    y: amountLabelY,
    size: amountLabelSize,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  // To the order of <payee>.
  painter.drawText(
    labels.toTheOrderOf,
    x: billInfoLeft,
    y: 183 + 6,
    size: 12,
    font: fonts.interSemiBold,
    color: textPrimary,
  );
  const payeeTextWidth = 292.0;
  painter.drawText(
    truncatePdfTextToFit(mono, 8, content.payeeName, payeeTextWidth),
    x: billInfoLeft + 92,
    y: 187 + 3,
    size: 8,
    font: mono,
    color: accent,
  );
  painter.drawLine(326, 184, 326 + 292, 184, thickness: 1, color: lineColor);
  painter.drawText(
    truncatePdfLeadingSegmentToFit(
      mono,
      8,
      content.payeeAddress,
      payeeTextWidth,
    ),
    x: billInfoLeft + 92,
    y: 168 + 3,
    size: 8,
    font: mono,
    color: accent,
  );

  // "Against value." (only with an invoice) and "No protest.".
  const againstValueBoxX = amountBoxX + 1;
  const againstValueBoxWidth = amountBoxWidth - 2;
  const againstValueBoxHeight = 36.0;
  const againstValueBoxTopY = amountLabelY - 8;
  const againstValueBoxBottomY = againstValueBoxTopY - againstValueBoxHeight;
  painter.strokeRect(
    againstValueBoxX,
    againstValueBoxBottomY,
    againstValueBoxWidth,
    againstValueBoxHeight,
    thickness: 1,
    color: lineColor,
  );
  painter.drawLine(
    326,
    againstValueBoxBottomY,
    326 + 292,
    againstValueBoxBottomY,
    thickness: 1,
    color: lineColor,
  );

  const againstValueTextX = againstValueBoxX + 8;
  const againstValueTextSize = 8.0;
  final againstValueTextHeight = mono.heightAtSize(againstValueTextSize);
  final againstValueBaseY = againstValueBoxTopY - 4 - againstValueTextHeight;
  final noProtestY = content.hasInvoice
      ? againstValueBaseY - 12
      : againstValueBaseY;
  if (content.hasInvoice) {
    painter.drawText(
      labels.againstValue,
      x: againstValueTextX,
      y: againstValueBaseY,
      size: againstValueTextSize,
      font: mono,
      color: textPrimary,
    );
  }
  painter.drawText(
    labels.noProtest,
    x: againstValueTextX,
    y: noProtestY,
    size: againstValueTextSize,
    font: mono,
    color: textPrimary,
  );

  // Amount in words: another hairline band, running downward from y = 155.
  const amountWordsX = contentLeft - 6;
  const amountWordsWidth = 561.0;
  const amountWordsFirstLineY = 155.0;
  const amountWordsLastLineY = amountWordsFirstLineY - 10 * 2;
  for (var i = 0; i < 11; i++) {
    final y = amountWordsFirstLineY - i * 2;
    painter.drawLine(
      amountWordsX,
      y,
      amountWordsX + amountWordsWidth,
      y,
      thickness: 1,
      color: BillPdfColors.amountBand,
    );
  }

  final amountWordsText = billPdfUpperCase(content.amountInWords);
  final amountWordsTextWidth = mono.widthOfTextAtSize(amountWordsText, 8);
  final amountWordsTextHeight = mono.heightAtSize(8);
  const amountWordsBandHeight = amountWordsFirstLineY - amountWordsLastLineY;
  final amountWordsTextY =
      amountWordsLastLineY +
      (amountWordsBandHeight - amountWordsTextHeight) / 2;
  painter.drawText(
    amountWordsText,
    x: amountWordsX + (amountWordsWidth - amountWordsTextWidth) / 2,
    y: amountWordsTextY + 2,
    size: 8,
    font: mono,
    color: accent,
  );

  const amountWordsLabelSize = 6.0;
  final amountWordsLabelWidth = fonts.inter.widthOfTextAtSize(
    labels.amountInWords,
    amountWordsLabelSize,
  );
  final amountWordsLabelHeight = fonts.inter.heightAtSize(amountWordsLabelSize);
  final amountWordsLabelY = amountWordsLastLineY - 4 - amountWordsLabelHeight;
  painter.drawText(
    labels.amountInWords,
    x: amountWordsX + (amountWordsWidth - amountWordsLabelWidth) / 2,
    y: amountWordsLabelY + 3,
    size: amountWordsLabelSize,
    font: fonts.inter,
    color: textMuted,
  );

  renderFrontPageParties(
    painter: painter,
    billInfoLeft: billInfoLeft,
    labels: labels,
    content: content,
    issuerSignatureText: header.issuerSignatureText,
    signatureSize: header.signatureSize,
    fonts: fonts,
  );

  painter.drawPageNumber(
    labels.pageNumber(pageNumber, totalPages),
    right: contentRight - 5,
    y: 5,
    font: mono,
    color: textMuted,
  );
}
