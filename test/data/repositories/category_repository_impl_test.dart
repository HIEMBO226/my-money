import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/database/seed/default_categories.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/domain/entities/category.dart';
import 'package:my_money/domain/enums/transaction_type.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl', () {
    test('seeds default categories idempotently', () async {
      final firstSeed = await repository.seedDefaultCategories();
      final secondSeed = await repository.seedDefaultCategories();

      expect(firstSeed.isSuccess, isTrue);
      expect(secondSeed.isSuccess, isTrue);

      final all = await repository.getCategories();
      expect(all.dataOrNull?.length, DefaultCategories.items.length);

      final expenses =
          await repository.getCategories(type: TransactionType.expense);
      final incomes =
          await repository.getCategories(type: TransactionType.income);

      expect(expenses.dataOrNull, isNotEmpty);
      expect(incomes.dataOrNull, isNotEmpty);
      expect(
        expenses.dataOrNull!.length + incomes.dataOrNull!.length,
        DefaultCategories.items.length,
      );
    });

    test('creates, updates and deletes a custom category', () async {
      final now = DateTime.now().toUtc();
      final custom = Category(
        id: 'cat-custom',
        type: TransactionType.expense,
        name: 'Café',
        iconCodePoint: 0xe390,
        colorValue: 0xFF795548,
        createdAt: now,
        updatedAt: now,
      );

      final created = await repository.createCategory(custom);
      expect(created.isSuccess, isTrue);

      final updated = await repository.updateCategory(
        custom.copyWith(name: 'Café & Thé'),
      );
      expect(updated.isSuccess, isTrue);

      final fetched = await repository.getCategoryById('cat-custom');
      expect(fetched.dataOrNull?.name, 'Café & Thé');

      final deleted = await repository.deleteCategory('cat-custom');
      expect(deleted.isSuccess, isTrue);
    });

    test('prevents deleting default categories', () async {
      await repository.seedDefaultCategories();

      final result = await repository.deleteCategory('cat_exp_food');
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });
}
