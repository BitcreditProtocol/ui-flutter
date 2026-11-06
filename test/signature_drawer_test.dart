import 'dart:async';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _labels = SignatureDrawerLabels(
  by: 'By',
  onBehalfOf: 'On behalf of',
  placeAndDate: 'Place, date:',
  date: 'Date:',
  confirm: 'Confirm signature',
  cancel: 'Cancel',
);

Future<Future<bool>> _open(
  WidgetTester tester, {
  String? location = 'Vienna (AT)',
  String? companyName,
  bool isAnonymous = false,
  Future<bool> Function()? onConfirm,
}) async {
  late Future<bool> result;

  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => result = showSignatureDrawer(
                context,
                title: 'Signed',
                labels: _labels,
                signerName: 'Ada Lovelace',
                date: '05 Nov 2026',
                location: location,
                companyName: companyName,
                isAnonymous: isAnonymous,
                onConfirm: onConfirm,
              ),
              child: const Text('Sign'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Sign'));
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('shows the signer in handwriting with place and date', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Signed'), findsOneWidget);
    expect(find.text('By'), findsOneWidget);
    expect(find.text('Place, date:'), findsOneWidget);
    expect(find.text('Vienna (AT), 05 Nov 2026'), findsOneWidget);
    expect(find.text('On behalf of'), findsNothing);
    expect(
      tester.widget<Text>(find.text('Ada Lovelace')).style?.fontFamily,
      BitcrFonts.handwriting,
    );
  });

  testWidgets('without a location only the date shows', (tester) async {
    await _open(tester, location: '');

    expect(find.text('Place, date:'), findsOneWidget);
    expect(find.text('05 Nov 2026'), findsOneWidget);
  });

  testWidgets('an anonymous signature hides the place', (tester) async {
    await _open(tester, isAnonymous: true);

    expect(find.text('Date:'), findsOneWidget);
    expect(find.text('05 Nov 2026'), findsOneWidget);
    expect(find.textContaining('Vienna'), findsNothing);
  });

  testWidgets('a company signature names the company', (tester) async {
    await _open(tester, companyName: 'Acme Ltd');

    expect(find.text('On behalf of'), findsOneWidget);
    expect(find.text('Acme Ltd'), findsOneWidget);
  });

  testWidgets('confirming without a callback resolves true', (tester) async {
    final result = await _open(tester);

    await tester.tap(find.text('Confirm signature'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(find.text('Signed'), findsNothing);
  });

  testWidgets('cancelling resolves false', (tester) async {
    final result = await _open(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('a failed confirmation keeps the drawer open', (tester) async {
    final pending = Completer<bool>();
    var calls = 0;
    final result = await _open(
      tester,
      onConfirm: () {
        calls++;
        return pending.future;
      },
    );

    await tester.tap(find.text('Confirm signature'));
    await tester.pump();

    expect(find.byType(Spinner), findsOneWidget);
    expect(find.text('Confirm signature'), findsNothing);

    await tester.tap(find.byType(Spinner));
    await tester.pump();
    expect(calls, 1);

    pending.complete(false);
    await tester.pump();
    await tester.pump();

    expect(find.byType(Spinner), findsNothing);
    expect(find.text('Confirm signature'), findsOneWidget);
    expect(find.text('Signed'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('a successful confirmation closes with true', (tester) async {
    final result = await _open(tester, onConfirm: () async => true);

    await tester.tap(find.text('Confirm signature'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(find.text('Signed'), findsNothing);
  });
}
