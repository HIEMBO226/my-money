import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/savings_goal_repository_impl.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../domain/repositories/savings_goal_repository.dart';
import '../../../domain/use_cases/goals/contribute_to_goal.dart';
import '../../../domain/use_cases/goals/create_savings_goal.dart';
import '../../../domain/use_cases/goals/delete_savings_goal.dart';
import '../../../domain/use_cases/goals/get_savings_goals.dart';
import '../../../domain/use_cases/goals/update_savings_goal.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SavingsGoalRepositoryImpl(db);
});

final getSavingsGoalsUseCaseProvider = Provider<GetSavingsGoals>((ref) {
  return GetSavingsGoals(ref.watch(savingsGoalRepositoryProvider));
});

final createSavingsGoalUseCaseProvider = Provider<CreateSavingsGoal>((ref) {
  return CreateSavingsGoal(ref.watch(savingsGoalRepositoryProvider));
});

final updateSavingsGoalUseCaseProvider = Provider<UpdateSavingsGoal>((ref) {
  return UpdateSavingsGoal(ref.watch(savingsGoalRepositoryProvider));
});

final deleteSavingsGoalUseCaseProvider = Provider<DeleteSavingsGoal>((ref) {
  return DeleteSavingsGoal(ref.watch(savingsGoalRepositoryProvider));
});

final contributeToGoalUseCaseProvider = Provider<ContributeToGoal>((ref) {
  return ContributeToGoal(ref.watch(savingsGoalRepositoryProvider));
});

final savingsGoalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(getSavingsGoalsUseCaseProvider).watch();
});

final goalControllerProvider = Provider<GoalController>((ref) {
  return GoalController(
    ref.watch(createSavingsGoalUseCaseProvider),
    ref.watch(updateSavingsGoalUseCaseProvider),
    ref.watch(deleteSavingsGoalUseCaseProvider),
    ref.watch(contributeToGoalUseCaseProvider),
  );
});

class GoalController {
  const GoalController(
    this._create,
    this._update,
    this._delete,
    this._contribute,
  );

  final CreateSavingsGoal _create;
  final UpdateSavingsGoal _update;
  final DeleteSavingsGoal _delete;
  final ContributeToGoal _contribute;

  Future<Result<SavingsGoal>> create({
    required String name,
    required int targetAmount,
    required int iconCodePoint,
    required int colorValue,
    int currentAmount = 0,
    DateTime? deadline,
    String? accountId,
  }) {
    return _create(
      name: name,
      targetAmount: targetAmount,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      currentAmount: currentAmount,
      deadline: deadline,
      accountId: accountId,
    );
  }

  Future<Result<SavingsGoal>> update(SavingsGoal goal) => _update(goal);

  Future<Result<SavingsGoal>> contribute({
    required String goalId,
    required int amount,
  }) {
    return _contribute(goalId: goalId, amount: amount);
  }

  Future<Result<void>> delete(String id) => _delete(id);
}
