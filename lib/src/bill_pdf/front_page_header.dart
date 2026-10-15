import 'package:pdf/pdf.dart';

import 'package:bitcr_ui/src/bill_pdf/bill_pdf_data.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';

/// Where the header ends, for the rest of the front panel to align against.
class FrontPageHeaderResult {
  const FrontPageHeaderResult({
    required this.billInfoDividerX,
    required this.signatureSize,
    required this.signatureText,
    required this.issuerSignatureText,
  });

  final double billInfoDividerX;
  final double signatureSize;
  final String signatureText;
  final String issuerSignatureText;
}

/// The left of the front panel: logo, the vertical "International / Bill of
/// exchange" title, and the acceptance column.
FrontPageHeaderResult renderFrontPageHeader({
  required BillPdfPainter painter,
  required double height,
  required BillPdfLabels labels,
  required BillPdfContent content,
  required PdfImage logoImage,
  required BillPdfFonts fonts,
}) {
  const lineColor = BillPdfColors.line;
  const textMuted = BillPdfColors.textMuted;
  const textPrimary = BillPdfColors.textPrimary;
  const accent = BillPdfColors.accent;

  painter.drawText(
    labels.front,
    x: 5,
    y: height - 13,
    size: 8,
    font: fonts.geistMono,
    color: textMuted,
  );

  painter.drawLine(166, 0, 166, height, thickness: 1, color: lineColor);

  const titleSize = 18.0;
  const titleTracking = titleSize * 0.03;
  final internationalText = billPdfUpperCase(labels.international);
  final billText = billPdfUpperCase(labels.billOfExchange);
  final trackedInternationalWidth = measureTrackedWidth(
    internationalText,
    fonts.morion,
    titleSize,
    titleTracking,
  );
  final trackedBillWidth = measureTrackedWidth(
    billText,
    fonts.morion,
    titleSize,
    titleTracking,
  );
  final billY = height / 2 - trackedBillWidth / 2;
  final internationalY = height / 2 - trackedInternationalWidth / 2;

  const logoSize = 40.0;
  const logoX = 13.0;
  final logoY = (height - logoSize) / 2;
  painter.drawImage(logoImage, logoX, logoY, logoSize, logoSize);

  final titleThickness = fonts.morion.heightAtSize(titleSize);
  final titleStartX = logoX + logoSize + 7 + titleThickness;
  final billTitleX = titleStartX + titleSize + 2;

  painter.drawTrackedRotatedText(
    internationalText,
    x: titleStartX - 3,
    y: internationalY,
    size: titleSize,
    font: fonts.morion,
    color: textPrimary,
    tracking: titleTracking,
  );
  painter.drawTrackedRotatedText(
    billText,
    x: billTitleX - 3,
    y: billY,
    size: titleSize,
    font: fonts.morion,
    color: textPrimary,
    tracking: titleTracking,
  );

  final maxAcceptanceHeight = height - 16;
  const lineStartY = 0.0;
  final lineEndY = height;
  final lineCenterY = (lineStartY + lineEndY) / 2;
  const acceptedSize = 8.0;
  const acceptedAndNameOffsetFromTitle = 22.0;
  final acceptedAndNameLeftX = billTitleX + acceptedAndNameOffsetFromTitle;
  final acceptedX =
      acceptedAndNameLeftX + fonts.inter.heightAtSize(acceptedSize);
  const acceptedBottomOffset = 24.0;
  final acceptedLabelHeight = fonts.inter.widthOfTextAtSize(
    labels.accepted,
    acceptedSize,
  );
  const acceptedNameGap = 45.0;
  final maxAcceptedNameHeight =
      maxAcceptanceHeight -
      acceptedBottomOffset -
      acceptedLabelHeight -
      acceptedNameGap;

  const uppercaseSize = 10.0;
  final uppercaseX =
      acceptedAndNameLeftX + fonts.geistMonoMedium.heightAtSize(uppercaseSize);
  final uppercaseText = truncateTextToWidth(
    fonts.geistMonoMedium,
    uppercaseSize,
    billPdfUpperCase(content.payerName),
    maxAcceptedNameHeight,
    slack: 10,
  );
  final uppercaseWidth = fonts.geistMonoMedium.widthOfTextAtSize(
    uppercaseText,
    uppercaseSize,
  );
  final uppercaseY = lineCenterY - uppercaseWidth / 2;

  painter.drawText(
    labels.accepted,
    x: acceptedX,
    y: acceptedBottomOffset,
    size: acceptedSize,
    font: fonts.inter,
    color: textMuted,
    rotate90: true,
  );

  if (content.isAccepted) {
    painter.drawText(
      uppercaseText,
      x: uppercaseX,
      y: uppercaseY,
      size: uppercaseSize,
      font: fonts.geistMonoMedium,
      color: accent,
      rotate90: true,
    );
  }

  painter.drawLine(
    142,
    lineStartY,
    142,
    lineEndY,
    thickness: 1,
    color: lineColor,
  );

  const addressSize = 8.0;
  final addressTextX = 142 + 6 + fonts.geistMono.heightAtSize(addressSize);
  final payerAddress = content.payerAddress;
  final uppercaseAddressText = truncateTextToWidth(
    fonts.geistMono,
    addressSize,
    billPdfUpperCase(
      payerAddress == null || payerAddress.isEmpty ? '-' : payerAddress,
    ),
    maxAcceptanceHeight,
    slack: 10,
  );
  final uppercaseAddressWidth = fonts.geistMono.widthOfTextAtSize(
    uppercaseAddressText,
    addressSize,
  );
  final uppercaseAddressY = lineCenterY - uppercaseAddressWidth / 2;
  if (content.isAccepted) {
    painter.drawText(
      uppercaseAddressText,
      x: addressTextX,
      y: uppercaseAddressY,
      size: addressSize,
      font: fonts.geistMono,
      color: accent,
      rotate90: true,
    );
  }

  final signatureLineX = addressTextX + 8;
  final signatureLabelLineX = signatureLineX + 24;
  painter.drawLine(
    signatureLabelLineX,
    lineStartY,
    signatureLabelLineX,
    lineEndY,
    thickness: 1,
    color: lineColor,
  );

  const signatureSize = 24.0;
  const payerSignatureSize = 24.0;
  final signatureText = truncateTextToWidth(
    fonts.malvinas,
    payerSignatureSize,
    content.payerSignatureName,
    maxAcceptanceHeight,
    slack: 10,
  );
  final signatureWidth = fonts.malvinas.widthOfTextAtSize(
    signatureText,
    payerSignatureSize,
  );
  final issuerSignatureText = truncateTextToWidth(
    fonts.malvinas,
    signatureSize,
    content.issuerSignatureName,
    maxAcceptanceHeight,
    slack: 10,
  );

  final signatureY = lineCenterY - signatureWidth / 2;
  final signatureThickness = fonts.malvinas.heightAtSize(payerSignatureSize);
  const signatureLaneInset = 2.0;
  final signatureLaneLeft = signatureLineX + signatureLaneInset;
  final signatureLaneRight = signatureLabelLineX - signatureLaneInset;
  final signatureLaneWidth = signatureLaneRight - signatureLaneLeft;
  final signatureLeftX =
      signatureLaneLeft + (signatureLaneWidth - signatureThickness) / 2;
  final signatureTextX = signatureLeftX + signatureThickness;

  if (content.isAccepted) {
    painter.drawText(
      signatureText,
      x: signatureTextX - 3,
      y: signatureY,
      size: payerSignatureSize,
      font: fonts.malvinas,
      color: accent,
      rotate90: true,
    );
  }

  const signatureLabelSize = 6.0;
  final signatureLabelWidth = fonts.interSemiBold.widthOfTextAtSize(
    labels.signatureOfAccepted,
    signatureLabelSize,
  );
  final signatureLabelY = lineCenterY - signatureLabelWidth / 2;
  final signatureLabelThickness = fonts.interSemiBold.heightAtSize(
    signatureLabelSize,
  );
  final signatureLabelX = signatureLabelLineX + 4 + signatureLabelThickness;
  painter.drawText(
    labels.signatureOfAccepted,
    x: signatureLabelX,
    y: signatureLabelY,
    size: signatureLabelSize,
    font: fonts.interSemiBold,
    color: textMuted,
    rotate90: true,
  );

  final signatureLabelLeftX = signatureLabelX - signatureLabelThickness;
  final signatureLabelRightX = signatureLabelLeftX + signatureLabelThickness;
  final billInfoDividerX = signatureLabelRightX + 6;
  painter.drawLine(
    billInfoDividerX,
    lineStartY,
    billInfoDividerX,
    lineEndY,
    thickness: 2,
    color: billPdfRgb255(0xba, 0xb4, 0xa9),
  );

  return FrontPageHeaderResult(
    billInfoDividerX: billInfoDividerX,
    signatureSize: signatureSize,
    signatureText: signatureText,
    issuerSignatureText: issuerSignatureText,
  );
}
