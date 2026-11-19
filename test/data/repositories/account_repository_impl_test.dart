import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/repositories/account_repository_impl.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/enums/account_type.dart';

void main() {
  late AppDatabase db;
  late AccountRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AccountRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Account buildAccount(String id, String name, AccountType type) {
    final now = DateTime.now().toUtc();
    return Account(
      id: id,
      name: name,
      type: type,
      iconCodePoint: type.defaultIconCodePoint,
      colorValue: 0xFF2196F3,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('AccountRepositoryImpl', () {
    test('creates account with initial balance and computes balance accurately',
        () async {
      final result = await repository.createAccount(
        buildAccount('acc-1', 'Banque', AccountType.bank),
        initialBalance: 100000,
        initialBalanceNote: 'Solde initial',
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.balance, 100000);

      final fetched = await repository.getAccounts();
      expect(fetched.dataOrNull?.length, 1);
      expect(fetched.dataOrNull?.first.balance, 100000);
    });

    test('updates account metadata while preserving balance', () async {
      final created = await repository.createAccount(
        buildAccount('acc-1', 'Espèces', AccountType.cash),
        initialBalance: 5000,
      );

      final updated = await repository.updateAccount(
        created.dataOrNull!.copyWith(name: 'Portefeuille'),
      );

      expect(updated.isSuccess, isTrue);
      expect(updated.dataOrNull?.name, 'Portefeuille');
      expect(updated.dataOrNull?.balance, 5000);
    });

    test('computes balances correctly after transfer between accounts',
        () async {
      await repository.createAccount(
        buildAccount('acc-1', 'Banque', AccountType.bank),
        initialBalance: 100000,
      );
      await repository.createAccount(
        buildAccount('acc-2', 'Épargne', AccountType.savings),
        initialBalance: 20000,
      );

      final transfer = await repository.transferBetweenAccounts(
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 35000,
        date: DateTime.now().toUtc(),
        note: 'Virement épargne',
      );
      expect(transfer.isSuccess, isTrue);

      final bank = await repository.getAccountById('acc-1');
      final savings = await repository.getAccountById('acc-2');

      expect(bank.dataOrNull?.balance, 65000);
      expect(savings.dataOrNull?.balance, 55000);
    });

    test('allows deleting unused account and blocks deleting used account',
        () async {
      await repository.createAccount(
        buildAccount('acc-empty', 'Vide', AccountType.cash),
      );
      await repository.createAccount(
        buildAccount('acc-used', 'Utilisé', AccountType.bank),
        initialBalance: 1000,
      );

      final deleteEmpty = await repository.deleteAccount('acc-empty');
      expect(deleteEmpty.isSuccess, isTrue);

      final deleteUsed = await repository.deleteAccount('acc-used');
      expect(deleteUsed.isFailure, isTrue);
      expect(deleteUsed.exceptionOrNull, isA<ValidationException>());
    });
  });
}
