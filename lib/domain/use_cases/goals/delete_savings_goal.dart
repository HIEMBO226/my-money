import '../../../core/errors/result.dart';
import '../../repositories/savings_goal_repository.dart';

class DeleteSavingsGoal {
  const DeleteSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteGoal(id);
}
