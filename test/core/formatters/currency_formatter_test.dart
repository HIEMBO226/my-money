import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats XOF without decimals', () {
      final result = CurrencyFormatter.format(15000, currencyCode: 'XOF');
      expect(result, contains('15'));
      expect(result, contains('000'));
      expect(result, contains('FCFA'));
      expect(result, isNot(contains(',')));
    });

    test('formats EUR with 2 decimals', () {
      final result = CurrencyFormatter.format(12550, currencyCode: 'EUR');
      expect(result, contains('125,50'));
      expect(result, contains('€'));
    });

    test('formats USD with 2 decimals', () {
      final result = CurrencyFormatter.format(1050, currencyCode: 'USD');
      expect(result, contains(r'$10.50'));
    });

    test('formats TND with 3 decimals', () {
      final result = CurrencyFormatter.format(1250, currencyCode: 'TND');
      expect(result, contains('1,250'));
      expect(result, contains('TND'));
    });

    test('parses string to smallest unit for EUR', () {
      expect(
        CurrencyFormatter.parseToSmallestUnit('12,50', currencyCode: 'EUR'),
        1250,
      );
      expect(
        CurrencyFormatter.parseToSmallestUnit('12.50', currencyCode: 'EUR'),
        1250,
      );
    });

    test('parses string to smallest unit for XOF', () {
      expect(
        CurrencyFormatter.parseToSmallestUnit('5 000', currencyCode: 'XOF'),
        5000,
      );
    });

    test('returns 0 for invalid input', () {
      expect(
        CurrencyFormatter.parseToSmallestUnit('abc', currencyCode: 'EUR'),
        0,
      );
    });
  });
}
