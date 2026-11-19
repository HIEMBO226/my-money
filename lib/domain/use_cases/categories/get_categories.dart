import '../../../core/errors/result.dart';
import '../../entities/category.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<Category>>> call({TransactionType? type}) =>
      _repository.getCategories(type: type);

  Stream<List<Category>> watch({TransactionType? type}) =>
      _repository.watchCategories(type: type);
}
