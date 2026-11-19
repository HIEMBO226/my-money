import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

@DataClassName('RecurringTransactionEntry')
class RecurringTransactions extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()();
  IntColumn get amount => integer()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  @ReferenceName('incomingRecurringTransactions')
  TextColumn get toAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get note => text().nullable()();
  IntColumn get frequency => integer()();
  IntColumn get nextDueDate => integer()();
  IntColumn get endDate => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
