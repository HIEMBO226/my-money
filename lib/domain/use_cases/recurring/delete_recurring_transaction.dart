import '../../../core/errors/result.dart';
import '../../repositories/recurring_transaction_repository.dart';

class DeleteRecurringTransaction {
  const DeleteRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<Result<void>> call(String id) =>
      _repository.deleteRecurringTransaction(id);
}
