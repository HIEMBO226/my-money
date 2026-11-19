import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/db_constants.dart';
import 'daos/accounts_dao.dart';
import 'daos/budgets_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/recurring_transactions_dao.dart';
import 'daos/savings_goals_dao.dart';
import 'daos/transactions_dao.dart';
import 'tables/accounts_table.dart';
import 'tables/attachments_table.dart';
import 'tables/budgets_table.dart';
import 'tables/categories_table.dart';
import 'tables/recurring_transactions_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Attachments,
    Budgets,
    SavingsGoals,
    RecurringTransactions,
  ],
  daos: [
    AccountsDao,
    BudgetsDao,
    CategoriesDao,
    RecurringTransactionsDao,
    SavingsGoalsDao,
    TransactionsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.defaults() {
    return AppDatabase(
      driftDatabase(
        name: DbConstants.databaseName,
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      ),
    );
  }

  @override
  int get schemaVersion => DbConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions (date DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_account ON transactions (account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_category ON transactions (category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_type_date ON transactions (type, date)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_budget_period '
      'ON budgets (year, month, category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recurring_due '
      'ON recurring_transactions (is_active, next_due_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attach_tx '
      'ON attachments (transaction_id)',
    );
  }
}
