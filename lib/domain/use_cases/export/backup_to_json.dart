import 'dart:convert';
import 'dart:typed_data';

import '../../../core/constants/db_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../data/database/app_database.dart';

class BackupToJson {
  const BackupToJson(this._db);

  final AppDatabase _db;

  Future<Result<Uint8List>> call({required String password}) async {
    try {
      final accounts = await _db.select(_db.accounts).get();
      final categories = await _db.select(_db.categories).get();
      final recurring = await _db.select(_db.recurringTransactions).get();
      final transactions = await _db.select(_db.transactions).get();
      final budgets = await _db.select(_db.budgets).get();
      final goals = await _db.select(_db.savingsGoals).get();

      final payload = jsonEncode({
        'schemaVersion': DbConstants.databaseVersion,
        'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
        'accounts': accounts
            .map(
              (a) => {
                'id': a.id,
                'name': a.name,
                'type': a.type,
                'iconCodePoint': a.iconCodePoint,
                'colorValue': a.colorValue,
                'sortOrder': a.sortOrder,
                'createdAt': a.createdAt,
                'updatedAt': a.updatedAt,
              },
            )
            .toList(),
        'categories': categories
            .map(
              (c) => {
                'id': c.id,
                'type': c.type,
                'name': c.name,
                'iconCodePoint': c.iconCodePoint,
                'colorValue': c.colorValue,
                'isDefault': c.isDefault,
                'sortOrder': c.sortOrder,
                'createdAt': c.createdAt,
                'updatedAt': c.updatedAt,
              },
            )
            .toList(),
        'recurringTransactions': recurring
            .map(
              (r) => {
                'id': r.id,
                'type': r.type,
                'amount': r.amount,
                'accountId': r.accountId,
                'categoryId': r.categoryId,
                'toAccountId': r.toAccountId,
                'note': r.note,
                'frequency': r.frequency,
                'nextDueDate': r.nextDueDate,
                'endDate': r.endDate,
                'isActive': r.isActive,
                'createdAt': r.createdAt,
                'updatedAt': r.updatedAt,
              },
            )
            .toList(),
        'transactions': transactions
            .map(
              (t) => {
                'id': t.id,
                'type': t.type,
                'amount': t.amount,
                'date': t.date,
                'accountId': t.accountId,
                'categoryId': t.categoryId,
                'toAccountId': t.toAccountId,
                'note': t.note,
                'recurringTransactionId': t.recurringTransactionId,
                'createdAt': t.createdAt,
                'updatedAt': t.updatedAt,
              },
            )
            .toList(),
        'budgets': budgets
            .map(
              (b) => {
                'id': b.id,
                'categoryId': b.categoryId,
                'amountLimit': b.amountLimit,
                'year': b.year,
                'month': b.month,
                'createdAt': b.createdAt,
                'updatedAt': b.updatedAt,
              },
            )
            .toList(),
        'savingsGoals': goals
            .map(
              (g) => {
                'id': g.id,
                'name': g.name,
                'targetAmount': g.targetAmount,
                'currentAmount': g.currentAmount,
                'deadline': g.deadline,
                'accountId': g.accountId,
                'colorValue': g.colorValue,
                'iconCodePoint': g.iconCodePoint,
                'createdAt': g.createdAt,
                'updatedAt': g.updatedAt,
              },
            )
            .toList(),
      });

      final encryptedEnvelope = CryptoUtils.encryptJson(
        payload,
        password: password,
      );
      return Success(Uint8List.fromList(utf8.encode(encryptedEnvelope)));
    } on AppException catch (e) {
      return Failure(e);
    } on Exception catch (e) {
      return Failure(ExportException('Failed to create backup: $e'));
    }
  }
}
