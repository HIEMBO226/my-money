import '../../core/errors/result.dart';
import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchBudgetsForMonth({
    required int year,
    required int month,
  });

  Future<Result<List<Budget>>> getBudgetsForMonth({
    required int year,
    required int month,
  });

  Future<Result<Budget?>> getBudgetForCategoryMonth({
    required String categoryId,
    required int year,
    required int month,
  });

  Future<Result<int>> getSpentForCategoryMonth({
    required String categoryId,
    required int year,
    required int month,
  });

  Future<Result<Budget>> upsertBudget(Budget budget);

  Future<Result<void>> deleteBudget(String id);
}
