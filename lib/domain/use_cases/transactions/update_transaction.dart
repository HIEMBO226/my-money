import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/transaction.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/transaction_repository.dart';

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<Transaction>> call(Transaction transaction) async {
    if (transaction.amount <= 0) {
      return const Failure(
        ValidationException('Transaction amount must be strictly positive.'),
      );
    }
    if (transaction.accountId.trim().isEmpty) {
      return const Failure(
        ValidationException('An account must be selected.'),
      );
    }
    if (transaction.type == TransactionType.transfer) {
      if (transaction.toAccountId == null ||
          transaction.toAccountId!.trim().isEmpty) {
        return const Failure(
          ValidationException('A destination account is required for transfers.'),
        );
      }
      if (transaction.toAccountId == transaction.accountId) {
        return const Failure(
          ValidationException(
            'Source and destination accounts must be different.',
          ),
        );
      }
    } else if (transaction.categoryId == null ||
        transaction.categoryId!.trim().isEmpty) {
      return const Failure(
        ValidationException('A category must be selected.'),
      );
    }

    final trimmedNote = transaction.note?.trim();
    if (trimmedNote != null && trimmedNote.length > AppConstants.maxNoteLength) {
      return const Failure(
        ValidationException('Note exceeds maximum allowed length.'),
      );
    }

    return _repository.updateTransaction(
      transaction.copyWith(
        date: transaction.date.toUtc(),
        categoryId: transaction.type == TransactionType.transfer
            ? null
            : transaction.categoryId,
        clearCategoryId: transaction.type == TransactionType.transfer,
        toAccountId: transaction.type == TransactionType.transfer
            ? transaction.toAccountId
            : null,
        clearToAccountId: transaction.type != TransactionType.transfer,
        note: trimmedNote,
        clearNote: trimmedNote == null || trimmedNote.isEmpty,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
