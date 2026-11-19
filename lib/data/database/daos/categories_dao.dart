import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories, Transactions, Budgets])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<CategoryEntry>> watchCategories({int? typeIndex}) {
    final query = select(categories)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (typeIndex != null) {
      query.where((t) => t.type.equals(typeIndex));
    }
    return query.watch();
  }

  Future<List<CategoryEntry>> getCategories({int? typeIndex}) {
    final query = select(categories)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (typeIndex != null) {
      query.where((t) => t.type.equals(typeIndex));
    }
    return query.get();
  }

  Future<CategoryEntry?> getCategoryById(String id) {
    return (select(categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> countCategories() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS cnt FROM categories',
      readsFrom: {categories},
    ).getSingle();
    return row.read<int>('cnt');
  }

  Future<void> insertCategory(CategoriesCompanion entry) async {
    await into(categories).insert(entry);
  }

  Future<void> insertCategoriesBatch(List<CategoriesCompanion> entries) async {
    await batch((b) {
      b.insertAll(categories, entries, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<bool> updateCategoryEntry(CategoriesCompanion entry) async {
    final affected = await (update(categories)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    return affected > 0;
  }

  Future<bool> isCategoryUsed(String categoryId) async {
    final txRow = await customSelect(
      'SELECT COUNT(*) AS cnt FROM transactions WHERE category_id = ?1',
      variables: [Variable.withString(categoryId)],
      readsFrom: {transactions},
    ).getSingle();
    if (txRow.read<int>('cnt') > 0) return true;

    final budgetRow = await customSelect(
      'SELECT COUNT(*) AS cnt FROM budgets WHERE category_id = ?1',
      variables: [Variable.withString(categoryId)],
      readsFrom: {budgets},
    ).getSingle();
    return budgetRow.read<int>('cnt') > 0;
  }

  Future<int> deleteCategoryById(String id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }
}
