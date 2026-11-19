import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/savings_goal.dart';
import '../../repositories/savings_goal_repository.dart';

class CreateSavingsGoal {
  const CreateSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  static const int maxGoalNameLength = 100;

  Future<Result<SavingsGoal>> call({
    required String name,
    required int targetAmount,
    required int iconCodePoint,
    required int colorValue,
    int currentAmount = 0,
    DateTime? deadline,
    String? accountId,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > maxGoalNameLength) {
      return const Failure(
        ValidationException(
          'Goal name must be between 1 and 100 characters.',
        ),
      );
    }
    if (targetAmount <= 0) {
      return const Failure(
        ValidationException('Target amount must be strictly positive.'),
      );
    }
    if (currentAmount < 0) {
      return const Failure(
        ValidationException('Initial saved amount cannot be negative.'),
      );
    }

    final now = DateTime.now().toUtc();
    final goal = SavingsGoal(
      id: IdGenerator.generate(),
      name: trimmedName,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline?.toUtc(),
      accountId: accountId,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createGoal(goal);
  }
}
