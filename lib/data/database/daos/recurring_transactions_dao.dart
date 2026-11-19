import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recurring_transactions_table.dart';
import '../tables/transactions_table.dart';

part 'recurring_transactions_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactions, Transactions])
class RecurringTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringTransactionsDaoMixin {
  RecurringTransactionsDao(super.db);

  Stream<List<RecurringTransactionEntry>> watchAll() {
    return (select(recurringTransactions)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.isActive,
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(expression: t.nextDueDate),
          ]))
        .watch();
  }

  Future<List<RecurringTransactionEntry>> getAll() {
    return (select(recurringTransactions)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.isActive,
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(expression: t.nextDueDate),
          ]))
        .get();
  }

  Future<List<RecurringTransactionEntry>> getDue(int asOfMillis) {
    return (select(recurringTransactions)
          ..where(
            (t) =>
                t.isActive.equals(true) &
                t.nextDueDate.isSmallerOrEqualValue(asOfMillis),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]))
        .get();
  }

  Future<void> insertEntry(RecurringTransactionsCompanion entry) async {
    await into(recurringTransactions).insert(entry);
  }

  Future<bool> updateEntry(RecurringTransactionsCompanion entry) async {
    final affected = await (update(recurringTransactions)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    return affected > 0;
  }

  Future<int> deleteById(String id) async {
    // Detach historical generated transactions so deleting a template
    // keeps past transactions intact and satisfies foreign keys.
    await (update(transactions)
          ..where((t) => t.recurringTransactionId.equals(id)))
        .write(
      const TransactionsCompanion(recurringTransactionId: Value(null)),
    );
    return (delete(recurringTransactions)..where((t) => t.id.equals(id))).go();
  }
}
