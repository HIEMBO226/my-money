import '../../core/errors/result.dart';
import '../entities/account.dart';

abstract interface class AccountRepository {
  Stream<List<Account>> watchAccounts();

  Future<Result<List<Account>>> getAccounts();

  Future<Result<Account>> getAccountById(String id);

  Future<Result<Account>> createAccount(
    Account account, {
    int initialBalance = 0,
    String? initialBalanceNote,
  });

  Future<Result<Account>> updateAccount(Account account);

  Future<Result<void>> deleteAccount(String id);

  Future<Result<void>> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required DateTime date,
    String? note,
  });
}
