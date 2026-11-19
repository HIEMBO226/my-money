enum AccountType {
  cash,
  bank,
  mobileMoney,
  savings;

  String get labelKey {
    return switch (this) {
      AccountType.cash => 'accountTypeCash',
      AccountType.bank => 'accountTypeBank',
      AccountType.mobileMoney => 'accountTypeMobileMoney',
      AccountType.savings => 'accountTypeSavings',
    };
  }

  int get defaultIconCodePoint {
    return switch (this) {
      AccountType.cash => 0xe227,
      AccountType.bank => 0xe069,
      AccountType.mobileMoney => 0xe4a2,
      AccountType.savings => 0xe58d,
    };
  }
}
