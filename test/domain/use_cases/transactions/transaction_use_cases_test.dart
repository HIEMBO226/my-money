import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/entities/transaction_filter.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/repositories/transaction_repository.dart';
import 'package:my_money/domain/use_cases/transactions/create_transaction.dart';
import 'package:my_money/domain/use_cases/transactions/filter_transactions.dart';
import 'package:my_money/domain/use_cases/transactions/update_transaction.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _FakeTransaction extends Fake implements Transaction {}

void main() {
  late _MockTransactionRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeTransaction());
    registerFallbackValue(const TransactionFilter());
  });

  setUp(() {
    repository = _MockTransactionRepository();
  });

  group('CreateTransaction', () {
    test('fails when amount is zero or negative', () async {
      final useCase = CreateTransaction(repository);

      final result = await useCase(
        type: TransactionType.expense,
        amount: 0,
        date: DateTime.now(),
        accountId: 'acc-1',
        categoryId: 'cat-1',
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
      verifyNever(() => repository.createTransaction(any()));
    });

    test('fails when expense has no category', () async {
      final useCase = CreateTransaction(repository);

      final result = await useCase(
        type: TransactionType.expense,
        amount: 2500,
        date: DateTime.now(),
        accountId: 'acc-1',
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('fails when transfer targets the same account', () async {
      final useCase = CreateTransaction(repository);

      final result = await useCase(
        type: TransactionType.transfer,
        amount: 10000,
        date: DateTime.now(),
        accountId: 'acc-1',
        toAccountId: 'acc-1',
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('stores UTC date and trims note for valid expense', () async {
      when(() => repository.createTransaction(any())).thenAnswer((inv) async {
        return Success(inv.positionalArguments.first as Transaction);
      });

      final useCase = CreateTransaction(repository);
      final localDate = DateTime(2026, 11, 18, 14, 30);
      final result = await useCase(
        type: TransactionType.expense,
        amount: 3500,
        date: localDate,
        accountId: 'acc-1',
        categoryId: 'cat-food',
        note: '  Déjeuner  ',
      );

      expect(result.isSuccess, isTrue);
      final saved = result.dataOrNull!;
      expect(saved.date.isUtc, isTrue);
      expect(saved.note, 'Déjeuner');
      expect(saved.toAccountId, isNull);
    });
  });

  group('UpdateTransaction', () {
    test('rejects invalid amount on update', () async {
      final useCase = UpdateTransaction(repository);
      final now = DateTime.now().toUtc();
      final tx = Transaction(
        id: 'tx-1',
        type: TransactionType.income,
        amount: -50,
        date: now,
        accountId: 'acc-1',
        categoryId: 'cat-salary',
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCase(tx);
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });

  group('FilterTransactions', () {
    test('rejects startDate after endDate', () async {
      final useCase = FilterTransactions(repository);
      final result = await useCase(
        TransactionFilter(
          startDate: DateTime.utc(2026, 11, 20),
          endDate: DateTime.utc(2026, 11, 10),
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('rejects minAmount greater than maxAmount', () async {
      final useCase = FilterTransactions(repository);
      final result = await useCase(
        const TransactionFilter(minAmount: 10000, maxAmount: 5000),
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });
}
