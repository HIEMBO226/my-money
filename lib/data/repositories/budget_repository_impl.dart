import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../database/app_database.dart';
import '../database/daos/budgets_dao.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl(this._db);

  final AppDatabase _db;

  BudgetsDao get _dao => _db.budgetsDao;

  Budget _toEntity(BudgetEntry entry) {
    return Budget(
      id: entry.id,
      categoryId: entry.categoryId,
      amountLimit: entry.amountLimit,
      year: entry.year,
      month: entry.month,
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  @override
  Stream<List<Budget>> watchBudgetsForMonth({
    required int year,
    required int month,
  }) {
    return _dao
        .watchBudgetsForMonth(year: year, month: month)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Budget>>> getBudgetsForMonth({
    required int year,
    required int month,
  }) async {
    try {
      final rows = await _dao.getBudgetsForMonth(year: year, month: month);
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch budgets: $e'));
    }
  }

  @override
  Future<Result<Budget?>> getBudgetForCategoryMonth({
    required String categoryId,
    required int year,
    required int month,
  }) async {
    try {
      final entry = await _dao.getBudgetForCategoryMonth(
        categoryId: categoryId,
        year: year,
        month: month,
      );
      return Success(entry == null ? null : _toEntity(entry));
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch budget: $e'));
    }
  }

  @override
  Future<Result<int>> getSpentForCategoryMonth({
    required String categoryId,
    required int year,
    required int month,
  }) async {
    try {
      final monthDate = DateTime(year, month);
      final total = await _dao.getSpentForCategoryInRange(
        categoryId: categoryId,
        startMillis: monthDate.startOfMonth.toUtcMillis,
        endMillis: monthDate.endOfMonth.toUtcMillis,
      );
      return Success(total);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to calculate category spending: $e'),
      );
    }
  }

  @override
  Future<Result<Budget>> upsertBudget(Budget budget) async {
    try {
      final existing = await _dao.getBudgetForCategoryMonth(
        categoryId: budget.categoryId,
        year: budget.year,
        month: budget.month,
      );

      final effectiveBudget = existing != null
          ? budget.copyWith(
              id: existing.id,
              createdAt: fromUtcMillis(existing.createdAt),
            )
          : budget;

      await _dao.upsertBudget(
        BudgetsCompanion(
          id: Value(effectiveBudget.id),
          categoryId: Value(effectiveBudget.categoryId),
          amountLimit: Value(effectiveBudget.amountLimit),
          year: Value(effectiveBudget.year),
          month: Value(effectiveBudget.month),
          createdAt: Value(effectiveBudget.createdAt.toUtcMillis),
          updatedAt: Value(effectiveBudget.updatedAt.toUtcMillis),
        ),
      );
      return Success(effectiveBudget);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to save budget: $e'));
    }
  }

  @override
  Future<Result<void>> deleteBudget(String id) async {
    try {
      final deleted = await _dao.deleteBudgetById(id);
      if (deleted == 0) {
        return Failure(NotFoundException('Budget not found: $id'));
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to delete budget: $e'));
    }
  }
}
