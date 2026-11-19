import '../../core/errors/result.dart';
import '../entities/recurring_transaction.dart';

abstract interface class RecurringTransactionRepository {
  Stream<List<RecurringTransaction>> watchRecurringTransactions();

  Future<Result<List<RecurringTransaction>>> getRecurringTransactions();

  Future<Result<List<RecurringTransaction>>> getDueRecurringTransactions(
    DateTime asOfUtc,
  );

  Future<Result<RecurringTransaction>> createRecurringTransaction(
    RecurringTransaction recurring,
  );

  Future<Result<RecurringTransaction>> updateRecurringTransaction(
    RecurringTransaction recurring,
  );

  Future<Result<void>> deleteRecurringTransaction(String id);
}
