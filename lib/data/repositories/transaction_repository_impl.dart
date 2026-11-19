import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/app_database.dart';
import '../database/daos/transactions_dao.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  TransactionsDao get _dao => _db.transactionsDao;

  Attachment _toAttachmentEntity(AttachmentEntry entry) {
    return Attachment(
      id: entry.id,
      transactionId: entry.transactionId,
      filePath: entry.filePath,
      fileName: entry.fileName,
      mimeType: entry.mimeType,
      createdAt: fromUtcMillis(entry.createdAt),
    );
  }

  Transaction _toEntity(TransactionWithAttachmentsRow row) {
    final entry = row.entry;
    return Transaction(
      id: entry.id,
      type: TransactionType.values[entry.type],
      amount: entry.amount,
      date: fromUtcMillis(entry.date),
      accountId: entry.accountId,
      categoryId: entry.categoryId,
      toAccountId: entry.toAccountId,
      note: entry.note,
      recurringTransactionId: entry.recurringTransactionId,
      attachments: row.attachments.map(_toAttachmentEntity).toList(),
      createdAt: fromUtcMillis(entry.createdAt),
      updatedAt: fromUtcMillis(entry.updatedAt),
    );
  }

  List<AttachmentsCompanion> _toAttachmentCompanions(Transaction transaction) {
    return transaction.attachments
        .map(
          (a) => AttachmentsCompanion.insert(
            id: a.id,
            transactionId: transaction.id,
            filePath: a.filePath,
            fileName: a.fileName,
            mimeType: Value(a.mimeType),
            createdAt: a.createdAt.toUtcMillis,
          ),
        )
        .toList();
  }

  @override
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) {
    return _dao
        .watchTransactions(filter)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    try {
      final rows = await _dao.getTransactions(filter);
      return Success(rows.map(_toEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch transactions: $e'));
    }
  }

  @override
  Future<Result<Transaction>> getTransactionById(String id) async {
    try {
      final row = await _dao.getTransactionById(id);
      if (row == null) {
        return Failure(NotFoundException('Transaction not found: $id'));
      }
      return Success(_toEntity(row));
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch transaction: $e'));
    }
  }

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    try {
      await _db.transaction(() async {
        await _dao.insertTransaction(
          TransactionsCompanion.insert(
            id: transaction.id,
            type: transaction.type.index,
            amount: transaction.amount,
            date: transaction.date.toUtcMillis,
            accountId: transaction.accountId,
            categoryId: Value(transaction.categoryId),
            toAccountId: Value(transaction.toAccountId),
            note: Value(transaction.note),
            recurringTransactionId: Value(transaction.recurringTransactionId),
            createdAt: transaction.createdAt.toUtcMillis,
            updatedAt: transaction.updatedAt.toUtcMillis,
          ),
        );
        if (transaction.attachments.isNotEmpty) {
          await _dao.replaceAttachments(
            transaction.id,
            _toAttachmentCompanions(transaction),
          );
        }
      });

      return await getTransactionById(transaction.id);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to create transaction: $e'));
    }
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      var updated = false;
      await _db.transaction(() async {
        updated = await _dao.updateTransactionEntry(
          TransactionsCompanion(
            id: Value(transaction.id),
            type: Value(transaction.type.index),
            amount: Value(transaction.amount),
            date: Value(transaction.date.toUtcMillis),
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            toAccountId: Value(transaction.toAccountId),
            note: Value(transaction.note),
            updatedAt: Value(transaction.updatedAt.toUtcMillis),
          ),
        );
        if (updated) {
          await _dao.replaceAttachments(
            transaction.id,
            _toAttachmentCompanions(transaction),
          );
        }
      });

      if (!updated) {
        return Failure(
          NotFoundException('Transaction not found: ${transaction.id}'),
        );
      }
      return await getTransactionById(transaction.id);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to update transaction: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      final deleted = await _db.transaction(() => _dao.deleteTransactionById(id));
      if (deleted == 0) {
        return Failure(NotFoundException('Transaction not found: $id'));
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to delete transaction: $e'));
    }
  }

  @override
  Future<Result<List<Attachment>>> getAttachmentsForTransaction(
    String transactionId,
  ) async {
    try {
      final entries = await _dao.getAttachmentsForTransaction(transactionId);
      return Success(entries.map(_toAttachmentEntity).toList());
    } on Exception catch (e) {
      return Failure(DatabaseException('Failed to fetch attachments: $e'));
    }
  }
}
