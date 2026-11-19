import 'package:drift/drift.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/attachments_table.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

class TransactionWithAttachmentsRow {
  const TransactionWithAttachmentsRow({
    required this.entry,
    required this.attachments,
  });

  final TransactionEntry entry;
  final List<AttachmentEntry> attachments;
}

@DriftAccessor(tables: [Transactions, Attachments, Categories, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  ({String sql, List<Variable<Object>> variables}) _buildFilterQuery(
    TransactionFilter filter,
  ) {
    final conditions = <String>[];
    final variables = <Variable<Object>>[];

    void addCondition(String clause, List<Variable<Object>> vars) {
      conditions.add(clause);
      variables.addAll(vars);
    }

    if (filter.type != null) {
      addCondition('t.type = ?', [Variable.withInt(filter.type!.index)]);
    }
    if (filter.accountId != null) {
      addCondition(
        '(t.account_id = ? OR t.to_account_id = ?)',
        [
          Variable.withString(filter.accountId!),
          Variable.withString(filter.accountId!),
        ],
      );
    }
    if (filter.categoryId != null) {
      addCondition(
        't.category_id = ?',
        [Variable.withString(filter.categoryId!)],
      );
    }
    if (filter.startDate != null) {
      addCondition(
        't.date >= ?',
        [Variable.withInt(filter.startDate!.toUtcMillis)],
      );
    }
    if (filter.endDate != null) {
      addCondition(
        't.date <= ?',
        [Variable.withInt(filter.endDate!.toUtcMillis)],
      );
    }
    if (filter.minAmount != null) {
      addCondition('t.amount >= ?', [Variable.withInt(filter.minAmount!)]);
    }
    if (filter.maxAmount != null) {
      addCondition('t.amount <= ?', [Variable.withInt(filter.maxAmount!)]);
    }

    final trimmedQuery = filter.searchQuery?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      final pattern = '%${trimmedQuery.toLowerCase()}%';
      addCondition(
        '(LOWER(COALESCE(t.note, \'\')) LIKE ? '
        'OR LOWER(COALESCE(c.name, \'\')) LIKE ? '
        'OR LOWER(COALESCE(a.name, \'\')) LIKE ?)',
        [
          Variable.withString(pattern),
          Variable.withString(pattern),
          Variable.withString(pattern),
        ],
      );
    }

    final whereClause =
        conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    variables.add(Variable.withInt(filter.limit));
    variables.add(Variable.withInt(filter.offset));

    final sql = '''
      SELECT
        t.id,
        t.type,
        t.amount,
        t.date,
        t.account_id,
        t.category_id,
        t.to_account_id,
        t.note,
        t.recurring_transaction_id,
        t.created_at,
        t.updated_at
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      LEFT JOIN accounts a ON a.id = t.account_id
      $whereClause
      ORDER BY t.date DESC, t.created_at DESC
      LIMIT ? OFFSET ?
    ''';

    return (sql: sql, variables: variables);
  }

  TransactionEntry _mapTransactionRow(QueryRow row) {
    return TransactionEntry(
      id: row.read<String>('id'),
      type: row.read<int>('type'),
      amount: row.read<int>('amount'),
      date: row.read<int>('date'),
      accountId: row.read<String>('account_id'),
      categoryId: row.readNullable<String>('category_id'),
      toAccountId: row.readNullable<String>('to_account_id'),
      note: row.readNullable<String>('note'),
      recurringTransactionId:
          row.readNullable<String>('recurring_transaction_id'),
      createdAt: row.read<int>('created_at'),
      updatedAt: row.read<int>('updated_at'),
    );
  }

  Future<List<TransactionWithAttachmentsRow>> _attachFiles(
    List<TransactionEntry> entries,
  ) async {
    if (entries.isEmpty) return const [];
    final ids = entries.map((e) => e.id).toList();
    final attachmentRows = await (select(attachments)
          ..where((t) => t.transactionId.isIn(ids)))
        .get();

    final grouped = <String, List<AttachmentEntry>>{};
    for (final att in attachmentRows) {
      grouped.putIfAbsent(att.transactionId, () => []).add(att);
    }

    return entries
        .map(
          (entry) => TransactionWithAttachmentsRow(
            entry: entry,
            attachments: grouped[entry.id] ?? const [],
          ),
        )
        .toList();
  }

  Stream<List<TransactionWithAttachmentsRow>> watchTransactions(
    TransactionFilter filter,
  ) {
    final built = _buildFilterQuery(filter);
    return customSelect(
      built.sql,
      variables: built.variables,
      readsFrom: {transactions, attachments, categories, accounts},
    ).watch().asyncMap((rows) async {
      final entries = rows.map(_mapTransactionRow).toList();
      return _attachFiles(entries);
    });
  }

  Future<List<TransactionWithAttachmentsRow>> getTransactions(
    TransactionFilter filter,
  ) async {
    final built = _buildFilterQuery(filter);
    final rows = await customSelect(
      built.sql,
      variables: built.variables,
      readsFrom: {transactions, attachments, categories, accounts},
    ).get();
    final entries = rows.map(_mapTransactionRow).toList();
    return _attachFiles(entries);
  }

  Future<TransactionWithAttachmentsRow?> getTransactionById(String id) async {
    final entry = await (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (entry == null) return null;
    final files = await getAttachmentsForTransaction(id);
    return TransactionWithAttachmentsRow(entry: entry, attachments: files);
  }

  Future<List<AttachmentEntry>> getAttachmentsForTransaction(
    String transactionId,
  ) {
    return (select(attachments)
          ..where((t) => t.transactionId.equals(transactionId)))
        .get();
  }

  Future<void> insertTransaction(TransactionsCompanion entry) async {
    await into(transactions).insert(entry);
  }

  Future<bool> updateTransactionEntry(TransactionsCompanion entry) async {
    final affected = await (update(transactions)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    return affected > 0;
  }

  Future<void> replaceAttachments(
    String transactionId,
    List<AttachmentsCompanion> newAttachments,
  ) async {
    await (delete(attachments)
          ..where((t) => t.transactionId.equals(transactionId)))
        .go();
    if (newAttachments.isNotEmpty) {
      await batch((b) {
        b.insertAll(attachments, newAttachments);
      });
    }
  }

  Future<int> deleteTransactionById(String id) async {
    await (delete(attachments)..where((t) => t.transactionId.equals(id))).go();
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
