import '../../../core/errors/result.dart';
import '../../entities/budget.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/category_repository.dart';

class CheckBudgetAlerts {
  const CheckBudgetAlerts(this._budgetRepository, this._categoryRepository);

  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  /// Evaluates whether the monthly budget for [categoryId] in [year]/[month]
  /// has reached the 80% warning or 100% critical threshold.
  Future<Result<BudgetAlertEvent?>> call({
    required String categoryId,
    required int year,
    required int month,
  }) async {
    final budgetResult = await _budgetRepository.getBudgetForCategoryMonth(
      categoryId: categoryId,
      year: year,
      month: month,
    );

    final budget = budgetResult.dataOrNull;
    if (budgetResult.isFailure) {
      return Failure(budgetResult.exceptionOrNull!);
    }
    if (budget == null) {
      return const Success(null);
    }

    final spentResult = await _budgetRepository.getSpentForCategoryMonth(
      categoryId: categoryId,
      year: year,
      month: month,
    );
    if (spentResult.isFailure) {
      return Failure(spentResult.exceptionOrNull!);
    }

    final spent = spentResult.dataOrNull ?? 0;
    final status = BudgetStatus(budget: budget, spentAmount: spent);
    if (status.alertLevel == BudgetAlertLevel.normal) {
      return const Success(null);
    }

    final categoryResult =
        await _categoryRepository.getCategoryById(categoryId);
    final categoryName = categoryResult.dataOrNull?.name ?? '';

    return Success(
      BudgetAlertEvent(
        budgetId: budget.id,
        categoryId: categoryId,
        categoryName: categoryName,
        alertLevel: status.alertLevel,
        spentAmount: spent,
        amountLimit: budget.amountLimit,
        percentage: status.percentage,
      ),
    );
  }
}
