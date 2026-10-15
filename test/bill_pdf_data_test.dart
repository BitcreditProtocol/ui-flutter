// The pure-logic half of the bill PDF, asserted against output captured from
// the TypeScript `@bitcredit/ui-library/bill-pdf` module it was ported from.
// Every expectation in this file was produced by running the original, not by
// reading it — the formatting has enough edge cases (whitespace-only address
// parts kept, BTC displayed to two decimals but spelled to eight, satoshi
// counts past a double's exact range) that agreeing by inspection proves
// little.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final words = kDefaultBillPdfLabels.amountWords;

  group('formatBillPdfAmount', () {
    test(
      "150000 sat",
      () => expect(formatBillPdfAmount("150000", "sat"), "0.00150000 XBT"),
    );
    test(
      "1 sat",
      () => expect(formatBillPdfAmount("1", "sat"), "0.00000001 XBT"),
    );
    test(
      "0 sat",
      () => expect(formatBillPdfAmount("0", "sat"), "0.00000000 XBT"),
    );
    test(
      "100000000 SAT",
      () => expect(formatBillPdfAmount("100000000", "SAT"), "1.00000000 XBT"),
    );
    test(
      "123456789012 sats",
      () => expect(
        formatBillPdfAmount("123456789012", "sats"),
        "1,234.56789012 XBT",
      ),
    );
    test(
      "2100000000000000 sat",
      () => expect(
        formatBillPdfAmount("2100000000000000", "sat"),
        "21,000,000.00000000 XBT",
      ),
    );
    test(
      "0.5 btc",
      () => expect(formatBillPdfAmount("0.5", "btc"), "0.50 XBT"),
    );
    test("1 BTC", () => expect(formatBillPdfAmount("1", "BTC"), "1.00 XBT"));
    test(
      "1234.5 usd",
      () => expect(formatBillPdfAmount("1234.5", "usd"), "1,234.50 usd"),
    );
    test(
      "1234567.891 EUR",
      () =>
          expect(formatBillPdfAmount("1234567.891", "EUR"), "1,234,567.89 EUR"),
    );
    test("5 usd", () => expect(formatBillPdfAmount("5", "usd"), "5.00 usd"));
    test("abc usd", () => expect(formatBillPdfAmount("abc", "usd"), "abc usd"));
  });

  group('billPdfAmountInWords', () {
    test(
      "150000 sat",
      () => expect(
        billPdfAmountInWords("150000", "sat", words),
        "Bitcoin zero point zero zero one five zero zero zero zero",
      ),
    );
    test(
      "1 sat",
      () => expect(
        billPdfAmountInWords("1", "sat", words),
        "Bitcoin zero point zero zero zero zero zero zero zero one",
      ),
    );
    test(
      "0 sat",
      () => expect(billPdfAmountInWords("0", "sat", words), "Bitcoin zero"),
    );
    test(
      "100000000 SAT",
      () => expect(
        billPdfAmountInWords("100000000", "SAT", words),
        "Bitcoin one",
      ),
    );
    test(
      "123456789012 sats",
      () => expect(
        billPdfAmountInWords("123456789012", "sats", words),
        "Bitcoin one thousand two hundred thirty-four point five six seven eight nine zero one two",
      ),
    );
    test(
      "2100000000000000 sat",
      () => expect(
        billPdfAmountInWords("2100000000000000", "sat", words),
        "Bitcoin twenty-one million",
      ),
    );
    test(
      "0.5 btc",
      () => expect(
        billPdfAmountInWords("0.5", "btc", words),
        "Bitcoin zero point five zero zero zero zero zero zero zero",
      ),
    );
    test(
      "1 BTC",
      () => expect(billPdfAmountInWords("1", "BTC", words), "Bitcoin one"),
    );
    test(
      "1234.5 usd",
      () =>
          expect(billPdfAmountInWords("1234.5", "usd", words), "1,234.50 usd"),
    );
    test(
      "1234567.891 EUR",
      () => expect(
        billPdfAmountInWords("1234567.891", "EUR", words),
        "1,234,567.89 EUR",
      ),
    );
    test(
      "5 usd",
      () => expect(billPdfAmountInWords("5", "usd", words), "5.00 usd"),
    );
    test(
      "abc usd",
      () => expect(billPdfAmountInWords("abc", "usd", words), "abc usd"),
    );
  });

  group('btcAmountToWords', () {
    test(
      "0.00000000",
      () => expect(btcAmountToWords("0.00000000", words), "Bitcoin zero"),
    );
    test(
      "1.00000000",
      () => expect(btcAmountToWords("1.00000000", words), "Bitcoin one"),
    );
    test(
      "0.00150000",
      () => expect(
        btcAmountToWords("0.00150000", words),
        "Bitcoin zero point zero zero one five zero zero zero zero",
      ),
    );
    test(
      "21.00000001",
      () => expect(
        btcAmountToWords("21.00000001", words),
        "Bitcoin twenty-one point zero zero zero zero zero zero zero one",
      ),
    );
    test(
      "1234.56780000",
      () => expect(
        btcAmountToWords("1234.56780000", words),
        "Bitcoin one thousand two hundred thirty-four point five six seven eight zero zero zero zero",
      ),
    );
  });

  group('formatBillPdfDate', () {
    test(
      "2026-10-15",
      () => expect(formatBillPdfDate("2026-10-15"), "Oct 15, 2026"),
    );
    test(
      "2026-01-05",
      () => expect(formatBillPdfDate("2026-01-05"), "Jan 05, 2026"),
    );
    test(
      "2026-01-05T12:30:00Z",
      () => expect(formatBillPdfDate("2026-01-05T12:30:00Z"), "Jan 05, 2026"),
    );
    test("(empty)", () => expect(formatBillPdfDate(""), "-"));
    test(
      "not-a-date",
      () => expect(formatBillPdfDate("not-a-date"), "not-a-date"),
    );
  });

  group('formatBillPdfLocation', () {
    test(
      'case 0',
      () => expect(
        formatBillPdfLocation("Vienna", "AT", "2026-10-15"),
        "Vienna, AT, Oct 15, 2026",
      ),
    );
    test('case 1', () => expect(formatBillPdfLocation("", "", ""), "-"));
    test(
      'case 2',
      () => expect(formatBillPdfLocation("Vienna", "", ""), "Vienna"),
    );
  });

  group('addresses', () {
    test(
      'format 0',
      () => expect(
        formatBillPdfAddress(
          const BillPdfPostalAddress(
            address: "Ring 1",
            zip: "1010",
            city: "Vienna",
            country: "AT",
          ),
        ),
        "Ring 1, 1010 Vienna, AT",
      ),
    );
    test(
      'format 1',
      () => expect(
        formatBillPdfAddress(
          const BillPdfPostalAddress(
            address: "  ",
            zip: null,
            city: "Vienna",
            country: "",
          ),
        ),
        "  , Vienna",
      ),
    );
    test(
      'format 2',
      () => expect(
        formatBillPdfAddress(
          const BillPdfPostalAddress(
            address: "Platz 3",
            zip: "",
            city: "",
            country: "DE",
          ),
        ),
        "Platz 3, DE",
      ),
    );
    test('lines 0', () {
      final lines = formatBillPdfAddressLines(
        const BillPdfPostalAddress(
          address: "Ring 1",
          zip: "1010",
          city: "Vienna",
          country: "AT",
        ),
      );
      expect(lines.line1, "Ring 1");
      expect(lines.line2, "Vienna, AT 1010");
    });
    test('lines 1', () {
      final lines = formatBillPdfAddressLines(
        const BillPdfPostalAddress(
          address: "  ",
          zip: null,
          city: "Vienna",
          country: "",
        ),
      );
      expect(lines.line1, "-");
      expect(lines.line2, "Vienna");
    });
    test('lines 2', () {
      final lines = formatBillPdfAddressLines(
        const BillPdfPostalAddress(
          address: "Platz 3",
          zip: "",
          city: "",
          country: "DE",
        ),
      );
      expect(lines.line1, "Platz 3");
      expect(lines.line2, "DE");
    });
    test(
      'place 0',
      () => expect(
        formatBillPdfPlace(
          const BillPdfPostalAddress(
            address: "Ring 1",
            zip: "1010",
            city: "Vienna",
            country: "AT",
          ),
        ),
        "Vienna",
      ),
    );
    test(
      'place 1',
      () => expect(
        formatBillPdfPlace(
          const BillPdfPostalAddress(
            address: "  ",
            zip: null,
            city: "Vienna",
            country: "",
          ),
        ),
        "Vienna",
      ),
    );
    test(
      'place 2',
      () => expect(
        formatBillPdfPlace(
          const BillPdfPostalAddress(
            address: "Platz 3",
            zip: "",
            city: "",
            country: "DE",
          ),
        ),
        "DE",
      ),
    );
    test('a missing address', () {
      expect(formatBillPdfAddress(null), "-");
      expect(formatBillPdfPlace(null), "-");
      final lines = formatBillPdfAddressLines(null);
      expect(lines.line1, "-");
      expect(lines.line2, "-");
    });
  });
}
