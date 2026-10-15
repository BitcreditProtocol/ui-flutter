import 'package:bitcr_ui/src/bill_pdf/amount_to_words.dart';

/// A payee that is the holder of the bill rather than a named party.
const String kBillPdfBearerName = 'Bearer';

const List<String> _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class BillPdfPostalAddress {
  const BillPdfPostalAddress({
    required this.address,
    required this.city,
    required this.country,
    this.zip,
  });

  final String address;
  final String city;
  final String country;
  final String? zip;
}

/// Everything the front page prints. Assembled by the app: the library knows
/// how to draw a bill, not how to read one.
class BillPdfContent {
  const BillPdfContent({
    required this.issuingPlace,
    required this.paymentPlace,
    required this.maturityDate,
    required this.payeeName,
    required this.payeeAddress,
    required this.amountDisplay,
    required this.amountInWords,
    required this.payerName,
    required this.payerSignatureName,
    required this.payerAddressLine1,
    required this.payerAddressLine2,
    required this.issuerName,
    required this.issuerSignatureName,
    required this.issuerAddressLine1,
    required this.issuerAddressLine2,
    required this.isAccepted,
    required this.isPayeeBearer,
    required this.hasInvoice,
    required this.isPaymentRequested,
    required this.paymentAddress,
    this.payerAddress,
    this.issuerAddress,
  });

  final String issuingPlace;
  final String paymentPlace;
  final String maturityDate;
  final String payeeName;
  final String payeeAddress;
  final String amountDisplay;
  final String amountInWords;
  final String payerName;
  final String payerSignatureName;
  final String? payerAddress;
  final String payerAddressLine1;
  final String payerAddressLine2;
  final String issuerName;
  final String issuerSignatureName;
  final String? issuerAddress;
  final String issuerAddressLine1;
  final String issuerAddressLine2;
  final bool isAccepted;
  final bool isPayeeBearer;
  final bool hasInvoice;
  final bool isPaymentRequested;
  final String paymentAddress;
}

/// Groups the integer part in threes, en-US style.
String _group(String fixed) {
  final parts = fixed.split('.');
  final negative = parts.first.startsWith('-');
  final digits = negative ? parts.first.substring(1) : parts.first;

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  final grouped = '${negative ? '-' : ''}$buffer';
  return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
}

/// Divides a decimal string by 1e8 and renders it with eight decimals,
/// without going through a double — a satoshi count can exceed what a double
/// represents exactly.
String? _satsToBtcFixed8(String sum) {
  final match = RegExp(r'^\s*(-?)(\d*)(?:\.(\d*))?\s*$').firstMatch(sum);
  if (match == null) return null;

  final sign = match.group(1) == '-' ? -1 : 1;
  final whole = match.group(2) ?? '';
  final fraction = match.group(3) ?? '';
  if (whole.isEmpty && fraction.isEmpty) return null;

  // value * 1e8 == the input itself, so rounding the input to a whole number
  // of satoshis is all that is needed before placing the point.
  final scaled = BigInt.parse(
    '${whole.isEmpty ? '0' : whole}'
    '${fraction.padRight(1, '0')}',
  );
  final divisor = BigInt.from(10).pow(fraction.isEmpty ? 1 : fraction.length);
  var units = scaled ~/ divisor;
  if ((scaled % divisor) * BigInt.two >= divisor) units += BigInt.one;

  final digits = units.toString().padLeft(9, '0');
  final whole8 = digits.substring(0, digits.length - 8);
  final frac8 = digits.substring(digits.length - 8);
  return '${sign < 0 ? '-' : ''}$whole8.$frac8';
}

bool _isBtcLike(String currency) => currency == 'SAT' || currency == 'SATS';

