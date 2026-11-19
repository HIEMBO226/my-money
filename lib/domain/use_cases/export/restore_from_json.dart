import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../data/database/app_database.dart';

class RestoreSummary {
  const RestoreSummary({
    required this.accountsCount,
    required this.categoriesCount,
    required this.transactionsCount,
    required this.budgetsCount,
    required this.goalsCount,
    required this.recurringCount,
  });

  final int accountsCount;
  final int categoriesCount;
  final int transactionsCount;
  final int budgetsCount;
  final int goalsCount;
  final int recurringCount;
}

class RestoreFromJson {
  const RestoreFromJson(this._db);

  final AppDatabase _db;

  Future<Result<RestoreSummary>> call({
    required String encryptedBackupContent,
    required String password,
  }) async {
    try {
      final decrypted = CryptoUtils.decryptJson(
        encryptedBackupContent,
        password: password,
      );
      final data = jsonDecode(decrypted) as Map<String, dynamic>;

      final accountsList = (data['accounts'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final categoriesList = (data['categories'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final recurringList =
          (data['recurringTransactions'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
      final transactionsList =
          (data['transactions'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
      final budgetsList = (data['budgets'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final goalsList = (data['savingsGoals'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();

      await _db.transaction(() async {
        // Clear tables in reverse foreign-key order
        await _db.delete(_db.attachments).go();
        await _db.delete(_db.transactions).go();
        await _db.delete(_db.budgets).go();
        await _db.delete(_db.savingsGoals).go();
        await _db.delete(_db.recurringTransactions).go();
        await _db.delete(_db.categories).go();
        await _db.delete(_db.accounts).go();

        // Restore tables in foreign-key dependency order
        if (accountsList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.accounts,
              accountsList
                  .map(
                    (a) => AccountsCompanion.insert(
                      id: a['id'] as String,
                      name: a['name'] as String,
                      type: a['type'] as int,
                      iconCodePoint: a['iconCodePoint'] as int,
                      colorValue: a['colorValue'] as int,
                      sortOrder: Value((a['sortOrder'] as int?) ?? 0),
                      createdAt: a['createdAt'] as int,
                      updatedAt: a['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }

        if (categoriesList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.categories,
              categoriesList
                  .map(
                    (c) => CategoriesCompanion.insert(
                      id: c['id'] as String,
                      type: c['type'] as int,
                      name: c['name'] as String,
                      iconCodePoint: c['iconCodePoint'] as int,
                      colorValue: c['colorValue'] as int,
                      isDefault: Value((c['isDefault'] as bool?) ?? false),
                      sortOrder: Value((c['sortOrder'] as int?) ?? 0),
                      createdAt: c['createdAt'] as int,
                      updatedAt: c['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }

        if (recurringList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.recurringTransactions,
              recurringList
                  .map(
                    (r) => RecurringTransactionsCompanion.insert(
                      id: r['id'] as String,
                      type: r['type'] as int,
                      amount: r['amount'] as int,
                      accountId: r['accountId'] as String,
                      categoryId: Value(r['categoryId'] as String?),
                      toAccountId: Value(r['toAccountId'] as String?),
                      note: Value(r['note'] as String?),
                      frequency: r['frequency'] as int,
                      nextDueDate: r['nextDueDate'] as int,
                      endDate: Value(r['endDate'] as int?),
                      isActive: Value((r['isActive'] as bool?) ?? true),
                      createdAt: r['createdAt'] as int,
                      updatedAt: r['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }

        if (transactionsList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.transactions,
              transactionsList
                  .map(
                    (t) => TransactionsCompanion.insert(
                      id: t['id'] as String,
                      type: t['type'] as int,
                      amount: t['amount'] as int,
                      date: t['date'] as int,
                      accountId: t['accountId'] as String,
                      categoryId: Value(t['categoryId'] as String?),
                      toAccountId: Value(t['toAccountId'] as String?),
                      note: Value(t['note'] as String?),
                      recurringTransactionId:
                          Value(t['recurringTransactionId'] as String?),
                      createdAt: t['createdAt'] as int,
                      updatedAt: t['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }

        if (budgetsList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.budgets,
              budgetsList
                  .map(
                    (bItem) => BudgetsCompanion.insert(
                      id: bItem['id'] as String,
                      categoryId: bItem['categoryId'] as String,
                      amountLimit: bItem['amountLimit'] as int,
                      year: bItem['year'] as int,
                      month: bItem['month'] as int,
                      createdAt: bItem['createdAt'] as int,
                      updatedAt: bItem['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }

        if (goalsList.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.savingsGoals,
              goalsList
                  .map(
                    (g) => SavingsGoalsCompanion.insert(
                      id: g['id'] as String,
                      name: g['name'] as String,
                      targetAmount: g['targetAmount'] as int,
                      currentAmount: Value((g['currentAmount'] as int?) ?? 0),
                      deadline: Value(g['deadline'] as int?),
                      accountId: Value(g['accountId'] as String?),
                      colorValue: g['colorValue'] as int,
                      iconCodePoint: g['iconCodePoint'] as int,
                      createdAt: g['createdAt'] as int,
                      updatedAt: g['updatedAt'] as int,
                    ),
                  )
                  .toList(),
            );
          });
        }
      });

      return Success(
        RestoreSummary(
          accountsCount: accountsList.length,
          categoriesCount: categoriesList.length,
          transactionsCount: transactionsList.length,
          budgetsCount: budgetsList.length,
          goalsCount: goalsList.length,
          recurringCount: recurringList.length,
        ),
      );
    } on AppException catch (e) {
      return Failure(e);
    } on Exception catch (e) {
      return Failure(ExportException('Failed to restore backup: $e'));
    }
  }
}
