import '../../../core/errors/result.dart';
import '../../entities/budget.dart';
import '../../entities/category.dart';
import '../../entities/transaction.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/budget_repository.dart';

class GetBudgets {
  const GetBudgets(this._repository);

  final BudgetRepository _repository;

  Future<Result<List<Budget>>> call({
    required int year,
    required int month,
  }) =>
      _repository.getBudgetsForMonth(year: year, month: month);

  Stream<List<Budget>> watch({
    required int year,
    required int month,
  }) =>
      _repository.watchBudgetsForMonth(year: year, month: month);

  List<BudgetStatus> computeStatuses({
    required List<Budget> budgets,
    required List<Transaction> monthTransactions,
    required List<Category> categories,
  }) {
    final categoryMap = {for (final c in categories) c.id: c};
    final spentByCategory = <String, int>{};

    for (final tx in monthTransactions) {
      if (tx.type != TransactionType.expense || tx.categoryId == null) continue;
      spentByCategory[tx.categoryId!] =
          (spentByCategory[tx.categoryId!] ?? 0) + tx.amount;
    }

    final statuses = budgets
        .map(
          (budget) => BudgetStatus(
            budget: budget,
            category: categoryMap[budget.categoryId],
            spentAmount: spentByCategory[budget.categoryId] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    return statuses;
  }
}