/// `02 Jan 2026` style, read in UTC so a date-only value does not slip a day.
String formatBillPdfDate(String? value) {
  if (value == null || value.isEmpty) return '-';

  DateTime? parsed;
  final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (dateOnly != null) {
    parsed = DateTime.utc(
      int.parse(dateOnly.group(1)!),
      int.parse(dateOnly.group(2)!),
      int.parse(dateOnly.group(3)!),
    );
  } else {
    parsed = DateTime.tryParse(value)?.toUtc();
  }

  if (parsed == null) return value;
  return '${_monthsShort[parsed.month - 1]} '
      '${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
}

/// The epoch-seconds form, read in local time as the web build does.
String formatBillPdfDateFromSeconds(num seconds) {
  if (!seconds.isFinite) return '-';
  final date = DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
  return '${_monthsShort[date.month - 1]} '
      '${date.day.toString().padLeft(2, '0')}, ${date.year}';
}

String formatBillPdfLocation(String? city, String? country, String? date) {
  final parts = [
    if (city != null && city.isNotEmpty) city,
    if (country != null && country.isNotEmpty) country,
    if (date != null && date.isNotEmpty) formatBillPdfDate(date),
  ];
  return parts.isEmpty ? '-' : parts.join(', ');
}

String formatBillPdfAmount(String sum, String currency) {
  final normalized = currency.toUpperCase();
  final displayCurrency = normalized == 'BTC' ? 'XBT' : currency;

  if (_isBtcLike(normalized)) {
    final btc = _satsToBtcFixed8(sum);
    if (btc != null) return '${_group(btc)} XBT';
  }

  final parsed = double.tryParse(sum.trim());
  if (parsed != null && parsed.isFinite) {
    return '${_group(parsed.toStringAsFixed(2))} $displayCurrency';
  }
  return '$sum $displayCurrency';
}

String billPdfAmountInWords(
  String sum,
  String currency,
  AmountToWordsLabels amountWordsLabels,
) {
  final normalized = currency.toUpperCase();

  if (_isBtcLike(normalized)) {
    final btc = _satsToBtcFixed8(sum);
    if (btc != null) return btcAmountToWords(btc, amountWordsLabels);
  }

  if (normalized == 'BTC') {
    final parsed = double.tryParse(sum.trim());
    if (parsed != null && parsed.isFinite) {
      return btcAmountToWords(parsed.toStringAsFixed(8), amountWordsLabels);
    }
  }

  return formatBillPdfAmount(sum, currency);
}

String formatBillPdfAddress(BillPdfPostalAddress? postalAddress) {
  if (postalAddress == null) return '-';
  final zipCity = [
    if (postalAddress.zip != null && postalAddress.zip!.isNotEmpty)
      postalAddress.zip!,
    if (postalAddress.city.isNotEmpty) postalAddress.city,
  ].join(' ');

  final parts = [
    if (postalAddress.address.isNotEmpty) postalAddress.address,
    if (zipCity.isNotEmpty) zipCity,
    if (postalAddress.country.isNotEmpty) postalAddress.country,
  ];
  return parts.isEmpty ? '' : parts.join(', ');
}

({String line1, String line2}) formatBillPdfAddressLines(
  BillPdfPostalAddress? postalAddress,
) {
  if (postalAddress == null) return (line1: '-', line2: '-');

  final cityCountry = [
    if (postalAddress.city.isNotEmpty) postalAddress.city,
    if (postalAddress.country.isNotEmpty) postalAddress.country,
  ].join(', ');
  final cityCountryZip = [
    if (cityCountry.isNotEmpty) cityCountry,
    if (postalAddress.zip != null && postalAddress.zip!.isNotEmpty)
      postalAddress.zip!,
  ].join(' ');

  return (
    line1: postalAddress.address.trim().isEmpty
        ? '-'
        : postalAddress.address.trim(),
    line2: cityCountryZip.isEmpty ? '-' : cityCountryZip,
  );
}

String formatBillPdfPlace(BillPdfPostalAddress? postalAddress) {
  if (postalAddress == null) return '-';
  if (postalAddress.city.isNotEmpty) return postalAddress.city;
  if (postalAddress.country.isNotEmpty) return postalAddress.country;
  return '-';
}
