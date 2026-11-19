import '../../../core/errors/result.dart';
import '../../repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteTransaction(id);
}
