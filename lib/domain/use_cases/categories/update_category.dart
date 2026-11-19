import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/category.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/category_repository.dart';

class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call(Category category) async {
    final trimmedName = category.name.trim();
    if (trimmedName.isEmpty ||
        trimmedName.length > AppConstants.maxCategoryNameLength) {
      return const Failure(
        ValidationException(
          'Category name must be between 1 and 50 characters.',
        ),
      );
    }
    if (category.type == TransactionType.transfer) {
      return const Failure(
        ValidationException('Categories cannot be of type transfer.'),
      );
    }

    return _repository.updateCategory(
      category.copyWith(
        name: trimmedName,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
