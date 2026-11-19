import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../database/app_database.dart';
import '../database/daos/savings_goals_dao.dart';

class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  const SavingsGoalRepositoryImpl(this._db);

  final AppDatabase _db;

  SavingsGoalsDao get _dao => _db.savingsGoalsDao;

  SavingsGoal _toEntity(SavingsGoalEntry entry) {
    return SavingsGoal(
      id: entry.id,
      name: entry.name,
      targetAmount: entry.targetAmount,
      currentAmount: entry.currentAmount,
      deadline: entry.deadline == null ? null : fromUtcMillis(entry.deadline!),
      accountId: entry.accountId,
      colorValue: entry.colorValue,
      iconCodePoint: entry.iconCodePoint,
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  @override
  Stream<List<SavingsGoal>> watchGoals() {
    return _dao.watchAll().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<SavingsGoal>>> getGoals() async {
    try {
      final rows = await _dao.getAll();
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch savings goals: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> getGoalById(String id) async {
    try {
      final entry = await _dao.getById(id);
      if (entry == null) {
        return Failure(NotFoundException('Savings goal not found: $id'));
      }
      return Success(_toEntity(entry));
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch savings goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> createGoal(SavingsGoal goal) async {
    try {
      await _dao.insertGoal(
        SavingsGoalsCompanion.insert(
          id: goal.id,
          name: goal.name,
          targetAmount: goal.targetAmount,
          currentAmount: Value(goal.currentAmount),
          deadline: Value(goal.deadline?.toUtcMillis),
          accountId: Value(goal.accountId),
          colorValue: goal.colorValue,
          iconCodePoint: goal.iconCodePoint,
          createdAt: goal.createdAt.toUtcMillis,
          updatedAt: goal.updatedAt.toUtcMillis,
        ),
      );
      return Success(goal);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to create savings goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> updateGoal(SavingsGoal goal) async {
    try {
      final updated = await _dao.updateGoalEntry(
        SavingsGoalsCompanion(
          id: Value(goal.id),
          name: Value(goal.name),
          targetAmount: Value(goal.targetAmount),
          currentAmount: Value(goal.currentAmount),
          deadline: Value(goal.deadline?.toUtcMillis),
          accountId: Value(goal.accountId),
          colorValue: Value(goal.colorValue),
          iconCodePoint: Value(goal.iconCodePoint),
          updatedAt: Value(goal.updatedAt.toUtcMillis),
        ),
      );
      if (!updated) {
        return Failure(
          NotFoundException('Savings goal not found: ${goal.id}'),
        );
      }
      return Success(goal);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to update savings goal: $e'));
    }
  }

  @override
  Future<Result<SavingsGoal>> contributeToGoal({
    required String goalId,
    required int amount,
  }) async {
    try {
      SavingsGoal? updatedGoal;
      await _db.transaction(() async {
        final existing = await _dao.getById(goalId);
        if (existing == null) return;

        final nowMillis = DateTime.now().toUtcMillis;
        final nextAmount = existing.currentAmount + amount;

        await _dao.updateGoalEntry(
          SavingsGoalsCompanion(
            id: Value(goalId),
            currentAmount: Value(nextAmount),
            updatedAt: Value(nowMillis),
          ),
        );
        updatedGoal = _toEntity(
          existing.copyWith(
            currentAmount: nextAmount,
            updatedAt: nowMillis,
          ),
        );
      });

      if (updatedGoal == null) {
        return Failure(NotFoundException('Savings goal not found: $goalId'));
      }
      return Success(updatedGoal!);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to contribute to savings goal: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      final deleted = await _dao.deleteById(id);
      if (deleted == 0) {
        return Failure(NotFoundException('Savings goal not found: $id'));
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to delete savings goal: $e'));
    }
  }
}
