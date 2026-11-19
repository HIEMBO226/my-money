import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/budget.dart';
import 'package:my_money/domain/entities/category.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/repositories/budget_repository.dart';
import 'package:my_money/domain/repositories/category_repository.dart';
import 'package:my_money/domain/use_cases/budgets/check_budget_alerts.dart';
import 'package:my_money/domain/use_cases/budgets/get_budgets.dart';
import 'package:my_money/domain/use_cases/budgets/set_budget.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _FakeBudget extends Fake implements Budget {}

void main() {
  late _MockBudgetRepository budgetRepo;
  late _MockCategoryRepository categoryRepo;

  setUpAll(() {
    registerFallbackValue(_FakeBudget());
  });

  setUp(() {
    budgetRepo = _MockBudgetRepository();
    categoryRepo = _MockCategoryRepository();
  });

  group('SetBudget', () {
    test('rejects invalid limit or invalid month', () async {
      final useCase = SetBudget(budgetRepo);

      final zeroLimit = await useCase(
        categoryId: 'cat-1',
        amountLimit: 0,
        year: 2026,
        month: 11,
      );
      expect(zeroLimit.isFailure, isTrue);
      expect(zeroLimit.exceptionOrNull, isA<ValidationException>());

      final invalidMonth = await useCase(
        categoryId: 'cat-1',
        amountLimit: 50000,
        year: 2026,
        month: 13,
      );
      expect(invalidMonth.isFailure, isTrue);
      expect(invalidMonth.exceptionOrNull, isA<ValidationException>());
    });

    test('upserts valid budget', () async {
      when(() => budgetRepo.upsertBudget(any())).thenAnswer(
        (inv) async => Success(inv.positionalArguments.first as Budget),
      );

      final useCase = SetBudget(budgetRepo);
      final result = await useCase(
        categoryId: 'cat-food',
        amountLimit: 80000,
        year: 2026,
        month: 11,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.amountLimit, 80000);
    });
  });

  group('GetBudgets.computeStatuses', () {
    test('computes spent, alert levels and sorts by highest ratio', () {
      final now = DateTime.utc(2026, 11, 18);
      final useCase = GetBudgets(budgetRepo);
      final categories = [
        Category(
          id: 'cat-food',
          type: TransactionType.expense,
          name: 'Alimentation',
          iconCodePoint: 0xe532,
          colorValue: 0xFFFF9800,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: 'cat-transport',
          type: TransactionType.expense,
          name: 'Transport',
          iconCodePoint: 0xe1d7,
          colorValue: 0xFF2196F3,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final budgets = [
        Budget(
          id: 'b-food',
          categoryId: 'cat-food',
          amountLimit: 100000,
          year: 2026,
          month: 11,
          createdAt: now,
          updatedAt: now,
        ),
        Budget(
          id: 'b-transport',
          categoryId: 'cat-transport',
          amountLimit: 20000,
          year: 2026,
          month: 11,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final transactions = [
        Transaction(
          id: 'tx-1',
          type: TransactionType.expense,
          amount: 80000,
          date: now,
          accountId: 'acc-1',
          categoryId: 'cat-food',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 'tx-2',
          type: TransactionType.expense,
          amount: 25000,
          date: now,
          accountId: 'acc-1',
          categoryId: 'cat-transport',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final statuses = useCase.computeStatuses(
        budgets: budgets,
        monthTransactions: transactions,
        categories: categories,
      );

      expect(statuses.length, 2);
      // Transport (125%) sorted first, Food (80%) second
      expect(statuses[0].budget.categoryId, 'cat-transport');
      expect(statuses[0].alertLevel, BudgetAlertLevel.exceeded);
      expect(statuses[0].remainingAmount, -5000);

      expect(statuses[1].budget.categoryId, 'cat-food');
      expect(statuses[1].alertLevel, BudgetAlertLevel.warning);
      expect(statuses[1].percentage, 80);
    });
  });

  group('CheckBudgetAlerts', () {
    final now = DateTime.utc(2026, 11, 18);
    final budget = Budget(
      id: 'b-1',
      categoryId: 'cat-food',
      amountLimit: 100000,
      year: 2026,
      month: 11,
      createdAt: now,
      updatedAt: now,
    );
    final category = Category(
      id: 'cat-food',
      type: TransactionType.expense,
      name: 'Alimentation',
      iconCodePoint: 0xe532,
      colorValue: 0xFFFF9800,
      createdAt: now,
      updatedAt: now,
    );

    test('returns null below 80%', () async {
      when(
        () => budgetRepo.getBudgetForCategoryMonth(
          categoryId: 'cat-food',
          year: 2026,
          month: 11,
        ),
      ).thenAnswer((_) async => Success(budget));
      when(
        () => budgetRepo.getSpentForCategoryMonth(
          categoryId: 'cat-food',
          year: 2026,
          month: 11,
        ),
      ).thenAnswer((_) async => const Success(50000));

      final useCase = CheckBudgetAlerts(budgetRepo, categoryRepo);
      final result = await useCase(
        categoryId: 'cat-food',
        year: 2026,
        month: 11,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('returns warning event at 80% and exceeded event at 100%+', () async {
      when(
        () => budgetRepo.getBudgetForCategoryMonth(
          categoryId: 'cat-food',
          year: 2026,
          month: 11,
        ),
      ).thenAnswer((_) async => Success(budget));
      when(() => categoryRepo.getCategoryById('cat-food'))
          .thenAnswer((_) async => Success(category));

      // 85% -> warning
      when(
        () => budgetRepo.getSpentForCategoryMonth(
          categoryId: 'cat-food',
          year: 2026,
          month: 11,
        ),
      ).thenAnswer((_) async => const Success(85000));

      final useCase = CheckBudgetAlerts(budgetRepo, categoryRepo);
      final warningRes = await useCase(
        categoryId: 'cat-food',
        year: 2026,
        month: 11,
      );
      expect(warningRes.dataOrNull?.alertLevel, BudgetAlertLevel.warning);
      expect(warningRes.dataOrNull?.percentage, 85);

      // 110% -> exceeded
      when(
        () => budgetRepo.getSpentForCategoryMonth(
          categoryId: 'cat-food',
          year: 2026,
          month: 11,
        ),
      ).thenAnswer((_) async => const Success(110000));

      final exceededRes = await useCase(
        categoryId: 'cat-food',
        year: 2026,
        month: 11,
      );
      expect(exceededRes.dataOrNull?.alertLevel, BudgetAlertLevel.exceeded);
      expect(exceededRes.dataOrNull?.percentage, 110);
    });
  });
}
