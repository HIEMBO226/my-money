import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String formatDate(
    DateTime date, {
    String locale = 'fr',
    String? pattern,
  }) {
    final local = date.toLocal();
    if (pattern != null && pattern.isNotEmpty) {
      return DateFormat(pattern, locale).format(local);
    }
    return DateFormat.yMMMd(locale).format(local);
  }

  static String formatDateFull(DateTime date, {String locale = 'fr'}) {
    final local = date.toLocal();
    return DateFormat.yMMMMEEEEd(locale).format(local);
  }

  static String formatTime(DateTime date, {String locale = 'fr'}) {
    final local = date.toLocal();
    return DateFormat.Hm(locale).format(local);
  }

  static String formatRelative(
    DateTime date, {
    String locale = 'fr',
    String? pattern,
  }) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(local.year, local.month, local.day);

    final difference = today.difference(dateDay).inDays;

    if (difference == 0) {
      return locale == 'fr' ? "Aujourd'hui" : 'Today';
    } else if (difference == 1) {
      return locale == 'fr' ? 'Hier' : 'Yesterday';
    } else {
      return formatDate(date, locale: locale, pattern: pattern);
    }
  }

  static String formatMonthYear(DateTime date, {String locale = 'fr'}) {
    final local = date.toLocal();
    return DateFormat.yMMMM(locale).format(local);
  }
}
