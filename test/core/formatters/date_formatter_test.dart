import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_money/core/formatters/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  group('DateFormatter', () {
    test('formats UTC date in local French format', () {
      final utcDate = DateTime.utc(2026, 11, 18, 12);
      final formatted = DateFormatter.formatDate(utcDate, locale: 'fr');
      expect(formatted, contains('2026'));
      expect(formatted.toLowerCase(), contains('nov'));
    });

    test('formats month and year in French and English', () {
      final utcDate = DateTime.utc(2026, 3, 15, 12);
      expect(
        DateFormatter.formatMonthYear(utcDate, locale: 'fr').toLowerCase(),
        contains('mars 2026'),
      );
      expect(
        DateFormatter.formatMonthYear(utcDate, locale: 'en').toLowerCase(),
        contains('march 2026'),
      );
    });

    test('formats relative dates for today and yesterday', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      expect(DateFormatter.formatRelative(now, locale: 'fr'), "Aujourd'hui");
      expect(DateFormatter.formatRelative(now, locale: 'en'), 'Today');
      expect(DateFormatter.formatRelative(yesterday, locale: 'fr'), 'Hier');
      expect(
        DateFormatter.formatRelative(yesterday, locale: 'en'),
        'Yesterday',
      );
    });

    test('formats dates using explicit user preference pattern', () {
      final localDate = DateTime(2026, 3, 7, 12);
      expect(
        DateFormatter.formatDate(localDate, pattern: 'dd/MM/yyyy'),
        '07/03/2026',
      );
      expect(
        DateFormatter.formatDate(localDate, pattern: 'MM/dd/yyyy'),
        '03/07/2026',
      );
      expect(
        DateFormatter.formatDate(localDate, pattern: 'yyyy-MM-dd'),
        '2026-03-07',
      );
    });
  });
}
