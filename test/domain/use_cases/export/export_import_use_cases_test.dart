import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/account_repository_impl.dart';
import 'package:my_money/data/repositories/budget_repository_impl.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/data/repositories/recurring_transaction_repository_impl.dart';
import 'package:my_money/data/repositories/savings_goal_repository_impl.dart';
import 'package:my_money/data/repositories/transaction_repository_impl.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/entities/app_settings.dart';
import 'package:my_money/domain/entities/budget.dart';
import 'package:my_money/domain/entities/recurring_transaction.dart';
import 'package:my_money/domain/entities/savings_goal.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/recurrence_frequency.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/use_cases/export/backup_to_json.dart';
import 'package:my_money/domain/use_cases/export/export_csv.dart';
import 'package:my_money/domain/use_cases/export/export_pdf.dart';
import 'package:my_money/domain/use_cases/export/restore_from_json.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl txRepo;
  late BudgetRepositoryImpl budgetRepo;
  late SavingsGoalRepositoryImpl goalRepo;
  late RecurringTransactionRepositoryImpl recurringRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);
    budgetRepo = BudgetRepositoryImpl(db);
    goalRepo = SavingsGoalRepositoryImpl(db);
    recurringRepo = RecurringTransactionRepositoryImpl(db);

    await categoryRepo.seedDefaultCategories();
    final now = DateTime.utc(2026, 11, 18, 12);

    await accountRepo.createAccount(
      Account(
        id: 'acc-bank',
        name: 'Banque',
        type: AccountType.bank,
        iconCodePoint: AccountType.bank.defaultIconCodePoint,
        colorValue: 0xFF2196F3,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await txRepo.createTransaction(
      Transaction(
        id: 'tx-1',
        type: TransactionType.income,
        amount: 250000,
        date: now,
        accountId: 'acc-bank',
        categoryId: 'cat_inc_salary',
        note: 'Salaire novembre',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await txRepo.createTransaction(
      Transaction(
        id: 'tx-2',
        type: TransactionType.expense,
        amount: 15000,
        date: now,
        accountId: 'acc-bank',
        categoryId: 'cat_exp_food',
        note: 'Courses marché',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await budgetRepo.upsertBudget(
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
    await goalRepo.createGoal(
      SavingsGoal(
        id: 'g-1',
        name: 'Fonds urgence',
        targetAmount: 500000,
        currentAmount: 100000,
        accountId: 'acc-bank',
        colorValue: 0xFF4CAF50,
        iconCodePoint: 0xe58d,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await recurringRepo.createRecurringTransaction(
      RecurringTransaction(
        id: 'r-1',
        type: TransactionType.expense,
        amount: 100000,
        accountId: 'acc-bank',
        categoryId: 'cat_exp_housing',
        note: 'Loyer',
        frequency: RecurrenceFrequency.monthly,
        nextDueDate: DateTime.utc(2026, 12, 1, 9),
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ExportCsv', () {
    test('exports UTF-8 BOM CSV with headers and signed transactions',
        () async {
      final exportCsv = ExportCsv(txRepo, accountRepo, categoryRepo);
      final result = await exportCsv(settings: const AppSettings());

      expect(result.isSuccess, isTrue);
      final bytes = result.dataOrNull!;
      // UTF-8 BOM prefix (EF BB BF) for Excel French accent compatibility
      expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      final content = utf8.decode(bytes);
      expect(content, contains('Amount (XOF)'));
      expect(content, contains('Salaire novembre'));
      expect(content, contains('-15000'));
      expect(content, contains('250000'));
    });
  });

  group('ExportPdf', () {
    test('generates valid Unicode PDF binary document for XOF and EUR',
        () async {
      final exportPdf = ExportPdf(txRepo, accountRepo, categoryRepo);

      final xofResult = await exportPdf(settings: const AppSettings());
      expect(xofResult.isSuccess, isTrue);
      final xofBytes = xofResult.dataOrNull!;
      expect(xofBytes.length, greaterThan(500));
      expect(ascii.decode(xofBytes.sublist(0, 5)), '%PDF-');

      final eurResult = await exportPdf(
        settings: const AppSettings(currencyCode: 'EUR'),
      );
      expect(eurResult.isSuccess, isTrue);
      expect(ascii.decode(eurResult.dataOrNull!.sublist(0, 5)), '%PDF-');
    });
  });

  group('BackupToJson & RestoreFromJson', () {
    test('backs up and restores all tables atomically into a fresh DB',
        () async {
      const password = 'my-secret-backup-key';
      final backupUseCase = BackupToJson(db);
      final backupRes = await backupUseCase(password: password);
      expect(backupRes.isSuccess, isTrue);

      final encryptedContent = utf8.decode(backupRes.dataOrNull!);

      // Restore into a completely fresh empty in-memory DB
      final freshDb = AppDatabase(NativeDatabase.memory());
      addTearDown(freshDb.close);

      final restoreUseCase = RestoreFromJson(freshDb);

      // Wrong password fails cleanly with SecurityException
      final badAttempt = await restoreUseCase(
        encryptedBackupContent: encryptedContent,
        password: 'wrong-password',
      );
      expect(badAttempt.isFailure, isTrue);
      expect(badAttempt.exceptionOrNull, isA<SecurityException>());

      // Correct password restores all 6 tables
      final restored = await restoreUseCase(
        encryptedBackupContent: encryptedContent,
        password: password,
      );
      expect(restored.isSuccess, isTrue);
      final summary = restored.dataOrNull!;
      expect(summary.accountsCount, 1);
      expect(summary.transactionsCount, 2);
      expect(summary.budgetsCount, 1);
      expect(summary.goalsCount, 1);
      expect(summary.recurringCount, 1);

      // Verify restored account balance matches original (250 000 - 15 000)
      final restoredAcc =
          await AccountRepositoryImpl(freshDb).getAccountById('acc-bank');
      expect(restoredAcc.dataOrNull?.balance, 235000);
    });
  });
}
