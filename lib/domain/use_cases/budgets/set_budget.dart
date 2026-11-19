import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/budget.dart';
import '../../repositories/budget_repository.dart';

class SetBudget {
  const SetBudget(this._repository);

  final BudgetRepository _repository;

  Future<Result<Budget>> call({
    required String categoryId,
    required int amountLimit,
    required int year,
    required int month,
  }) async {
    if (categoryId.trim().isEmpty) {
      return const Failure(
        ValidationException('A category must be selected.'),
      );
    }
    if (amountLimit <= 0) {
      return const Failure(
        ValidationException('Budget limit must be strictly positive.'),
      );
    }
    if (month < 1 || month > 12) {
      return const Failure(
        ValidationException('Month must be between 1 and 12.'),
      );
    }

    final now = DateTime.now().toUtc();
    final budget = Budget(
      id: IdGenerator.generate(),
      categoryId: categoryId,
      amountLimit: amountLimit,
      year: year,
      month: month,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.upsertBudget(budget);
  }
}
