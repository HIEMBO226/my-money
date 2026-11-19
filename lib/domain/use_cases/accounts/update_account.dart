import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/account.dart';
import '../../repositories/account_repository.dart';

class UpdateAccount {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<Result<Account>> call(Account account) async {
    final trimmedName = account.name.trim();
    if (trimmedName.isEmpty ||
        trimmedName.length > AppConstants.maxAccountNameLength) {
      return const Failure(
        ValidationException('Account name must be between 1 and 50 characters.'),
      );
    }

    return _repository.updateAccount(
      account.copyWith(
        name: trimmedName,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
