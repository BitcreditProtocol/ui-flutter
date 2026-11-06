const _flaglessCurrencies = {
  'xaf',
  'xag',
  'xau',
  'xcd',
  'xdr',
  'xof',
  'xpd',
  'xpf',
  'xpt',
};

String? countryFlag(String? country) {
  final upper = country?.toUpperCase() ?? '';

  if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper)) return null;

  return String.fromCharCodes(upper.codeUnits.map((unit) => unit + 0x1F1A5));
}

String? currencyFlag(String code) {
  final lower = code.toLowerCase();

  if (lower.length < 2 || _flaglessCurrencies.contains(lower)) return null;

  return countryFlag(lower == 'ang' ? 'NL' : lower.substring(0, 2));
}
