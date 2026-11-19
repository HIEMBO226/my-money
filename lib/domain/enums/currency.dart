enum Currency {
  xof(code: 'XOF', symbol: 'FCFA', decimalDigits: 0, labelKey: 'currencyXof'),
  eur(code: 'EUR', symbol: '€', decimalDigits: 2, labelKey: 'currencyEur'),
  usd(code: 'USD', symbol: '\$', decimalDigits: 2, labelKey: 'currencyUsd'),
  gbp(code: 'GBP', symbol: '£', decimalDigits: 2, labelKey: 'currencyGbp'),
  cad(code: 'CAD', symbol: 'CA\$', decimalDigits: 2, labelKey: 'currencyCad'),
  chf(code: 'CHF', symbol: 'CHF', decimalDigits: 2, labelKey: 'currencyChf'),
  mad(code: 'MAD', symbol: 'MAD', decimalDigits: 2, labelKey: 'currencyMad'),
  tnd(code: 'TND', symbol: 'TND', decimalDigits: 3, labelKey: 'currencyTnd'),
  xaf(code: 'XAF', symbol: 'FCFA', decimalDigits: 0, labelKey: 'currencyXaf'),
  gnf(code: 'GNF', symbol: 'FG', decimalDigits: 0, labelKey: 'currencyGnf');

  const Currency({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
    required this.labelKey,
  });

  final String code;
  final String symbol;
  final int decimalDigits;
  final String labelKey;

  int get smallestUnitMultiplier {
    int result = 1;
    for (int i = 0; i < decimalDigits; i++) {
      result *= 10;
    }
    return result;
  }

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency.xof,
    );
  }
}
