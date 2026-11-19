import '../../core/errors/result.dart';
import '../entities/savings_goal.dart';

abstract interface class SavingsGoalRepository {
  Stream<List<SavingsGoal>> watchGoals();

  Future<Result<List<SavingsGoal>>> getGoals();

  Future<Result<SavingsGoal>> getGoalById(String id);

  Future<Result<SavingsGoal>> createGoal(SavingsGoal goal);

  Future<Result<SavingsGoal>> updateGoal(SavingsGoal goal);

  Future<Result<SavingsGoal>> contributeToGoal({
    required String goalId,
    required int amount,
  });

  Future<Result<void>> deleteGoal(String id);
}
