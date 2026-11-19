import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/savings_goal.dart';
import 'package:my_money/domain/repositories/savings_goal_repository.dart';
import 'package:my_money/domain/use_cases/goals/contribute_to_goal.dart';
import 'package:my_money/domain/use_cases/goals/create_savings_goal.dart';

class _MockGoalRepo extends Mock implements SavingsGoalRepository {}

class _FakeGoal extends Fake implements SavingsGoal {}

void main() {
  late _MockGoalRepo repo;

  setUpAll(() {
    registerFallbackValue(_FakeGoal());
  });

  setUp(() {
    repo = _MockGoalRepo();
  });

  group('SavingsGoal entity', () {
    test('calculates progress, remaining, completion and days remaining', () {
      final now = DateTime.utc(2026, 11, 18, 12);
      final goal = SavingsGoal(
        id: 'g-1',
        name: 'Voyage',
        targetAmount: 200000,
        currentAmount: 50000,
        deadline: DateTime.utc(2026, 11, 28, 12),
        colorValue: 0xFF4CAF50,
        iconCodePoint: 0xe58d,
        createdAt: now,
        updatedAt: now,
      );

      expect(goal.progress, closeTo(0.25, 0.001));
      expect(goal.percentage, 25);
      expect(goal.remainingAmount, 150000);
      expect(goal.isCompleted, isFalse);
      expect(goal.daysRemaining(now), 10);

      final completed = goal.copyWith(currentAmount: 250000);
      expect(completed.isCompleted, isTrue);
      expect(completed.progress, 1.0);
      expect(completed.remainingAmount, 0);
    });
  });

  group('CreateSavingsGoal', () {
    test('rejects blank name or non-positive target', () async {
      final useCase = CreateSavingsGoal(repo);

      final blankName = await useCase(
        name: '  ',
        targetAmount: 100000,
        iconCodePoint: 0xe58d,
        colorValue: 0xFF4CAF50,
      );
      expect(blankName.isFailure, isTrue);
      expect(blankName.exceptionOrNull, isA<ValidationException>());

      final zeroTarget = await useCase(
        name: 'Voiture',
        targetAmount: 0,
        iconCodePoint: 0xe58d,
        colorValue: 0xFF4CAF50,
      );
      expect(zeroTarget.isFailure, isTrue);
      expect(zeroTarget.exceptionOrNull, isA<ValidationException>());
    });
  });

  group('ContributeToGoal', () {
    test('rejects non-positive contribution and delegates positive one',
        () async {
      final useCase = ContributeToGoal(repo);

      final invalid = await useCase(goalId: 'g-1', amount: 0);
      expect(invalid.isFailure, isTrue);
      expect(invalid.exceptionOrNull, isA<ValidationException>());

      final now = DateTime.utc(2026, 11, 18);
      final updated = SavingsGoal(
        id: 'g-1',
        name: 'Fonds urgence',
        targetAmount: 100000,
        currentAmount: 30000,
        colorValue: 0xFF4CAF50,
        iconCodePoint: 0xe58d,
        createdAt: now,
        updatedAt: now,
      );
      when(() => repo.contributeToGoal(goalId: 'g-1', amount: 30000))
          .thenAnswer((_) async => Success(updated));

      final valid = await useCase(goalId: 'g-1', amount: 30000);
      expect(valid.isSuccess, isTrue);
      expect(valid.dataOrNull?.currentAmount, 30000);
    });
  });
}
