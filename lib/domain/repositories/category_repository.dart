import '../../core/errors/result.dart';
import '../entities/category.dart';
import '../enums/transaction_type.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchCategories({TransactionType? type});

  Future<Result<List<Category>>> getCategories({TransactionType? type});

  Future<Result<Category>> getCategoryById(String id);

  Future<Result<Category>> createCategory(Category category);

  Future<Result<Category>> updateCategory(Category category);

  Future<Result<void>> deleteCategory(String id);

  Future<Result<void>> seedDefaultCategories();
}
