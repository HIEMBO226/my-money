import '../../../core/errors/result.dart';
import '../../entities/recurring_transaction.dart';
import '../../repositories/recurring_transaction_repository.dart';

class GetRecurringTransactions {
  const GetRecurringTransactions(this._repository);

  final RecurringTransactionRepository _repository;

  Future<Result<List<RecurringTransaction>>> call() =>
      _repository.getRecurringTransactions();

  Stream<List<RecurringTransaction>> watch() =>
      _repository.watchRecurringTransactions();
}
