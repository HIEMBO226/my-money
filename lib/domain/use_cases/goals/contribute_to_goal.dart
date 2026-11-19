import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/savings_goal.dart';
import '../../repositories/savings_goal_repository.dart';

class ContributeToGoal {
  const ContributeToGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call({
    required String goalId,
    required int amount,
  }) async {
    if (amount <= 0) {
      return const Failure(
        ValidationException('Contribution amount must be strictly positive.'),
      );
    }
    return _repository.contributeToGoal(goalId: goalId, amount: amount);
  }
}
