import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase v1', () {
    test('creates all 7 tables and expected indexes', () async {
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%'",
          )
          .get();

      final tableNames = tables.map((row) => row.read<String>('name')).toSet();
      expect(
        tableNames,
        containsAll([
          'accounts',
          'categories',
          'transactions',
          'attachments',
          'budgets',
          'savings_goals',
          'recurring_transactions',
        ]),
      );

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'idx_%'",
          )
          .get();

      final indexNames =
          indexes.map((row) => row.read<String>('name')).toSet();
      expect(
        indexNames,
        containsAll([
          'idx_tx_date',
          'idx_tx_account',
          'idx_tx_category',
          'idx_tx_type_date',
          'idx_budget_period',
          'idx_recurring_due',
          'idx_attach_tx',
        ]),
      );
    });

    test('enables foreign keys pragma', () async {
      final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.read<int>('foreign_keys'), 1);
    });
  });
}
