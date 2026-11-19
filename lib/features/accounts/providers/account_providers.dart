import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/account_repository_impl.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/account_type.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/use_cases/accounts/create_account.dart';
import '../../../domain/use_cases/accounts/delete_account.dart';
import '../../../domain/use_cases/accounts/get_accounts.dart';
import '../../../domain/use_cases/accounts/transfer_between_accounts.dart';
import '../../../domain/use_cases/accounts/update_account.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountRepositoryImpl(db);
});

final getAccountsUseCaseProvider = Provider<GetAccounts>((ref) {
  return GetAccounts(ref.watch(accountRepositoryProvider));
});

final createAccountUseCaseProvider = Provider<CreateAccount>((ref) {
  return CreateAccount(ref.watch(accountRepositoryProvider));
});

final updateAccountUseCaseProvider = Provider<UpdateAccount>((ref) {
  return UpdateAccount(ref.watch(accountRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccount>((ref) {
  return DeleteAccount(ref.watch(accountRepositoryProvider));
});

final transferBetweenAccountsUseCaseProvider =
    Provider<TransferBetweenAccounts>((ref) {
  return TransferBetweenAccounts(ref.watch(accountRepositoryProvider));
});

final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(getAccountsUseCaseProvider).watch();
});

final totalBalanceProvider = Provider<int>((ref) {
  final accounts = ref.watch(accountsStreamProvider).value ?? const [];
  return accounts.fold<int>(0, (sum, account) => sum + account.balance);
});

final accountControllerProvider = Provider<AccountController>((ref) {
  return AccountController(
    ref.watch(createAccountUseCaseProvider),
    ref.watch(updateAccountUseCaseProvider),
    ref.watch(deleteAccountUseCaseProvider),
    ref.watch(transferBetweenAccountsUseCaseProvider),
  );
});

class AccountController {
  const AccountController(
    this._createAccount,
    this._updateAccount,
    this._deleteAccount,
    this._transferBetweenAccounts,
  );

  final CreateAccount _createAccount;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;
  final TransferBetweenAccounts _transferBetweenAccounts;

  Future<Result<Account>> create({
    required String name,
    required AccountType type,
    required int iconCodePoint,
    required int colorValue,
    int initialBalance = 0,
    String? initialBalanceNote,
  }) {
    return _createAccount(
      name: name,
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      initialBalance: initialBalance,
      initialBalanceNote: initialBalanceNote,
    );
  }

  Future<Result<Account>> update(Account account) => _updateAccount(account);

  Future<Result<void>> delete(String id) => _deleteAccount(id);

  Future<Result<void>> transfer({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    DateTime? date,
    String? note,
  }) {
    return _transferBetweenAccounts(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: date,
      note: note,
    );
  }
}
