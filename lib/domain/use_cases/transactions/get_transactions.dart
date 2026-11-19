import '../../../core/errors/result.dart';
import '../../entities/transaction.dart';
import '../../entities/transaction_filter.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  Future<Result<List<Transaction>>> call({
    TransactionFilter filter = const TransactionFilter(),
  }) =>
      _repository.getTransactions(filter: filter);

  Stream<List<Transaction>> watch({
    TransactionFilter filter = const TransactionFilter(),
  }) =>
      _repository.watchTransactions(filter: filter);
}
