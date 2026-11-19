enum TransactionType {
  expense,
  income,
  transfer;

  String get labelKey {
    return switch (this) {
      TransactionType.expense => 'transactionTypeExpense',
      TransactionType.income => 'transactionTypeIncome',
      TransactionType.transfer => 'transactionTypeTransfer',
    };
  }
}
