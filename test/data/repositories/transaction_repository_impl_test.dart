import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/account_repository_impl.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/data/repositories/transaction_repository_impl.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/entities/attachment.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/entities/transaction_filter.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/transaction_type.dart';

void main() {
  late AppDatabase db;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl txRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);

    await categoryRepo.seedDefaultCategories();
    final now = DateTime.now().toUtc();
    await accountRepo.createAccount(
      Account(
        id: 'acc-cash',
        name: 'Espèces',
        type: AccountType.cash,
        iconCodePoint: AccountType.cash.defaultIconCodePoint,
        colorValue: 0xFF4CAF50,
        createdAt: now,
        updatedAt: now,
      ),
    );
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
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepositoryImpl', () {
    test('creates, updates, attaches files and deletes a transaction',
        () async {
      final now = DateTime.utc(2026, 11, 18, 10);
      final tx = Transaction(
        id: 'tx-1',
        type: TransactionType.expense,
        amount: 4500,
        date: now,
        accountId: 'acc-cash',
        categoryId: 'cat_exp_food',
        note: 'Déjeuner',
        attachments: [
          Attachment(
            id: 'att-1',
            transactionId: 'tx-1',
            filePath: '/tmp/receipt.jpg',
            fileName: 'receipt.jpg',
            mimeType: 'image/jpg',
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final created = await txRepo.createTransaction(tx);
      expect(created.isSuccess, isTrue);
      expect(created.dataOrNull?.attachments.length, 1);

      // Account balance reflects expense
      final cashAfterCreate = await accountRepo.getAccountById('acc-cash');
      expect(cashAfterCreate.dataOrNull?.balance, -4500);

      // Update amount and remove attachment
      final updated = await txRepo.updateTransaction(
        created.dataOrNull!.copyWith(
          amount: 5000,
          note: 'Déjeuner équipe',
          attachments: const [],
        ),
      );
      expect(updated.isSuccess, isTrue);
      expect(updated.dataOrNull?.amount, 5000);
      expect(updated.dataOrNull?.attachments, isEmpty);

      final cashAfterUpdate = await accountRepo.getAccountById('acc-cash');
      expect(cashAfterUpdate.dataOrNull?.balance, -5000);

      // Delete restores balance
      final deleted = await txRepo.deleteTransaction('tx-1');
      expect(deleted.isSuccess, isTrue);

      final cashAfterDelete = await accountRepo.getAccountById('acc-cash');
      expect(cashAfterDelete.dataOrNull?.balance, 0);
    });

    test('filters by type, account, category, period, amount and search query',
        () async {
      final d1 = DateTime.utc(2026, 10, 5, 12);
      final d2 = DateTime.utc(2026, 11, 10, 12);
      final d3 = DateTime.utc(2026, 11, 18, 12);

      await txRepo.createTransaction(
        Transaction(
          id: 'tx-income',
          type: TransactionType.income,
          amount: 250000,
          date: d1,
          accountId: 'acc-bank',
          categoryId: 'cat_inc_salary',
          note: 'Salaire octobre',
          createdAt: d1,
          updatedAt: d1,
        ),
      );
      await txRepo.createTransaction(
        Transaction(
          id: 'tx-food',
          type: TransactionType.expense,
          amount: 3000,
          date: d2,
          accountId: 'acc-cash',
          categoryId: 'cat_exp_food',
          note: 'Restaurant midi',
          createdAt: d2,
          updatedAt: d2,
        ),
      );
      await txRepo.createTransaction(
        Transaction(
          id: 'tx-transfer',
          type: TransactionType.transfer,
          amount: 50000,
          date: d3,
          accountId: 'acc-bank',
          toAccountId: 'acc-cash',
          note: 'Retrait distributeur',
          createdAt: d3,
          updatedAt: d3,
        ),
      );

      // Filter by type
      final onlyExpenses = await txRepo.getTransactions(
        filter: const TransactionFilter(type: TransactionType.expense),
      );
      expect(onlyExpenses.dataOrNull?.map((t) => t.id), ['tx-food']);

      // Filter by account includes transfers where account is toAccountId
      final cashTxs = await txRepo.getTransactions(
        filter: const TransactionFilter(accountId: 'acc-cash'),
      );
      expect(
        cashTxs.dataOrNull?.map((t) => t.id).toList(),
        ['tx-transfer', 'tx-food'],
      );

      // Filter by period
      final november = await txRepo.getTransactions(
        filter: TransactionFilter(
          startDate: DateTime.utc(2026, 11, 1),
          endDate: DateTime.utc(2026, 11, 30, 23, 59, 59),
        ),
      );
      expect(november.dataOrNull?.length, 2);

      // Filter by amount range
      final midRange = await txRepo.getTransactions(
        filter: const TransactionFilter(minAmount: 10000, maxAmount: 100000),
      );
      expect(midRange.dataOrNull?.map((t) => t.id), ['tx-transfer']);

      // Search by category name
      final searchCat = await txRepo.getTransactions(
        filter: const TransactionFilter(searchQuery: 'Alimentation'),
      );
      expect(searchCat.dataOrNull?.map((t) => t.id), ['tx-food']);

      // Search by note
      final searchNote = await txRepo.getTransactions(
        filter: const TransactionFilter(searchQuery: 'distributeur'),
      );
      expect(searchNote.dataOrNull?.map((t) => t.id), ['tx-transfer']);

      // Pagination
      final page1 = await txRepo.getTransactions(
        filter: const TransactionFilter(limit: 2, offset: 0),
      );
      final page2 = await txRepo.getTransactions(
        filter: const TransactionFilter(limit: 2, offset: 2),
      );
      expect(page1.dataOrNull?.length, 2);
      expect(page2.dataOrNull?.length, 1);
    });
  });
}
