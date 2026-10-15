/// One endorsement row on the back of the bill.
class BillPdfEndorsement {
  const BillPdfEndorsement({
    required this.label,
    required this.payeeName,
    required this.payeeAddressLine1,
    required this.payeeAddressLine2,
    required this.signerName,
    required this.signatureName,
    required this.signaturePlace,
    required this.signatureDate,
  });

  final String label;
  final String payeeName;
  final String payeeAddressLine1;
  final String payeeAddressLine2;
  final String signerName;
  final String signatureName;
  final String signaturePlace;
  final String signatureDate;
}

/// The block types that transfer a bill, and so print an endorsement.
const List<String> kBillPdfEndorsingBlockTypes = [
  'Endorse',
  'Mint',
  'Sell',
  'Recourse',
];

String billPdfEndorsementLabel(bool isPayeeBearer) =>
    isPayeeBearer ? 'Pay to' : 'Pay to the order of';
