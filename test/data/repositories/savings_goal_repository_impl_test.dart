import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/savings_goal_repository_impl.dart';
import 'package:my_money/domain/entities/savings_goal.dart';

void main() {
  late AppDatabase db;
  late SavingsGoalRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SavingsGoalRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SavingsGoalRepositoryImpl', () {
    test('creates, contributes, updates and deletes savings goal', () async {
      final now = DateTime.utc(2026, 11, 18);
      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'Fonds urgence',
        targetAmount: 100000,
        currentAmount: 20000,
        deadline: DateTime.utc(2027, 6, 1),
        colorValue: 0xFF4CAF50,
        iconCodePoint: 0xe58d,
        createdAt: now,
        updatedAt: now,
      );

      final created = await repo.createGoal(goal);
      expect(created.isSuccess, isTrue);

      final contributed = await repo.contributeToGoal(
        goalId: 'goal-1',
        amount: 35000,
      );
      expect(contributed.isSuccess, isTrue);
      expect(contributed.dataOrNull?.currentAmount, 55000);

      final updated = await repo.updateGoal(
        contributed.dataOrNull!.copyWith(name: 'Épargne sécurité'),
      );
      expect(updated.isSuccess, isTrue);

      final fetched = await repo.getGoalById('goal-1');
      expect(fetched.dataOrNull?.name, 'Épargne sécurité');
      expect(fetched.dataOrNull?.currentAmount, 55000);

      final deleted = await repo.deleteGoal('goal-1');
      expect(deleted.isSuccess, isTrue);

      final all = await repo.getGoals();
      expect(all.dataOrNull, isEmpty);
    });
  });
}
