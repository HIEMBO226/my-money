import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/category.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/app_database.dart';
import '../database/daos/categories_dao.dart';
import '../database/seed/default_categories.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  CategoriesDao get _dao => _db.categoriesDao;

  Category _toEntity(CategoryEntry entry) {
    return Category(
      id: entry.id,
      type: TransactionType.values[entry.type],
      name: entry.name,
      iconCodePoint: entry.iconCodePoint,
      colorValue: entry.colorValue,
      isDefault: entry.isDefault,
      sortOrder: entry.sortOrder,
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  @override
  Stream<List<Category>> watchCategories({TransactionType? type}) {
    return _dao
        .watchCategories(typeIndex: type?.index)
        .map((entries) => entries.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Category>>> getCategories({TransactionType? type}) async {
    try {
      final entries = await _dao.getCategories(typeIndex: type?.index);
      return Success(entries.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch categories: $e'));
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      final entry = await _dao.getCategoryById(id);
      if (entry == null) {
        return Failure(NotFoundException('Category not found: $id'));
      }
      return Success(_toEntity(entry));
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch category: $e'));
    }
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      await _dao.insertCategory(
        CategoriesCompanion.insert(
          id: category.id,
          type: category.type.index,
          name: category.name,
          iconCodePoint: category.iconCodePoint,
          colorValue: category.colorValue,
          isDefault: Value(category.isDefault),
          sortOrder: Value(category.sortOrder),
          createdAt: category.createdAt.toUtcMillis,
          updatedAt: category.updatedAt.toUtcMillis,
        ),
      );
      return Success(category);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to create category: $e'));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      final updated = await _dao.updateCategoryEntry(
        CategoriesCompanion(
          id: Value(category.id),
          type: Value(category.type.index),
          name: Value(category.name),
          iconCodePoint: Value(category.iconCodePoint),
          colorValue: Value(category.colorValue),
          sortOrder: Value(category.sortOrder),
          updatedAt: Value(category.updatedAt.toUtcMillis),
        ),
      );
      if (!updated) {
        return Failure(NotFoundException('Category not found: ${category.id}'));
      }
      return Success(category);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to update category: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      final existing = await _dao.getCategoryById(id);
      if (existing == null) {
        return Failure(NotFoundException('Category not found: $id'));
      }
      if (existing.isDefault) {
        return const Failure(
          ValidationException('Default categories cannot be deleted.'),
        );
      }
      final isUsed = await _dao.isCategoryUsed(id);
      if (isUsed) {
        return const Failure(
          ValidationException(
            'Cannot delete a category linked to transactions or budgets.',
          ),
        );
      }
      await _dao.deleteCategoryById(id);
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to delete category: $e'));
    }
  }

  @override
  Future<Result<void>> seedDefaultCategories() async {
    try {
      final count = await _dao.countCategories();
      if (count > 0) {
        return const Success(null);
      }
      final nowMillis = DateTime.now().toUtcMillis;
      await _dao.insertCategoriesBatch(
        DefaultCategories.toCompanions(nowMillis),
      );
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to seed default categories: $e'),
      );
    }
  }
}
