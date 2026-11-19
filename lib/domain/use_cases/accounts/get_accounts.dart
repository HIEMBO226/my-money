import '../../../core/errors/result.dart';
import '../../entities/account.dart';
import '../../repositories/account_repository.dart';

class GetAccounts {
  const GetAccounts(this._repository);

  final AccountRepository _repository;

  Future<Result<List<Account>>> call() => _repository.getAccounts();

  Stream<List<Account>> watch() => _repository.watchAccounts();
}
