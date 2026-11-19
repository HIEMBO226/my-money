import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/savings_goals_table.dart';

part 'savings_goals_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalsDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalsDaoMixin {
  SavingsGoalsDao(super.db);

  Stream<List<SavingsGoalEntry>> watchAll() {
    return (select(savingsGoals)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .watch();
  }

  Future<List<SavingsGoalEntry>> getAll() {
    return (select(savingsGoals)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
  }

  Future<SavingsGoalEntry?> getById(String id) {
    return (select(savingsGoals)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertGoal(SavingsGoalsCompanion entry) async {
    await into(savingsGoals).insert(entry);
  }

  Future<bool> updateGoalEntry(SavingsGoalsCompanion entry) async {
    final affected = await (update(savingsGoals)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    return affected > 0;
  }

  Future<int> deleteById(String id) {
    return (delete(savingsGoals)..where((t) => t.id.equals(id))).go();
  }
}
