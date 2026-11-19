import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/repositories/account_repository.dart';
import 'package:my_money/domain/use_cases/accounts/create_account.dart';
import 'package:my_money/domain/use_cases/accounts/transfer_between_accounts.dart';
import 'package:my_money/domain/use_cases/accounts/update_account.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _FakeAccount extends Fake implements Account {}

void main() {
  late _MockAccountRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeAccount());
  });

  setUp(() {
    repository = _MockAccountRepository();
  });

  group('CreateAccount', () {
    test('fails with ValidationException when name is blank', () async {
      final useCase = CreateAccount(repository);

      final result = await useCase(
        name: '   ',
        type: AccountType.cash,
        iconCodePoint: 0xe227,
        colorValue: 0xFF2196F3,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
      verifyNever(
        () => repository.createAccount(
          any(),
          initialBalance: any(named: 'initialBalance'),
          initialBalanceNote: any(named: 'initialBalanceNote'),
        ),
      );
    });

    test('fails with ValidationException when initialBalance is negative',
        () async {
      final useCase = CreateAccount(repository);

      final result = await useCase(
        name: 'Portefeuille',
        type: AccountType.cash,
        iconCodePoint: 0xe227,
        colorValue: 0xFF2196F3,
        initialBalance: -100,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('trims name and delegates to repository', () async {
      when(
        () => repository.createAccount(
          any(),
          initialBalance: any(named: 'initialBalance'),
          initialBalanceNote: any(named: 'initialBalanceNote'),
        ),
      ).thenAnswer((invocation) async {
        final account = invocation.positionalArguments.first as Account;
        return Success(account);
      });

      final useCase = CreateAccount(repository);
      final result = await useCase(
        name: '  Orange Money  ',
        type: AccountType.mobileMoney,
        iconCodePoint: 0xe4a2,
        colorValue: 0xFFFF9800,
        initialBalance: 25000,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.name, 'Orange Money');
      verify(
        () => repository.createAccount(
          any(),
          initialBalance: 25000,
          initialBalanceNote: null,
        ),
      ).called(1);
    });
  });

  group('UpdateAccount', () {
    test('rejects empty name', () async {
      final useCase = UpdateAccount(repository);
      final now = DateTime.now().toUtc();
      final account = Account(
        id: 'acc-1',
        name: '   ',
        type: AccountType.bank,
        iconCodePoint: 0xe069,
        colorValue: 0xFF2196F3,
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCase(account);
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });

  group('TransferBetweenAccounts', () {
    test('rejects transfer to same account', () async {
      final useCase = TransferBetweenAccounts(repository);

      final result = await useCase(
        fromAccountId: 'acc-1',
        toAccountId: 'acc-1',
        amount: 5000,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('rejects non-positive amount', () async {
      final useCase = TransferBetweenAccounts(repository);

      final result = await useCase(
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 0,
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });

    test('delegates valid transfer to repository', () async {
      when(
        () => repository.transferBetweenAccounts(
          fromAccountId: any(named: 'fromAccountId'),
          toAccountId: any(named: 'toAccountId'),
          amount: any(named: 'amount'),
          date: any(named: 'date'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => const Success(null));

      final useCase = TransferBetweenAccounts(repository);
      final result = await useCase(
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 10000,
        note: '  Épargne mensuelle  ',
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.transferBetweenAccounts(
          fromAccountId: 'acc-1',
          toAccountId: 'acc-2',
          amount: 10000,
          date: any(named: 'date'),
          note: 'Épargne mensuelle',
        ),
      ).called(1);
    });
  });
}
