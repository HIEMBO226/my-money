import '../../../core/errors/result.dart';
import '../../repositories/category_repository.dart';

class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteCategory(id);
}
