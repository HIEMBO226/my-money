import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/recurring_transaction.dart';
import '../../entities/transaction.dart';
import '../../repositories/recurring_transaction_repository.dart';
import '../../repositories/transaction_repository.dart';

class ProcessDueRecurring {
  const ProcessDueRecurring(
    this._recurringRepository,
    this._transactionRepository,
  );

  final RecurringTransactionRepository _recurringRepository;
  final TransactionRepository _transactionRepository;

  /// Safety cap to avoid runaway generation if device clock jumps far ahead.
  static const int _maxOccurrencesPerTemplate = 60;

  /// Generates transactions for all active recurring templates whose
  /// `nextDueDate` is at or before [nowUtc] (defaults to `DateTime.now().toUtc()`).
  /// Returns the number of newly created transactions.
  Future<Result<int>> call({DateTime? nowUtc}) async {
    final referenceNow = (nowUtc ?? DateTime.now()).toUtc();
    final dueResult =
        await _recurringRepository.getDueRecurringTransactions(referenceNow);

    if (dueResult.isFailure) {
      return Failure(dueResult.exceptionOrNull!);
    }

    final dueTemplates = dueResult.dataOrNull ?? const [];
    var generatedCount = 0;

    for (final template in dueTemplates) {
      var cursorDate = template.nextDueDate.toUtc();
      var occurrencesForTemplate = 0;
      var stillActive = template.isActive;

      while (stillActive &&
          !cursorDate.isAfter(referenceNow) &&
          occurrencesForTemplate < _maxOccurrencesPerTemplate) {
        if (template.endDate != null &&
            cursorDate.isAfter(template.endDate!.toUtc())) {
          stillActive = false;
          break;
        }

        final now = DateTime.now().toUtc();
        final txResult = await _transactionRepository.createTransaction(
          Transaction(
            id: IdGenerator.generate(),
            type: template.type,
            amount: template.amount,
            date: cursorDate,
            accountId: template.accountId,
            categoryId: template.categoryId,
            toAccountId: template.toAccountId,
            note: template.note,
            recurringTransactionId: template.id,
            createdAt: now,
            updatedAt: now,
          ),
        );

        if (txResult.isFailure) {
          return Failure(txResult.exceptionOrNull!);
        }

        generatedCount++;
        occurrencesForTemplate++;
        cursorDate = RecurringTransaction.computeNextDueDate(
          cursorDate,
          template.frequency,
        );

        if (template.endDate != null &&
            cursorDate.isAfter(template.endDate!.toUtc())) {
          stillActive = false;
        }
      }

      final updateResult =
          await _recurringRepository.updateRecurringTransaction(
        template.copyWith(
          nextDueDate: cursorDate,
          isActive: stillActive,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      if (updateResult.isFailure) {
        return Failure(updateResult.exceptionOrNull!);
      }
    }

    return Success(generatedCount);
  }
}
