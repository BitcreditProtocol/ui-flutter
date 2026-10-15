import 'package:bitcr_ui/src/bill_pdf/amount_to_words.dart';

/// Every string the bill PDF prints. The library ships no copy of its own, so
/// a localised app passes its own set; [kDefaultBillPdfLabels] is the English
/// wording the web build uses.
class BillPdfLabels {
  const BillPdfLabels({
    required this.international,
    required this.billOfExchange,
    required this.placeAndDateOfIssue,
    required this.placeOfPayment,
    required this.againstThisBill,
    required this.toTheOrderOf,
    required this.amount,
    required this.amountInWords,
    required this.payer,
    required this.issuer,
    required this.signatures,
    required this.accepted,
    required this.signatureLabel,
    required this.paymentInstructions,
    required this.signatureOfAccepted,
    required this.front,
    required this.againstValue,
    required this.noProtest,
    required this.pageNumber,
    required this.amountWords,
    required this.endorsements,
    required this.payToTheOrderOf,
    required this.back,
  });

  final String international;
  final String billOfExchange;
  final String placeAndDateOfIssue;
  final String placeOfPayment;
  final String againstThisBill;
  final String toTheOrderOf;
  final String amount;
  final String amountInWords;
  final String payer;
  final String issuer;
  final String signatures;
  final String accepted;
  final String signatureLabel;
  final String paymentInstructions;
  final String signatureOfAccepted;
  final String front;
  final String againstValue;
  final String noProtest;
  final String Function(int current, int total) pageNumber;
  final AmountToWordsLabels amountWords;

  final String endorsements;
  final String payToTheOrderOf;
  final String back;
}

String _defaultPageNumber(int current, int total) => '$current of $total';

const AmountToWordsLabels kDefaultAmountToWordsLabels = AmountToWordsLabels(
  ones: [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ],
  tens: [
    'zero',
    'ten',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ],
  orders: [
    'zero',
    'thousand',
    'million',
    'billion',
    'trillion',
    'quadrillion',
    'quintillion',
  ],
  hundred: 'hundred',
  bitcoin: 'Bitcoin',
  point: 'point',
);

const BillPdfLabels kDefaultBillPdfLabels = BillPdfLabels(
  international: 'International',
  billOfExchange: 'Bill of exchange',
  placeAndDateOfIssue: 'Place and date of issue',
  placeOfPayment: 'Place of payment',
  againstThisBill: 'Against this bill of exchange pay on',
  toTheOrderOf: 'to the order of',
  amount: 'Amount',
  amountInWords: 'Amount in words',
  payer: 'Payer:',
  issuer: 'Issuer:',
  signatures: 'Signature:',
  accepted: 'Accepted:',
  signatureLabel: 'Signature:',
  paymentInstructions: 'Payment instruction:',
  signatureOfAccepted: 'Signature of the acceptor',
  front: 'Front',
  againstValue: 'Against value.',
  noProtest: 'No protest.',
  pageNumber: _defaultPageNumber,
  amountWords: kDefaultAmountToWordsLabels,
  endorsements: 'Endorsements',
  payToTheOrderOf: 'Pay to the order of',
  back: 'Back',
);
