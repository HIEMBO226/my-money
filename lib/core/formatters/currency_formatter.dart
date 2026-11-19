import 'package:intl/intl.dart';

import '../../domain/enums/currency.dart';

abstract final class CurrencyFormatter {
  static String format(
    int amountInSmallestUnit, {
    required String currencyCode,
  }) {
    final currency = Currency.fromCode(currencyCode);
    final double displayAmount =
        amountInSmallestUnit / currency.smallestUnitMultiplier;

    final formatter = NumberFormat.currency(
      locale: _localeForCurrency(currency),
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );

    return formatter.format(displayAmount);
  }

  static int parseToSmallestUnit(
    String input, {
    required String currencyCode,
  }) {
    final currency = Currency.fromCode(currencyCode);
    final cleaned = input.replaceAll(RegExp(r'[^\d.,\-]'), '');
    final normalized = cleaned.replaceAll(',', '.');

    final parsed = double.tryParse(normalized) ?? 0.0;
    return (parsed * currency.smallestUnitMultiplier).round();
  }

  static String _localeForCurrency(Currency currency) {
    return switch (currency) {
      Currency.eur || Currency.xof || Currency.xaf => 'fr_FR',
      Currency.usd => 'en_US',
      Currency.gbp => 'en_GB',
      Currency.cad => 'en_CA',
      Currency.chf => 'fr_CH',
      Currency.mad || Currency.tnd || Currency.gnf => 'fr_FR',
    };
  }
}
