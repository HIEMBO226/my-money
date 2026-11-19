import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/attachment.dart';
import '../../entities/transaction.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/transaction_repository.dart';

class CreateTransaction {
  const CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<Transaction>> call({
    required TransactionType type,
    required int amount,
    required DateTime date,
    required String accountId,
    String? categoryId,
    String? toAccountId,
    String? note,
    String? recurringTransactionId,
    List<Attachment> attachments = const [],
  }) async {
    if (amount <= 0) {
      return const Failure(
        ValidationException('Transaction amount must be strictly positive.'),
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

    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > AppConstants.maxNoteLength) {
      return const Failure(
        ValidationException('Note exceeds maximum allowed length.'),
      );
    }

    final now = DateTime.now().toUtc();
    final transactionId = IdGenerator.generate();
    final normalizedAttachments = attachments
        .map(
          (a) => Attachment(
            id: a.id.isEmpty ? IdGenerator.generate() : a.id,
            transactionId: transactionId,
            filePath: a.filePath,
            fileName: a.fileName,
            mimeType: a.mimeType,
            createdAt: a.createdAt.toUtc(),
          ),
        )
        .toList();

    final transaction = Transaction(
      id: transactionId,
      type: type,
      amount: amount,
      date: date.toUtc(),
      accountId: accountId,
      categoryId: type == TransactionType.transfer ? null : categoryId,
      toAccountId: type == TransactionType.transfer ? toAccountId : null,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      recurringTransactionId: recurringTransactionId,
      attachments: normalizedAttachments,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createTransaction(transaction);
  }
}
