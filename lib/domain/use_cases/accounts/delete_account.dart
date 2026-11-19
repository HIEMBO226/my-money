import '../../../core/errors/result.dart';
import '../../repositories/account_repository.dart';

class DeleteAccount {
  const DeleteAccount(this._repository);

  final AccountRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAccount(id);
}
