import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/recurring_transaction.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/recurring_transaction_repository.dart';

class UpdateRecurringTransaction {
  const UpdateRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<Result<RecurringTransaction>> call(
    RecurringTransaction recurring,
  ) async {
    if (recurring.amount <= 0) {
      return const Failure(
        ValidationException('Recurring amount must be strictly positive.'),
      );
    }
    if (recurring.type == TransactionType.transfer) {
      if (recurring.toAccountId == null ||
          recurring.toAccountId == recurring.accountId) {
        return const Failure(
          ValidationException(
            'Source and destination accounts must be different.',
          ),
        );
      }
    } else if (recurring.categoryId == null ||
        recurring.categoryId!.trim().isEmpty) {
      return const Failure(
        ValidationException('A category must be selected.'),
      );
    }

    final nextUtc = recurring.nextDueDate.toUtc();
    final endUtc = recurring.endDate?.toUtc();
    if (endUtc != null && endUtc.isBefore(nextUtc)) {
      return const Failure(
        ValidationException('End date cannot be before next due date.'),
      );
    }

    final trimmedNote = recurring.note?.trim();
    if (trimmedNote != null && trimmedNote.length > AppConstants.maxNoteLength) {
      return const Failure(
        ValidationException('Note exceeds maximum allowed length.'),
      );
    }

    return _repository.updateRecurringTransaction(
      recurring.copyWith(
        categoryId: recurring.type == TransactionType.transfer
            ? null
            : recurring.categoryId,
        clearCategoryId: recurring.type == TransactionType.transfer,
        toAccountId: recurring.type == TransactionType.transfer
            ? recurring.toAccountId
            : null,
        clearToAccountId: recurring.type != TransactionType.transfer,
        note: trimmedNote,
        clearNote: trimmedNote == null || trimmedNote.isEmpty,
        nextDueDate: nextUtc,
        endDate: endUtc,
        clearEndDate: endUtc == null,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
