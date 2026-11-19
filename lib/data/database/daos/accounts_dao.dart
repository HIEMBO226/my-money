import 'package:drift/drift.dart';

import '../../../domain/enums/transaction_type.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'accounts_dao.g.dart';

class AccountWithBalanceRow {
  const AccountWithBalanceRow({
    required this.entry,
    required this.balance,
  });

  final AccountEntry entry;
  final int balance;
}

@DriftAccessor(tables: [Accounts, Transactions])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  static const String _accountsWithBalanceSql = '''
    SELECT
      a.id,
      a.name,
      a.type,
      a.icon_code_point,
      a.color_value,
      a.sort_order,
      a.created_at,
      a.updated_at,
      COALESCE(SUM(
        CASE
          WHEN t.type = ?1 AND t.account_id = a.id THEN t.amount
          WHEN t.type = ?2 AND t.account_id = a.id THEN -t.amount
          WHEN t.type = ?3 AND t.account_id = a.id THEN -t.amount
          WHEN t.type = ?3 AND t.to_account_id = a.id THEN t.amount
          ELSE 0
        END
      ), 0) AS balance
    FROM accounts a
    LEFT JOIN transactions t
      ON t.account_id = a.id OR t.to_account_id = a.id
    GROUP BY a.id
    ORDER BY a.sort_order ASC, a.created_at ASC
  ''';

  static const String _accountWithBalanceByIdSql = '''
    SELECT
      a.id,
      a.name,
      a.type,
      a.icon_code_point,
      a.color_value,
      a.sort_order,
      a.created_at,
      a.updated_at,
      COALESCE(SUM(
        CASE
          WHEN t.type = ?1 AND t.account_id = a.id THEN t.amount
          WHEN t.type = ?2 AND t.account_id = a.id THEN -t.amount
          WHEN t.type = ?3 AND t.account_id = a.id THEN -t.amount
          WHEN t.type = ?3 AND t.to_account_id = a.id THEN t.amount
          ELSE 0
        END
      ), 0) AS balance
    FROM accounts a
    LEFT JOIN transactions t
      ON t.account_id = a.id OR t.to_account_id = a.id
    WHERE a.id = ?4
    GROUP BY a.id
  ''';

  List<Variable<Object>> get _typeVars => [
        Variable.withInt(TransactionType.income.index),
        Variable.withInt(TransactionType.expense.index),
        Variable.withInt(TransactionType.transfer.index),
      ];

  AccountWithBalanceRow _mapRow(QueryRow row) {
    return AccountWithBalanceRow(
      entry: AccountEntry(
        id: row.read<String>('id'),
        name: row.read<String>('name'),
        type: row.read<int>('type'),
        iconCodePoint: row.read<int>('icon_code_point'),
        colorValue: row.read<int>('color_value'),
        sortOrder: row.read<int>('sort_order'),
        createdAt: row.read<int>('created_at'),
        updatedAt: row.read<int>('updated_at'),
      ),
      balance: row.read<int>('balance'),
    );
  }

  Stream<List<AccountWithBalanceRow>> watchAccountsWithBalance() {
    return customSelect(
      _accountsWithBalanceSql,
      variables: _typeVars,
      readsFrom: {accounts, transactions},
    ).watch().map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<AccountWithBalanceRow>> getAccountsWithBalance() async {
    final rows = await customSelect(
      _accountsWithBalanceSql,
      variables: _typeVars,
      readsFrom: {accounts, transactions},
    ).get();
    return rows.map(_mapRow).toList();
  }

  Future<AccountWithBalanceRow?> getAccountWithBalanceById(String id) async {
    final rows = await customSelect(
      _accountWithBalanceByIdSql,
      variables: [..._typeVars, Variable.withString(id)],
      readsFrom: {accounts, transactions},
    ).get();
    if (rows.isEmpty) return null;
    return _mapRow(rows.first);
  }

  Future<void> insertAccount(AccountsCompanion entry) async {
    await into(accounts).insert(entry);
  }

  Future<bool> updateAccountEntry(AccountsCompanion entry) async {
    final affected = await (update(accounts)
          ..where((tbl) => tbl.id.equals(entry.id.value)))
        .write(entry);
    return affected > 0;
  }

  Future<int> countTransactionsForAccount(String accountId) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS cnt FROM transactions '
      'WHERE account_id = ?1 OR to_account_id = ?1',
      variables: [Variable.withString(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return row.read<int>('cnt');
  }

  Future<int> deleteAccountById(String id) {
    return (delete(accounts)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> insertTransactionEntry(TransactionsCompanion entry) async {
    await into(transactions).insert(entry);
  }
}
