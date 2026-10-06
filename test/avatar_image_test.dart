// Avatar loaded pictures over the network only, so an app could not show one
// that has no URL yet — a picture just chosen on the device, waiting to be
// uploaded. The provider slot covers that without giving up the clipping,
// cover-fit and decode-at-display-size the URL path already had.

import 'dart:typed_data';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 1x1 transparent PNG, the smallest thing MemoryImage will decode.
final _pixel = Uint8List.fromList([
  ...[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  ...[0, 0, 0, 0x0D, 0x49, 0x48, 0x44, 0x52],
  ...[0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0],
  ...[0x1F, 0x15, 0xC4, 0x89],
  ...[0, 0, 0, 0x0A, 0x49, 0x44, 0x41, 0x54],
  ...[0x78, 0x9C, 0x63, 0, 1, 0, 0, 5, 0, 1],
  ...[0x0D, 0x0A, 0x2D, 0xB4],
  ...[0, 0, 0, 0, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82],
]);

Future<void> _pump(WidgetTester tester, Avatar avatar) => tester.pumpWidget(
  MaterialApp(
    theme: BitcrTheme.light,
    home: Scaffold(body: Center(child: avatar)),
  ),
);

void main() {
  testWidgets('a provider renders without a url', (tester) async {
    await _pump(
      tester,
      Avatar(name: 'Ada Lovelace', image: MemoryImage(_pixel)),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a provider wins over a url', (tester) async {
    await _pump(
      tester,
      Avatar(
        name: 'Ada Lovelace',
        imageUrl: 'https://example.com/ada.png',
        image: MemoryImage(_pixel),
      ),
    );

    final resize =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;

    expect(resize.imageProvider, isA<MemoryImage>());
  });

  testWidgets('with neither, only the initials show', (tester) async {
    await _pump(tester, const Avatar(name: 'Ada Lovelace'));

    expect(find.byType(Image), findsNothing);
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('xl is 64 so a profile header can use the scale', (tester) async {
    await _pump(
      tester,
      const Avatar(name: 'Ada Lovelace', size: AvatarSize.xl),
    );

    expect(tester.getSize(find.byType(Avatar)), const Size(64, 64));
  });
}
