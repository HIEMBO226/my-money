import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/category.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/repositories/category_repository.dart';
import 'package:my_money/domain/use_cases/categories/create_category.dart';
import 'package:my_money/domain/use_cases/categories/update_category.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _FakeCategory extends Fake implements Category {}

void main() {
  late _MockCategoryRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeCategory());
  });

  setUp(() {
    repository = _MockCategoryRepository();
  });

  group('CreateCategory', () {
    test('fails when name is empty', () async {
      final useCase = CreateCategory(repository);

      final result = await useCase(
        name: '  ',
        type: TransactionType.expense,
        iconCodePoint: 0xe532,
        colorValue: 0xFFFF9800,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('fails when type is transfer', () async {
      final useCase = CreateCategory(repository);

      final result = await useCase(
        name: 'Transfert',
        type: TransactionType.transfer,
        iconCodePoint: 0xe532,
        colorValue: 0xFFFF9800,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('creates custom non-default category', () async {
      when(() => repository.createCategory(any())).thenAnswer((inv) async {
        return Success(inv.positionalArguments.first as Category);
      });

      final useCase = CreateCategory(repository);
      final result = await useCase(
        name: '  Café  ',
        type: TransactionType.expense,
        iconCodePoint: 0xe390,
        colorValue: 0xFF795548,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.name, 'Café');
      expect(result.dataOrNull?.isDefault, isFalse);
    });
  });

  group('UpdateCategory', () {
    test('rejects transfer type on update', () async {
      final useCase = UpdateCategory(repository);
      final now = DateTime.now().toUtc();
      final category = Category(
        id: 'cat-1',
        type: TransactionType.transfer,
        name: 'Test',
        iconCodePoint: 0xe532,
        colorValue: 0xFFFF9800,
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCase(category);
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });
}
