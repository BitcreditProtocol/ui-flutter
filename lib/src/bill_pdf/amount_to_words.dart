/// The number words a bill's "amount in words" line is built from.
///
/// Supplied rather than baked in: the library ships no strings.
class AmountToWordsLabels {
  const AmountToWordsLabels({
    required this.ones,
    required this.tens,
    required this.orders,
    required this.hundred,
    required this.bitcoin,
    required this.point,
  });

  final List<String> ones;
  final List<String> tens;
  final List<String> orders;
  final String hundred;
  final String bitcoin;
  final String point;
}

String _formatNum(int num, int div, String order, AmountToWordsLabels labels) {
  final upper = num ~/ div;
  final lower = num % div;
  return lower == 0
      ? '${_numbersToWords(upper, labels)} $order'
      : '${_numbersToWords(upper, labels)} $order '
            '${_numbersToWords(lower, labels)}';
}

String _numbersToWords(int num, AmountToWordsLabels labels) {
  if (num <= 19) return labels.ones[num];
  if (num <= 99) {
    final upper = num ~/ 10;
    final lower = num % 10;
    return lower == 0
        ? labels.tens[upper]
        : '${labels.tens[upper]}-${_numbersToWords(lower, labels)}';
  }
  if (num <= 999) return _formatNum(num, 100, labels.hundred, labels);

  for (
    var orderIndex = labels.orders.length - 1;
    orderIndex >= 1;
    orderIndex--
  ) {
    final div = BigInt.from(1000).pow(orderIndex);
    if (BigInt.from(num) >= div) {
      return _formatNum(num, div.toInt(), labels.orders[orderIndex], labels);
    }
  }

  return num.toString();
}

String _digitsToWords(String digits, AmountToWordsLabels labels) =>
    digits.split('').map((d) => labels.ones[int.parse(d)]).join(' ');

/// Spells out a decimal BTC amount: the integer part as words, the eight
/// fractional digits read out one by one.
String btcAmountToWords(String btcAmount, AmountToWordsLabels labels) {
  final parts = btcAmount.split('.');
  final integerPart = int.tryParse(parts.first);
  if (integerPart == null) return btcAmount;

  final integerWords = _numbersToWords(integerPart, labels);
  final fractionalDigits = (parts.length > 1 ? parts[1] : '').padRight(8, '0');

  if (fractionalDigits.isEmpty || RegExp(r'^0+$').hasMatch(fractionalDigits)) {
    return '${labels.bitcoin} $integerWords';
  }

  return '${labels.bitcoin} $integerWords ${labels.point} '
      '${_digitsToWords(fractionalDigits, labels)}';
}
