import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'package:bitcr_ui/src/bill_pdf/back_page.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_assets.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_data.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_endorsement.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_labels.dart';
import 'package:bitcr_ui/src/bill_pdf/bill_pdf_layout.dart';
import 'package:bitcr_ui/src/bill_pdf/front_page.dart';
import 'package:bitcr_ui/src/bill_pdf/pdf_painter.dart';

/// Renders a printable copy of a bill of exchange and returns the PDF bytes.
///
/// The document is A4 landscape with two panels per sheet: the front panel,
/// then one back panel per five [endorsements] (at least one, so the back is
/// printed even before the first endorsement), each numbered "n of total".
/// [footerText] is centred at the foot of every sheet.
///
/// Fonts and the logo load from this package's assets through `rootBundle`,
/// so a Flutter binding must be initialised. Printing or sharing the bytes is
/// the caller's job (e.g. the `printing` package).
Future<Uint8List> createBillPdf(
  BillPdfContent content,
  List<BillPdfEndorsement> endorsements, {
  BillPdfLabels labels = kDefaultBillPdfLabels,
  String footerText =
      'Physical copy of electronic bill of exchange. Not the original.',
}) async {
  final document = PdfDocument();

  Future<BillPdfFont> loadFont(String key) async =>
      BillPdfFont(PdfTtfFont(document, await rootBundle.load(key)));

  final fonts = BillPdfFonts(
    morion: await loadFont(BillPdfAssets.morionRegular),
    inter: await loadFont(BillPdfAssets.interRegular),
    interSemiBold: await loadFont(BillPdfAssets.interSemiBold),
    geistMono: await loadFont(BillPdfAssets.geistMonoRegular),
    geistMonoMedium: await loadFont(BillPdfAssets.geistMonoMedium),
    malvinas: await loadFont(BillPdfAssets.malvinasSignature),
  );
  final logoData = await rootBundle.load(BillPdfAssets.logo);
  final logo = PdfImage.file(
    document,
    bytes: logoData.buffer.asUint8List(
      logoData.offsetInBytes,
      logoData.lengthInBytes,
    ),
  );

  final totalPanels = BillPdfLayout.panelCount(endorsements.length);

  void drawPanel(BillPdfPainter painter, int panelIndex) {
    if (panelIndex == 0) {
      renderFrontPage(
        painter: painter,
        content: content,
        labels: labels,
        logoImage: logo,
        fonts: fonts,
        pageNumber: 1,
        totalPages: totalPanels,
      );
    } else {
      renderBackPage(
        painter: painter,
        labels: labels,
        endorsements: endorsements,
        panelIndex: panelIndex - 1,
        pageNumber: panelIndex + 1,
        totalPages: totalPanels,
        fonts: fonts,
      );
    }
  }

  const sheetWidth = BillPdfLayout.sheetWidth;
  const sheetHeight = BillPdfLayout.sheetHeight;
  const padding = BillPdfLayout.panelPadding;
  const panelWidth = BillPdfLayout.panelWidth;
  const panelHeight = BillPdfLayout.panelHeight;
  const topPanelY = sheetHeight - (panelHeight + padding * 2) + padding;
  const bottomPanelY = padding;
  const footerSize = 8.0;
  final footerWidth = fonts.geistMono.widthOfTextAtSize(footerText, footerSize);

  for (var panel = 0; panel < totalPanels; panel += 2) {
    final page = PdfPage(
      document,
      pageFormat: const PdfPageFormat(sheetWidth, sheetHeight),
    );
    final painter = BillPdfPainter(page.getGraphics());

    // Each panel draws in its own translated context, clipped to the panel.
    void placePanel(int index, double y) {
      painter.fillRect(
        padding,
        y,
        panelWidth,
        panelHeight,
        BillPdfColors.sheetPanelBackground,
      );
      painter.graphics
        ..saveContext()
        ..setTransform(Matrix4.translationValues(padding, y, 0))
        ..drawRect(0, 0, panelWidth, panelHeight)
        ..clipPath();
      drawPanel(painter, index);
      painter.graphics.restoreContext();
    }

    placePanel(panel, topPanelY);
    if (panel + 1 < totalPanels) {
      placePanel(panel + 1, bottomPanelY);
    }

    painter.drawText(
      footerText,
      x: (sheetWidth - footerWidth) / 2,
      y: 5 + 19,
      size: footerSize,
      font: fonts.geistMono,
      color: BillPdfColors.footer,
    );
  }

  return document.save();
}
