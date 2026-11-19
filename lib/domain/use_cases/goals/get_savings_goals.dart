import '../../../core/errors/result.dart';
import '../../entities/savings_goal.dart';
import '../../repositories/savings_goal_repository.dart';

class GetSavingsGoals {
  const GetSavingsGoals(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<List<SavingsGoal>>> call() => _repository.getGoals();

  Stream<List<SavingsGoal>> watch() => _repository.watchGoals();
}
