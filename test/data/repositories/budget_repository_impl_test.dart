import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/account_repository_impl.dart';
import 'package:my_money/data/repositories/budget_repository_impl.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/data/repositories/transaction_repository_impl.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/entities/budget.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/transaction_type.dart';

void main() {
  late AppDatabase db;
  late BudgetRepositoryImpl budgetRepo;
  late CategoryRepositoryImpl categoryRepo;
  late AccountRepositoryImpl accountRepo;
  late TransactionRepositoryImpl txRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    budgetRepo = BudgetRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);
    accountRepo = AccountRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);

    await categoryRepo.seedDefaultCategories();
    final now = DateTime.now().toUtc();
    await accountRepo.createAccount(
      Account(
        id: 'acc-1',
        name: 'Espèces',
        type: AccountType.cash,
        iconCodePoint: AccountType.cash.defaultIconCodePoint,
        colorValue: 0xFF4CAF50,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetRepositoryImpl', () {
    test('upserts, updates existing category/month without conflict, deletes',
        () async {
      final now = DateTime.utc(2026, 11, 10);
      final created = await budgetRepo.upsertBudget(
        Budget(
          id: 'b-1',
          categoryId: 'cat_exp_food',
          amountLimit: 50000,
          year: 2026,
          month: 11,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(created.isSuccess, isTrue);

      // Upsert again with different ID for same category/year/month updates cleanly
      final updated = await budgetRepo.upsertBudget(
        Budget(
          id: 'b-new-id',
          categoryId: 'cat_exp_food',
          amountLimit: 75000,
          year: 2026,
          month: 11,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(updated.isSuccess, isTrue);
      expect(updated.dataOrNull?.id, 'b-1');
      expect(updated.dataOrNull?.amountLimit, 75000);

      final list = await budgetRepo.getBudgetsForMonth(year: 2026, month: 11);
      expect(list.dataOrNull?.length, 1);

      final deleted = await budgetRepo.deleteBudget('b-1');
      expect(deleted.isSuccess, isTrue);

      final afterDelete =
          await budgetRepo.getBudgetsForMonth(year: 2026, month: 11);
      expect(afterDelete.dataOrNull, isEmpty);
    });

    test('computes spent amount strictly for expense transactions in month',
        () async {
      final novDate = DateTime.utc(2026, 11, 15, 12);
      final octDate = DateTime.utc(2026, 10, 15, 12);

      await txRepo.createTransaction(
        Transaction(
          id: 'tx-nov-1',
          type: TransactionType.expense,
          amount: 12000,
          date: novDate,
          accountId: 'acc-1',
          categoryId: 'cat_exp_food',
          createdAt: novDate,
          updatedAt: novDate,
        ),
      );
      await txRepo.createTransaction(
        Transaction(
          id: 'tx-oct',
          type: TransactionType.expense,
          amount: 9000,
          date: octDate,
          accountId: 'acc-1',
          categoryId: 'cat_exp_food',
          createdAt: octDate,
          updatedAt: octDate,
        ),
      );

      final spent = await budgetRepo.getSpentForCategoryMonth(
        categoryId: 'cat_exp_food',
        year: 2026,
        month: 11,
      );
      expect(spent.dataOrNull, 12000);
    });
  });
}
