import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/enums/recurrence_frequency.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../database/app_database.dart';
import '../database/daos/recurring_transactions_dao.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  const RecurringTransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  RecurringTransactionsDao get _dao => _db.recurringTransactionsDao;

  RecurringTransaction _toEntity(RecurringTransactionEntry entry) {
    return RecurringTransaction(
      id: entry.id,
      type: TransactionType.values[entry.type],
      amount: entry.amount,
      accountId: entry.accountId,
      categoryId: entry.categoryId,
      toAccountId: entry.toAccountId,
      note: entry.note,
      frequency: RecurrenceFrequency.values[entry.frequency],
      nextDueDate: fromUtcMillis(entry.nextDueDate),
      endDate: entry.endDate == null ? null : fromUtcMillis(entry.endDate!),
      isActive: entry.isActive,
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  @override
  Stream<List<RecurringTransaction>> watchRecurringTransactions() {
    return _dao.watchAll().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<RecurringTransaction>>> getRecurringTransactions() async {
    try {
      final rows = await _dao.getAll();
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to fetch recurring transactions: $e'),
      );
    }
  }

  @override
  Future<Result<List<RecurringTransaction>>> getDueRecurringTransactions(
    DateTime asOfUtc,
  ) async {
    try {
      final rows = await _dao.getDue(asOfUtc.toUtcMillis);
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to fetch due recurring transactions: $e'),
      );
    }
  }

  @override
  Future<Result<RecurringTransaction>> createRecurringTransaction(
    RecurringTransaction recurring,
  ) async {
    try {
      await _dao.insertEntry(
        RecurringTransactionsCompanion.insert(
          id: recurring.id,
          type: recurring.type.index,
          amount: recurring.amount,
          accountId: recurring.accountId,
          categoryId: Value(recurring.categoryId),
          toAccountId: Value(recurring.toAccountId),
          note: Value(recurring.note),
          frequency: recurring.frequency.index,
          nextDueDate: recurring.nextDueDate.toUtcMillis,
          endDate: Value(recurring.endDate?.toUtcMillis),
          isActive: Value(recurring.isActive),
          createdAt: recurring.createdAt.toUtcMillis,
          updatedAt: recurring.updatedAt.toUtcMillis,
        ),
      );
      return Success(recurring);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to create recurring transaction: $e'),
      );
    }
  }

  @override
  Future<Result<RecurringTransaction>> updateRecurringTransaction(
    RecurringTransaction recurring,
  ) async {
    try {
      final updated = await _dao.updateEntry(
        RecurringTransactionsCompanion(
          id: Value(recurring.id),
          type: Value(recurring.type.index),
          amount: Value(recurring.amount),
          accountId: Value(recurring.accountId),
          categoryId: Value(recurring.categoryId),
          toAccountId: Value(recurring.toAccountId),
          note: Value(recurring.note),
          frequency: Value(recurring.frequency.index),
          nextDueDate: Value(recurring.nextDueDate.toUtcMillis),
          endDate: Value(recurring.endDate?.toUtcMillis),
          isActive: Value(recurring.isActive),
          updatedAt: Value(recurring.updatedAt.toUtcMillis),
        ),
      );
      if (!updated) {
        return Failure(
          NotFoundException('Recurring transaction not found: ${recurring.id}'),
        );
      }
      return Success(recurring);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to update recurring transaction: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteRecurringTransaction(String id) async {
    try {
      final deleted = await _db.transaction(() => _dao.deleteById(id));
      if (deleted == 0) {
        return Failure(
          NotFoundException('Recurring transaction not found: $id'),
        );
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        DatabaseException('Failed to delete recurring transaction: $e'),
      );
    }
  }
}
