import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';
import 'recurring_transactions_table.dart';

@DataClassName('TransactionEntry')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()();
  IntColumn get amount => integer()();
  IntColumn get date => integer()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  @ReferenceName('incomingTransactions')
  TextColumn get toAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get recurringTransactionId =>
      text().nullable().references(RecurringTransactions, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
