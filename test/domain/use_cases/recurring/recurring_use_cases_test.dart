import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';
import 'package:my_money/domain/entities/recurring_transaction.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/enums/recurrence_frequency.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/repositories/recurring_transaction_repository.dart';
import 'package:my_money/domain/repositories/transaction_repository.dart';
import 'package:my_money/domain/use_cases/recurring/create_recurring_transaction.dart';
import 'package:my_money/domain/use_cases/recurring/process_due_recurring.dart';

class _MockRecurringRepo extends Mock
    implements RecurringTransactionRepository {}

class _MockTransactionRepo extends Mock implements TransactionRepository {}

class _FakeRecurring extends Fake implements RecurringTransaction {}

class _FakeTransaction extends Fake implements Transaction {}

void main() {
  late _MockRecurringRepo recurringRepo;
  late _MockTransactionRepo transactionRepo;

  setUpAll(() {
    registerFallbackValue(_FakeRecurring());
    registerFallbackValue(_FakeTransaction());
  });

  setUp(() {
    recurringRepo = _MockRecurringRepo();
    transactionRepo = _MockTransactionRepo();
  });

  group('RecurringTransaction.computeNextDueDate', () {
    test('clamps monthly month-end dates properly (Jan 31 -> Feb 28/29)', () {
      final nonLeap = RecurringTransaction.computeNextDueDate(
        DateTime.utc(2026, 1, 31, 9),
        RecurrenceFrequency.monthly,
      );
      expect(nonLeap, DateTime.utc(2026, 2, 28, 9));

      final leap = RecurringTransaction.computeNextDueDate(
        DateTime.utc(2028, 1, 31, 9),
        RecurrenceFrequency.monthly,
      );
      expect(leap, DateTime.utc(2028, 2, 29, 9));
    });

    test('clamps yearly leap day cleanly (Feb 29 2028 -> Feb 28 2029)', () {
      final next = RecurringTransaction.computeNextDueDate(
        DateTime.utc(2028, 2, 29, 9),
        RecurrenceFrequency.yearly,
      );
      expect(next, DateTime.utc(2029, 2, 28, 9));
    });
  });

  group('CreateRecurringTransaction', () {
    test('rejects endDate before nextDueDate', () async {
      final useCase = CreateRecurringTransaction(recurringRepo);
      final result = await useCase(
        type: TransactionType.expense,
        amount: 100000,
        accountId: 'acc-1',
        categoryId: 'cat-housing',
        frequency: RecurrenceFrequency.monthly,
        nextDueDate: DateTime.utc(2026, 11, 20),
        endDate: DateTime.utc(2026, 11, 10),
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<ValidationException>());
    });
  });

  group('ProcessDueRecurring', () {
    test('generates missed occurrences and deactivates once past endDate',
        () async {
      final now = DateTime.utc(2026, 11, 18, 12);
      final template = RecurringTransaction(
        id: 'rec-1',
        type: TransactionType.expense,
        amount: 5000,
        accountId: 'acc-1',
        categoryId: 'cat-bills',
        note: 'Abonnement',
        frequency: RecurrenceFrequency.weekly,
        nextDueDate: DateTime.utc(2026, 11, 1, 9),
        endDate: DateTime.utc(2026, 11, 15, 23, 59),
        createdAt: now,
        updatedAt: now,
      );

      when(() => recurringRepo.getDueRecurringTransactions(now))
          .thenAnswer((_) async => Success([template]));
      when(() => transactionRepo.createTransaction(any())).thenAnswer(
        (inv) async => Success(inv.positionalArguments.first as Transaction),
      );

      RecurringTransaction? updatedTemplate;
      when(() => recurringRepo.updateRecurringTransaction(any()))
          .thenAnswer((inv) async {
        updatedTemplate = inv.positionalArguments.first as RecurringTransaction;
        return Success(updatedTemplate!);
      });

      final useCase = ProcessDueRecurring(recurringRepo, transactionRepo);
      final result = await useCase(nowUtc: now);

      // Nov 1, Nov 8, Nov 15 = 3 occurrences; next due Nov 22 > endDate Nov 15 -> deactivated
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 3);
      verify(() => transactionRepo.createTransaction(any())).called(3);
      expect(updatedTemplate?.isActive, isFalse);
      expect(updatedTemplate?.nextDueDate, DateTime.utc(2026, 11, 22, 9));
    });
  });
}
