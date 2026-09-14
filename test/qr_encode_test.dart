// What the QR encoder and the widgets over it do when a payload cannot be
// encoded, and how the animated one sizes itself.

import 'dart:async';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] and gives the encode isolate real time to land.
///
/// `pumpAndSettle` drives a fake clock, so it never sees a `compute` result —
/// it times out on the spinner's own animation instead.
Future<void> pumpEncoded(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(body: child),
    ),
  );
  await tester.runAsync(() async {
    await tester.pump();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  await tester.pump();
}

void main() {
  group('encodeQrMatrix', () {
    test('returns a matrix for a payload that fits', () {
      expect(encodeQrMatrix('bcrt1qexample'), isNotNull);
      expect(encodeQrMatrix('x' * 2000), isNotNull);
    });

    test('returns null past the largest QR version, rather than throwing', () {
      // `QrValidator` reports its own failures through `isValid`, but the
      // `QrImage` construction after it throws `InputTooLongException`. Run
      // through `compute` that becomes a rejected future, which every caller
      // here left unhandled -- and the widget waiting on it waited for ever.
      expect(encodeQrMatrix('x' * 3000), isNull);
      expect(encodeQrMatrix('x' * 50000), isNull);
    });
  });

  group('the error state', () {
    testWidgets('QrCode draws the placeholder instead of spinning', (
      tester,
    ) async {
      await pumpEncoded(tester, QrCode(data: 'x' * 5000));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(QrCodeUnavailable), findsOneWidget);
    });

    testWidgets('ExactQrCode does too', (tester) async {
      await pumpEncoded(
        tester,
        ExactQrCode(data: 'x' * 5000, color: Colors.black),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(QrCodeUnavailable), findsOneWidget);
    });

    testWidgets('errorBuilder replaces the placeholder', (tester) async {
      await pumpEncoded(
        tester,
        QrCode(
          data: 'x' * 5000,
          errorBuilder: (context) => const Text('too long'),
        ),
      );

      expect(find.text('too long'), findsOneWidget);
      expect(find.byType(QrCodeUnavailable), findsNothing);
    });

    testWidgets('a payload that fits still paints', (tester) async {
      await pumpEncoded(tester, const QrCode(data: 'bcrt1qexample'));

      expect(find.byType(QrCodeUnavailable), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('AnimatedQrCode sizing', () {
    testWidgets('fits a landscape box instead of overflowing it', (
      tester,
    ) async {
      // `AspectRatio` takes the width when the height is loose, so the square
      // came out taller than a wide-but-short box and the column overflowed --
      // 858 pixels on a 1920x1080 window through `showQrCodeFullscreen`.
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpEncoded(
        tester,
        Center(
          child: AnimatedQrCode(
            data: 'x' * 5000,
            padding: EdgeInsets.zero,
            enlargeOnTap: false,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AnimatedQrCode)).height,
        lessThanOrEqualTo(1080),
      );
    });

    testWidgets('still fills the width in a portrait box', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpEncoded(
        tester,
        Center(
          child: AnimatedQrCode(
            data: 'x' * 5000,
            padding: EdgeInsets.zero,
            enlargeOnTap: false,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AnimatedQrCode)).width, 400);
    });

    testWidgets('showQrCodeFullscreen no longer overflows on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          theme: BitcrTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      unawaited(showQrCodeFullscreen(ctx, data: 'x' * 5000));
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
