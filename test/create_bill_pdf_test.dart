import 'dart:convert';
import 'dart:typed_data';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

BillPdfContent _content({
  bool isAccepted = true,
  bool isPayeeBearer = false,
  bool hasInvoice = true,
  bool isPaymentRequested = true,
}) {
  const labels = kDefaultBillPdfLabels;
  return BillPdfContent(
    issuingPlace: 'Vienna, Austria, Mar 12, 2026',
    paymentPlace: 'Graz, Austria',
    maturityDate: 'Jun 12, 2026',
    payeeName: isPayeeBearer ? 'Bearer' : 'Muster Handels GmbH',
    payeeAddress: isPayeeBearer
        ? ''
        : 'Mariahilfer Straße 1, 1060 Vienna, Austria',
    amountDisplay: formatBillPdfAmount('150000000', 'sat'),
    amountInWords: billPdfAmountInWords('150000000', 'sat', labels.amountWords),
    payerName: 'Acme Trading AG',
    payerSignatureName: 'Jane Doe',
    payerAddress: 'Kärntner Straße 10, 1010 Vienna, Austria',
    payerAddressLine1: 'Kärntner Straße 10',
    payerAddressLine2: 'Vienna, Austria 1010',
    issuerName: 'Bitcredit Example Issuer Ltd',
    issuerSignatureName: 'John Smith',
    issuerAddress: 'Main Street 5, 8010 Graz, Austria',
    issuerAddressLine1: 'Main Street 5',
    issuerAddressLine2: 'Graz, Austria 8010',
    isAccepted: isAccepted,
    isPayeeBearer: isPayeeBearer,
    hasInvoice: hasInvoice,
    isPaymentRequested: isPaymentRequested,
    paymentAddress: isPaymentRequested
        ? 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'
              'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'
        : '',
  );
}

List<BillPdfEndorsement> _endorsements(int count) => [
  for (var i = 0; i < count; i++)
    BillPdfEndorsement(
      label: i.isEven ? 'Pay to the order of' : 'Pay to',
      payeeName: i.isEven ? 'Endorsee Number ${i + 1} GmbH' : 'Bearer',
      payeeAddressLine1: i.isEven ? 'Ringstraße ${i + 1}' : '-',
      payeeAddressLine2: i.isEven ? 'Vienna, Austria 1010' : '-',
      signerName: 'Signer ${i + 1}',
      signatureName: 'Signatory ${i + 1}',
      signaturePlace: 'Vienna',
      signatureDate: 'Apr ${(i % 28) + 1}, 2026',
    ),
];

/// Pages in [pdf], from the page tree's `/Count` (dictionaries are written
/// uncompressed by `package:pdf`).
int _pageCount(Uint8List pdf) {
  final text = latin1.decode(pdf);
  final counts = RegExp(r'/Count\s+(\d+)')
      .allMatches(text)
      .map((m) => int.parse(m.group(1)!));
  return counts.reduce((a, b) => a > b ? a : b);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BillPdfLayout', () {
    // endorsements -> (panels, sheets)
    const cases = <int, (int, int)>{
      0: (2, 1),
      1: (2, 1),
      5: (2, 1),
      6: (3, 2),
      10: (3, 2),
      11: (4, 2),
    };
    for (final MapEntry(key: endorsements, value: (panels, sheets))
        in cases.entries) {
      test(
        '$endorsements endorsements -> $panels panels on $sheets sheets',
        () {
          expect(BillPdfLayout.panelCount(endorsements), panels);
          expect(BillPdfLayout.sheetCount(endorsements), sheets);
        },
      );
    }
  });

  group('BillPdfAssets keys resolve against the bundle', () {
    for (final key in BillPdfAssets.all) {
      test(key, () async {
        final data = await rootBundle.load(key);
        expect(data.lengthInBytes, greaterThan(0));
      });
    }
  });

  test('page numbers read "n of total" in English', () {
    expect(kDefaultBillPdfLabels.pageNumber(1, 3), '1 of 3');
  });

  group('createBillPdf', () {
    test('renders a fully populated bill over three back panels', () async {
      final bytes = await createBillPdf(_content(), _endorsements(12));
      expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
      expect(_pageCount(bytes), BillPdfLayout.sheetCount(12));
    });

    test(
      'renders a bearer, unaccepted bill without a payment request',
      () async {
        final bytes = await createBillPdf(
          _content(
            isAccepted: false,
            isPayeeBearer: true,
            hasInvoice: false,
            isPaymentRequested: false,
          ),
          const [],
        );
        expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
        expect(_pageCount(bytes), 1);
      },
    );

    for (final count in [0, 1, 5, 6, 11]) {
      test('$count endorsements print on '
          '${BillPdfLayout.sheetCount(count)} sheets', () async {
        final bytes = await createBillPdf(_content(), _endorsements(count));
        expect(_pageCount(bytes), BillPdfLayout.sheetCount(count));
      });
    }
  });
}
