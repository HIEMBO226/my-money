import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/transaction.dart';
import '../../entities/transaction_filter.dart';
import '../../repositories/transaction_repository.dart';

class FilterTransactions {
  const FilterTransactions(this._repository);

  final TransactionRepository _repository;

  Future<Result<List<Transaction>>> call(TransactionFilter filter) async {
    if (filter.startDate != null &&
        filter.endDate != null &&
        filter.startDate!.isAfter(filter.endDate!)) {
      return const Failure(
        ValidationException('Start date cannot be after end date.'),
      );
    }
    if (filter.minAmount != null &&
        filter.maxAmount != null &&
        filter.minAmount! > filter.maxAmount!) {
      return const Failure(
        ValidationException('Minimum amount cannot exceed maximum amount.'),
      );
    }
    return _repository.getTransactions(filter: filter);
  }
}
