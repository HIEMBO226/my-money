import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../repositories/account_repository.dart';

class TransferBetweenAccounts {
  const TransferBetweenAccounts(this._repository);

  final AccountRepository _repository;

  Future<Result<void>> call({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    DateTime? date,
    String? note,
  }) async {
    if (fromAccountId == toAccountId) {
      return const Failure(
        ValidationException('Source and destination accounts must be different.'),
      );
    }
    if (amount <= 0) {
      return const Failure(
        ValidationException('Transfer amount must be strictly positive.'),
      );
    }

    return _repository.transferBetweenAccounts(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: (date ?? DateTime.now()).toUtc(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
  }
}
