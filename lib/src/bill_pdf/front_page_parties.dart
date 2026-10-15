import 'package:bitcr_ui/src/bill_pdf/bill_pdf_data.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';

/// The bottom of the front panel: payer (left), issuer and issuer signature
/// (right), and the payment instruction under the payer.
void renderFrontPageParties({
  required BillPdfPainter painter,
  required double billInfoLeft,
  required BillPdfLabels labels,
  required BillPdfContent content,
  required String issuerSignatureText,
  required double signatureSize,
  required BillPdfFonts fonts,
}) {
  const textMuted = BillPdfColors.textMuted;
  const accent = BillPdfColors.accent;
  final rule = BillPdfColors.doubleRule;

  const payerLaneWidth = 267.0;
  final payerNameText = truncateTextToWidth(
    fonts.geistMonoMedium,
    10,
    billPdfUpperCase(content.payerName),
    payerLaneWidth,
    slack: 10,
  );

  painter.drawText(
    labels.payer,
    x: billInfoLeft,
    y: 108,
    size: 8,
    font: fonts.interSemiBold,
    color: textMuted,
  );
  painter.drawText(
    payerNameText,
    x: billInfoLeft,
    y: 88,
    size: 10,
    font: fonts.geistMonoMedium,
    color: accent,
  );

  const payerDividerTopY = 53.0;
  const payerAddressBottomGap = 9.5;
  const payerAddressLineHeight = 8.5 * 1.4;
  const payerAddressLine2Y = payerDividerTopY + payerAddressBottomGap;
  const payerAddressLine1Y = payerAddressLine2Y + payerAddressLineHeight;
  final payerAddressLine1Text = truncateTextToWidth(
    fonts.geistMono,
    8.5,
    content.payerAddressLine1,
    payerLaneWidth,
    slack: 10,
  );
  painter.drawText(
    payerAddressLine1Text,
    x: billInfoLeft,
    y: payerAddressLine1Y,
    size: 8.5,
    font: fonts.geistMono,
    color: accent,
  );

  if (content.payerAddressLine2.isNotEmpty) {
    painter.drawText(
      truncateFirstSegmentToWidth(
        fonts.geistMono,
        8.5,
        content.payerAddressLine2,
        payerLaneWidth,
      ),
      x: billInfoLeft,
      y: payerAddressLine2Y,
      size: 8.5,
      font: fonts.geistMono,
      color: accent,
    );
  }

  painter.drawLine(
    billInfoLeft,
    53,
    billInfoLeft + 267,
    53,
    thickness: 1,
    color: rule,
  );
  painter.drawLine(
    billInfoLeft,
    51,
    billInfoLeft + 267,
    51,
    thickness: 1,
    color: rule,
  );

  // Payment instruction.
  final paymentFlowX = billInfoLeft;
  const paymentFlowWidth = 267.0;
  const paymentAddressSize = 8.5;
  const paymentAddressBottomOffset = 14.0;
  const paymentAddressLineGap = 2.0;
  final paymentAddressLineHeight = fonts.geistMono.heightAtSize(
    paymentAddressSize,
  );
  final paymentAddressDescender =
      paymentAddressLineHeight -
      fonts.geistMono.heightAtSize(paymentAddressSize, descender: false);
  final paymentAddressLine2Y =
      paymentAddressBottomOffset + paymentAddressDescender;
  final paymentAddressLine1Y =
      paymentAddressLine2Y + paymentAddressLineHeight + paymentAddressLineGap;
  const paymentInstructionsSize = 6.0;
  final paymentAddress = splitToTwoLines(
    fonts.geistMono,
    paymentAddressSize,
    content.paymentAddress,
    paymentFlowWidth,
  );
  final isTwoLinePaymentAddress = paymentAddress.line2.isNotEmpty;
  // Single- and two-line addresses start on the same line; only the second
  // line is conditional.
  final paymentInstructionsY = paymentAddressLine1Y + 6;

  painter.drawText(
    labels.paymentInstructions,
    x: paymentFlowX,
    y: paymentInstructionsY + 3,
    size: paymentInstructionsSize,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  if (content.isPaymentRequested) {
    painter.drawText(
      paymentAddress.line1,
      x: paymentFlowX,
      y: paymentAddressLine1Y - 6,
      size: paymentAddressSize,
      font: fonts.geistMono,
      color: accent,
    );
    if (isTwoLinePaymentAddress) {
      painter.drawText(
        paymentAddress.line2,
        x: paymentFlowX,
        y: paymentAddressLine2Y,
        size: paymentAddressSize,
        font: fonts.geistMono,
        color: accent,
      );
    }
  }

  // Issuer: everything centred in its lane.
  final issuerX = billInfoLeft + 287;
  const issuerLaneWidth = 267.0;
  painter.drawText(
    labels.issuer,
    x: issuerX,
    y: 108,
    size: 8,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  void drawCentred(String text, double y, double size, BillPdfFont font) {
    final width = font.widthOfTextAtSize(text, size);
    painter.drawText(
      text,
      x: issuerX + (issuerLaneWidth - width) / 2,
      y: y,
      size: size,
      font: font,
      color: accent,
    );
  }

  drawCentred(
    truncateTextToWidth(
      fonts.geistMonoMedium,
      10,
      billPdfUpperCase(content.issuerName),
      issuerLaneWidth,
      slack: 10,
    ),
    88,
    10,
    fonts.geistMonoMedium,
  );
  drawCentred(
    truncateTextToWidth(
      fonts.geistMono,
      8.5,
      content.issuerAddressLine1,
      issuerLaneWidth,
      slack: 10,
    ),
    payerAddressLine1Y,
    8.5,
    fonts.geistMono,
  );
  if (content.issuerAddressLine2.isNotEmpty) {
    drawCentred(
      truncateFirstSegmentToWidth(
        fonts.geistMono,
        8.5,
        content.issuerAddressLine2,
        issuerLaneWidth,
      ),
      payerAddressLine2Y,
      8.5,
      fonts.geistMono,
    );
  }

  painter.drawLine(issuerX, 53, issuerX + 267, 53, thickness: 1, color: rule);
  painter.drawLine(issuerX, 51, issuerX + 267, 51, thickness: 1, color: rule);

  painter.drawText(
    labels.signatures,
    x: issuerX,
    y: 38,
    size: 6,
    font: fonts.interSemiBold,
    color: textMuted,
  );

  const maxSignatureWidth = 267.0;
  final issuerSignature = truncateTextToWidth(
    fonts.malvinas,
    signatureSize,
    issuerSignatureText,
    maxSignatureWidth,
    slack: 20,
  );
  final issuerSignatureWidth = fonts.malvinas.widthOfTextAtSize(
    issuerSignature,
    signatureSize,
  );
  painter.drawText(
    issuerSignature,
    x: issuerX + (maxSignatureWidth - issuerSignatureWidth) / 2,
    y: 8,
    size: signatureSize,
    font: fonts.malvinas,
    color: accent,
  );
}
