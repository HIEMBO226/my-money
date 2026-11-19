import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/savings_goal.dart';
import '../../repositories/savings_goal_repository.dart';
import 'create_savings_goal.dart';

class UpdateSavingsGoal {
  const UpdateSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call(SavingsGoal goal) async {
    final trimmedName = goal.name.trim();
    if (trimmedName.isEmpty ||
        trimmedName.length > CreateSavingsGoal.maxGoalNameLength) {
      return const Failure(
        ValidationException(
          'Goal name must be between 1 and 100 characters.',
        ),
      );
    }
    if (goal.targetAmount <= 0) {
      return const Failure(
        ValidationException('Target amount must be strictly positive.'),
      );
    }
    if (goal.currentAmount < 0) {
      return const Failure(
        ValidationException('Saved amount cannot be negative.'),
      );
    }

    return _repository.updateGoal(
      goal.copyWith(
        name: trimmedName,
        deadline: goal.deadline?.toUtc(),
        clearDeadline: goal.deadline == null,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
