import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/recurring_transaction.dart';
import '../../enums/recurrence_frequency.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/recurring_transaction_repository.dart';

class CreateRecurringTransaction {
  const CreateRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<Result<RecurringTransaction>> call({
    required TransactionType type,
    required int amount,
    required String accountId,
    required RecurrenceFrequency frequency,
    required DateTime nextDueDate,
    String? categoryId,
    String? toAccountId,
    String? note,
    DateTime? endDate,
  }) async {
    if (amount <= 0) {
      return const Failure(
        ValidationException('Recurring amount must be strictly positive.'),
      );
    }
    if (accountId.trim().isEmpty) {
      return const Failure(
        ValidationException('An account must be selected.'),
      );
    }
    if (type == TransactionType.transfer) {
      if (toAccountId == null || toAccountId.trim().isEmpty) {
        return const Failure(
          ValidationException('A destination account is required for transfers.'),
        );
      }
      if (toAccountId == accountId) {
        return const Failure(
          ValidationException(
            'Source and destination accounts must be different.',
          ),
        );
      }
    } else if (categoryId == null || categoryId.trim().isEmpty) {
      return const Failure(
        ValidationException('A category must be selected.'),
      );
    }

    final nextUtc = nextDueDate.toUtc();
    final endUtc = endDate?.toUtc();
    if (endUtc != null && endUtc.isBefore(nextUtc)) {
      return const Failure(
        ValidationException('End date cannot be before the first due date.'),
      );
    }

    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > AppConstants.maxNoteLength) {
      return const Failure(
        ValidationException('Note exceeds maximum allowed length.'),
      );
    }

    final now = DateTime.now().toUtc();
    final item = RecurringTransaction(
      id: IdGenerator.generate(),
      type: type,
      amount: amount,
      accountId: accountId,
      categoryId: type == TransactionType.transfer ? null : categoryId,
      toAccountId: type == TransactionType.transfer ? toAccountId : null,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      frequency: frequency,
      nextDueDate: nextUtc,
      endDate: endUtc,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createRecurringTransaction(item);
  }
}
