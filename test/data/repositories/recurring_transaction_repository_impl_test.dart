import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/account_repository_impl.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/data/repositories/recurring_transaction_repository_impl.dart';
import 'package:my_money/data/repositories/transaction_repository_impl.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/entities/recurring_transaction.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/recurrence_frequency.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/use_cases/recurring/process_due_recurring.dart';

void main() {
  late AppDatabase db;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl txRepo;
  late RecurringTransactionRepositoryImpl recurringRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);
    recurringRepo = RecurringTransactionRepositoryImpl(db);

    await categoryRepo.seedDefaultCategories();
    final now = DateTime.now().toUtc();
    await accountRepo.createAccount(
      Account(
        id: 'acc-1',
        name: 'Banque',
        type: AccountType.bank,
        iconCodePoint: AccountType.bank.defaultIconCodePoint,
        colorValue: 0xFF2196F3,
        createdAt: now,
        updatedAt: now,
      ),
      initialBalance: 500000,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('RecurringTransactionRepositoryImpl', () {
    test('processes due recurring end-to-end and keeps history on delete',
        () async {
      final now = DateTime.utc(2026, 11, 18, 12);
      final rec = RecurringTransaction(
        id: 'rec-rent',
        type: TransactionType.expense,
        amount: 150000,
        accountId: 'acc-1',
        categoryId: 'cat_exp_housing',
        note: 'Loyer mensuel',
        frequency: RecurrenceFrequency.monthly,
        nextDueDate: DateTime.utc(2026, 10, 1, 9),
        createdAt: now,
        updatedAt: now,
      );

      final created = await recurringRepo.createRecurringTransaction(rec);
      expect(created.isSuccess, isTrue);

      final process = ProcessDueRecurring(recurringRepo, txRepo);
      final genResult = await process(nowUtc: now);
      // Oct 1 + Nov 1 = 2 occurrences
      expect(genResult.dataOrNull, 2);

      // Re-running immediately is idempotent -> 0 new transactions
      final secondRun = await process(nowUtc: now);
      expect(secondRun.dataOrNull, 0);

      // Account balance reflects 500 000 - 300 000 = 200 000
      final acc = await accountRepo.getAccountById('acc-1');
      expect(acc.dataOrNull?.balance, 200000);

      // Deleting template succeeds and keeps generated transactions intact
      final deleted = await recurringRepo.deleteRecurringTransaction('rec-rent');
      expect(deleted.isSuccess, isTrue);

      final txs = await txRepo.getTransactions();
      // 1 initial balance + 2 rent transactions = 3
      expect(txs.dataOrNull?.length, 3);
    });
  });
}
