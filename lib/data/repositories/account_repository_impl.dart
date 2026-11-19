import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/account.dart';
import '../../domain/enums/account_type.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/app_database.dart';
import '../database/daos/accounts_dao.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._db);

  final AppDatabase _db;

  AccountsDao get _dao => _db.accountsDao;

  Account _toEntity(AccountWithBalanceRow row) {
    final entry = row.entry;
    return Account(
      id: entry.id,
      name: entry.name,
      type: AccountType.values[entry.type],
      iconCodePoint: entry.iconCodePoint,
      colorValue: entry.colorValue,
      sortOrder: entry.sortOrder,
      balance: row.balance,
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  @override
  Stream<List<Account>> watchAccounts() {
    return _dao
        .watchAccountsWithBalance()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Account>>> getAccounts() async {
    try {
      final rows = await _dao.getAccountsWithBalance();
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch accounts: $e'));
    }
  }

  @override
  Future<Result<Account>> getAccountById(String id) async {
    try {
      final row = await _dao.getAccountWithBalanceById(id);
      if (row == null) {
        return Failure(NotFoundException('Account not found: $id'));
      }
      return Success(_toEntity(row));
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch account: $e'));
    }
  }

  @override
  Future<Result<Account>> createAccount(
    Account account, {
    int initialBalance = 0,
    String? initialBalanceNote,
  }) async {
    try {
      await _db.transaction(() async {
        final createdMillis = account.createdAt.toUtcMillis;
        await _dao.insertAccount(
          AccountsCompanion.insert(
            id: account.id,
            name: account.name,
            type: account.type.index,
            iconCodePoint: account.iconCodePoint,
            colorValue: account.colorValue,
            sortOrder: Value(account.sortOrder),
            createdAt: createdMillis,
            updatedAt: account.updatedAt.toUtcMillis,
          ),
        );

        if (initialBalance > 0) {
          await _dao.insertTransactionEntry(
            TransactionsCompanion.insert(
              id: IdGenerator.generate(),
              type: TransactionType.income.index,
              amount: initialBalance,
              date: createdMillis,
              accountId: account.id,
              note: Value(initialBalanceNote),
              createdAt: createdMillis,
              updatedAt: createdMillis,
            ),
          );
        }
      });

      return await getAccountById(account.id);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to create account: $e'));
    }
  }

  @override
  Future<Result<Account>> updateAccount(Account account) async {
    try {
      final updated = await _dao.updateAccountEntry(
        AccountsCompanion(
          id: Value(account.id),
          name: Value(account.name),
          type: Value(account.type.index),
          iconCodePoint: Value(account.iconCodePoint),
          colorValue: Value(account.colorValue),
          sortOrder: Value(account.sortOrder),
          updatedAt: Value(account.updatedAt.toUtcMillis),
        ),
      );
      if (!updated) {
        return Failure(NotFoundException('Account not found: ${account.id}'));
      }
      return await getAccountById(account.id);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to update account: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String id) async {
    try {
      final txCount = await _dao.countTransactionsForAccount(id);
      if (txCount > 0) {
        return const Failure(
          ValidationException(
            'Cannot delete an account that has linked transactions.',
          ),
        );
      }
      final deleted = await _dao.deleteAccountById(id);
      if (deleted == 0) {
        return Failure(NotFoundException('Account not found: $id'));
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to delete account: $e'));
    }
  }

  @override
  Future<Result<void>> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      final source = await _dao.getAccountWithBalanceById(fromAccountId);
      final target = await _dao.getAccountWithBalanceById(toAccountId);
      if (source == null || target == null) {
        return const Failure(
          NotFoundException('Source or destination account not found.'),
        );
      }

      final nowMillis = DateTime.now().toUtcMillis;
      await _dao.insertTransactionEntry(
        TransactionsCompanion.insert(
          id: IdGenerator.generate(),
          type: TransactionType.transfer.index,
          amount: amount,
          date: date.toUtcMillis,
          accountId: fromAccountId,
          toAccountId: Value(toAccountId),
          note: Value(note),
          createdAt: nowMillis,
          updatedAt: nowMillis,
        ),
      );
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to transfer between accounts: $e'));
    }
  }
}
