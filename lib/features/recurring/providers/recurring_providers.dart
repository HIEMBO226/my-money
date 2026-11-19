import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/recurring_transaction_repository_impl.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../domain/enums/recurrence_frequency.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../domain/repositories/recurring_transaction_repository.dart';
import '../../../domain/use_cases/recurring/create_recurring_transaction.dart';
import '../../../domain/use_cases/recurring/delete_recurring_transaction.dart';
import '../../../domain/use_cases/recurring/get_recurring_transactions.dart';
import '../../../domain/use_cases/recurring/process_due_recurring.dart';
import '../../../domain/use_cases/recurring/update_recurring_transaction.dart';
import '../../transactions/providers/transaction_providers.dart';

final recurringRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RecurringTransactionRepositoryImpl(db);
});

final getRecurringUseCaseProvider = Provider<GetRecurringTransactions>((ref) {
  return GetRecurringTransactions(ref.watch(recurringRepositoryProvider));
});

final createRecurringUseCaseProvider =
    Provider<CreateRecurringTransaction>((ref) {
  return CreateRecurringTransaction(ref.watch(recurringRepositoryProvider));
});

final updateRecurringUseCaseProvider =
    Provider<UpdateRecurringTransaction>((ref) {
  return UpdateRecurringTransaction(ref.watch(recurringRepositoryProvider));
});

final deleteRecurringUseCaseProvider =
    Provider<DeleteRecurringTransaction>((ref) {
  return DeleteRecurringTransaction(ref.watch(recurringRepositoryProvider));
});

final processDueRecurringUseCaseProvider = Provider<ProcessDueRecurring>((ref) {
  return ProcessDueRecurring(
    ref.watch(recurringRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
  );
});

/// Runs once when the app starts to generate any due recurring transactions.
final processDueRecurringOnStartupProvider = FutureProvider<int>((ref) async {
  final processDue = ref.watch(processDueRecurringUseCaseProvider);
  final result = await processDue();
  return result.dataOrNull ?? 0;
});

final recurringTransactionsStreamProvider =
    StreamProvider<List<RecurringTransaction>>((ref) {
  return ref.watch(getRecurringUseCaseProvider).watch();
});

final recurringControllerProvider = Provider<RecurringController>((ref) {
  return RecurringController(
    ref.watch(createRecurringUseCaseProvider),
    ref.watch(updateRecurringUseCaseProvider),
    ref.watch(deleteRecurringUseCaseProvider),
    ref.watch(processDueRecurringUseCaseProvider),
  );
});

class RecurringController {
  const RecurringController(
    this._create,
    this._update,
    this._delete,
    this._processDue,
  );

  final CreateRecurringTransaction _create;
  final UpdateRecurringTransaction _update;
  final DeleteRecurringTransaction _delete;
  final ProcessDueRecurring _processDue;

  Future<Result<RecurringTransaction>> create({
    required TransactionType type,
    required int amount,
    required String accountId,
    required RecurrenceFrequency frequency,
    required DateTime nextDueDate,
    String? categoryId,
    String? toAccountId,
    String? note,
    DateTime? endDate,
  }) {
    return _create(
      type: type,
      amount: amount,
      accountId: accountId,
      frequency: frequency,
      nextDueDate: nextDueDate,
      categoryId: categoryId,
      toAccountId: toAccountId,
      note: note,
      endDate: endDate,
    );
  }

  Future<Result<RecurringTransaction>> update(RecurringTransaction item) =>
      _update(item);

  Future<Result<RecurringTransaction>> toggleActive(
    RecurringTransaction item,
    bool isActive,
  ) {
    return _update(item.copyWith(isActive: isActive));
  }

  Future<Result<void>> delete(String id) => _delete(id);

  Future<Result<int>> processDueNow() => _processDue();
}
