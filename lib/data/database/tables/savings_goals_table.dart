import 'package:drift/drift.dart';

import 'accounts_table.dart';

@DataClassName('SavingsGoalEntry')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount => integer().withDefault(const Constant(0))();
  IntColumn get deadline => integer().nullable()();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  IntColumn get colorValue => integer()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
