import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/id_generator.dart';
import '../../entities/category.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/category_repository.dart';

class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty ||
        trimmedName.length > AppConstants.maxCategoryNameLength) {
      return const Failure(
        ValidationException(
          'Category name must be between 1 and 50 characters.',
        ),
      );
    }
    if (type == TransactionType.transfer) {
      return const Failure(
        ValidationException('Categories cannot be of type transfer.'),
      );
    }

    final now = DateTime.now().toUtc();
    final category = Category(
      id: IdGenerator.generate(),
      type: type,
      name: trimmedName,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createCategory(category);
  }
}
