import 'package:drift/drift.dart';

import '../../../domain/enums/transaction_type.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/transactions_table.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets, Transactions])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Stream<List<BudgetEntry>> watchBudgetsForMonth({
    required int year,
    required int month,
  }) {
    return (select(budgets)
          ..where((t) => t.year.equals(year) & t.month.equals(month))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<List<BudgetEntry>> getBudgetsForMonth({
    required int year,
    required int month,
  }) {
    return (select(budgets)
          ..where((t) => t.year.equals(year) & t.month.equals(month))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  Future<BudgetEntry?> getBudgetForCategoryMonth({
    required String categoryId,
    required int year,
    required int month,
  }) {
    return (select(budgets)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.year.equals(year) &
                t.month.equals(month),
          ))
        .getSingleOrNull();
  }

  Future<void> upsertBudget(BudgetsCompanion entry) async {
    await into(budgets).insertOnConflictUpdate(entry);
  }

  Future<int> deleteBudgetById(String id) {
    return (delete(budgets)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getSpentForCategoryInRange({
    required String categoryId,
    required int startMillis,
    required int endMillis,
  }) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM transactions '
      'WHERE type = ? AND category_id = ? AND date >= ? AND date <= ?',
      variables: [
        Variable.withInt(TransactionType.expense.index),
        Variable.withString(categoryId),
        Variable.withInt(startMillis),
        Variable.withInt(endMillis),
      ],
      readsFrom: {transactions},
    ).getSingle();
    return row.read<int>('total');
  }
}
