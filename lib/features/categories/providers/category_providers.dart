import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/use_cases/categories/create_category.dart';
import '../../../domain/use_cases/categories/delete_category.dart';
import '../../../domain/use_cases/categories/get_categories.dart';
import '../../../domain/use_cases/categories/update_category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepositoryImpl(db);
});

final seedDefaultCategoriesProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  await repository.seedDefaultCategories();
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(categoryRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.watch(categoryRepositoryProvider));
});

final categoriesStreamProvider =
    StreamProvider.family<List<Category>, TransactionType?>((ref, type) async* {
  await ref.watch(seedDefaultCategoriesProvider.future);
  final getCategories = ref.watch(getCategoriesUseCaseProvider);
  yield* getCategories.watch(type: type);
});

final categoryControllerProvider = Provider<CategoryController>((ref) {
  return CategoryController(
    ref.watch(createCategoryUseCaseProvider),
    ref.watch(updateCategoryUseCaseProvider),
    ref.watch(deleteCategoryUseCaseProvider),
  );
});

class CategoryController {
  const CategoryController(
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
  );

  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  Future<Result<Category>> create({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required int colorValue,
  }) {
    return _createCategory(
      name: name,
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );
  }

  Future<Result<Category>> update(Category category) =>
      _updateCategory(category);

  Future<Result<void>> delete(String id) => _deleteCategory(id);
}
