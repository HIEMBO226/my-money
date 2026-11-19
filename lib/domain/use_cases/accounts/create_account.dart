import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/account.dart';
import '../../enums/account_type.dart';
import '../../repositories/account_repository.dart';

class CreateAccount {
  const CreateAccount(this._repository);

  final AccountRepository _repository;

  Future<Result<Account>> call({
    required String name,
    required AccountType type,
    required int iconCodePoint,
    required int colorValue,
    int initialBalance = 0,
    String? initialBalanceNote,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty ||
        trimmedName.length > AppConstants.maxAccountNameLength) {
      return const Failure(
        ValidationException('Account name must be between 1 and 50 characters.'),
      );
    }
    if (initialBalance < 0) {
      return const Failure(
        ValidationException('Initial balance cannot be negative.'),
      );
    }

    final now = DateTime.now().toUtc();
    final account = Account(
      id: IdGenerator.generate(),
      name: trimmedName,
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      balance: initialBalance,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createAccount(
      account,
      initialBalance: initialBalance,
      initialBalanceNote: initialBalanceNote,
    );
  }
}
