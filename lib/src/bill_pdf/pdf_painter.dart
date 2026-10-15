import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'package:bitcr_ui/src/bill_pdf/pdf_text_truncation.dart';

/// An embedded TTF measured the way pdf-lib measures, which the layout
/// coordinates were tuned against.
class BillPdfFont implements BillPdfTextMeasure {
  BillPdfFont(this.font);

  final PdfTtfFont font;

  @override
  double widthOfTextAtSize(String text, double size) =>
      text.isEmpty ? 0 : font.stringMetrics(text).advanceWidth * size;

  /// pdf-lib's `heightAtSize`: hhea ascent to descent. With
  /// `descender: false` pdf-lib subtracts the descent in raw font units from
  /// a 1000-unit-em height — reproduced as is, since layout was tuned on it.
  double heightAtSize(double size, {bool descender = true}) {
    final parser = font.font;
    final scale = 1000 / parser.unitsPerEm;
    var height = (parser.ascent - parser.descent) * scale;
    if (!descender) height -= parser.descent.abs();
    return height / 1000 * size;
  }
}

/// The six typefaces the bill is set in.
class BillPdfFonts {
  const BillPdfFonts({
    required this.morion,
    required this.inter,
    required this.interSemiBold,
    required this.geistMono,
    required this.geistMonoMedium,
    required this.malvinas,
  });

  final BillPdfFont morion;
  final BillPdfFont inter;
  final BillPdfFont interSemiBold;
  final BillPdfFont geistMono;
  final BillPdfFont geistMonoMedium;
  final BillPdfFont malvinas;
}

/// Drawing calls over [PdfGraphics] in PDF-native coordinates: origin
/// bottom-left, y up.
class BillPdfPainter {
  BillPdfPainter(this.graphics);

  final PdfGraphics graphics;

  /// Draws [text] with its baseline starting at ([x], [y]). With [rotate90]
  /// the text runs upwards, turned counter-clockwise about that point.
  void drawText(
    String text, {
    required double x,
    required double y,
    required double size,
    required BillPdfFont font,
    required PdfColor color,
    bool rotate90 = false,
  }) {
    if (text.isEmpty) return;
    graphics.setFillColor(color);
    if (!rotate90) {
      graphics.drawString(font.font, size, text, x, y);
      return;
    }
    graphics.saveContext();
    graphics.setTransform(
      Matrix4.translationValues(x, y, 0)..rotateZ(math.pi / 2),
    );
    graphics.drawString(font.font, size, text, 0, 0);
    graphics.restoreContext();
  }

  void drawLine(
    double x1,
    double y1,
    double x2,
    double y2, {
    required double thickness,
    required PdfColor color,
  }) {
    graphics
      ..setStrokeColor(color)
      ..setLineWidth(thickness)
      ..drawLine(x1, y1, x2, y2)
      ..strokePath();
  }

  void fillRect(
    double x,
    double y,
    double width,
    double height,
    PdfColor color,
  ) {
    graphics
      ..setFillColor(color)
      ..drawRect(x, y, width, height)
      ..fillPath();
  }

  void strokeRect(
    double x,
    double y,
    double width,
    double height, {
    required double thickness,
    required PdfColor color,
  }) {
    graphics
      ..setStrokeColor(color)
      ..setLineWidth(thickness)
      ..drawRect(x, y, width, height)
      ..strokePath();
  }

  void drawImage(
    PdfImage image,
    double x,
    double y,
    double width,
    double height,
  ) {
    graphics.drawImage(image, x, y, width, height);
  }

  /// Draws text one code point at a time, rotated 90°, with [tracking] points
  /// between glyphs.
  void drawTrackedRotatedText(
    String text, {
    required double x,
    required double y,
    required double size,
    required BillPdfFont font,
    required PdfColor color,
    required double tracking,
  }) {
    var cursorY = y;
    for (final rune in text.runes) {
      final glyph = String.fromCharCode(rune);
      drawText(
        glyph,
        x: x,
        y: cursorY,
        size: size,
        font: font,
        color: color,
        rotate90: true,
      );
      cursorY += font.widthOfTextAtSize(glyph, size) + tracking;
    }
  }

  /// "1 of 3", right-aligned to [right].
  void drawPageNumber(
    String value, {
    required double right,
    required double y,
    required BillPdfFont font,
    required PdfColor color,
    double size = 8,
  }) {
    drawText(
      value,
      x: right - font.widthOfTextAtSize(value, size),
      y: y,
      size: size,
      font: font,
      color: color,
    );
  }
}

/// Width of [text] with [tracking] points between consecutive characters.
double measureTrackedWidth(
  String text,
  BillPdfFont font,
  double size,
  double tracking,
) {
  if (text.isEmpty) return 0;
  return font.widthOfTextAtSize(text, size) + tracking * (text.length - 1);
}

/// pdf-lib `rgb(r, g, b)` from 0–255 channels.
PdfColor billPdfRgb255(int r, int g, int b) =>
    PdfColor(r / 255, g / 255, b / 255);

/// Colors shared by the front and back panels.
abstract final class BillPdfColors {
  static final PdfColor panelBackground = billPdfRgb255(0xfe, 0xfb, 0xf1);
  static final PdfColor sheetPanelBackground = billPdfRgb255(0xf6, 0xf2, 0xe7);
  static final PdfColor footer = billPdfRgb255(0x8d, 0x85, 0x79);
  static const PdfColor line = PdfColor(0.85, 0.84, 0.82);
  static const PdfColor textMuted = PdfColor(0.55, 0.52, 0.47);
  static const PdfColor textPrimary = PdfColor(0.11, 0.06, 0);
  static const PdfColor accent = PdfColor(0, 0, 0.67);
  static final PdfColor doubleRule = billPdfRgb255(0xa3, 0x9d, 0x91);
  static final PdfColor amountBand = billPdfRgb255(0xec, 0xe8, 0xde);
}
