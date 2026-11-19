import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../entities/app_settings.dart';
import '../../entities/transaction_filter.dart';
import '../../enums/currency.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/transaction_repository.dart';

class ExportCsv {
  const ExportCsv(
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository,
  );

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<Uint8List>> call({
    required AppSettings settings,
    TransactionFilter filter = const TransactionFilter(limit: 100000),
  }) async {
    try {
      final txResult =
          await _transactionRepository.getTransactions(filter: filter);
      if (txResult.isFailure) return Failure(txResult.exceptionOrNull!);

      final accResult = await _accountRepository.getAccounts();
      if (accResult.isFailure) return Failure(accResult.exceptionOrNull!);

      final catResult = await _categoryRepository.getCategories();
      if (catResult.isFailure) return Failure(catResult.exceptionOrNull!);

      final accounts = {for (final a in accResult.dataOrNull!) a.id: a.name};
      final categories = {for (final c in catResult.dataOrNull!) c.id: c.name};
      final currency = Currency.fromCode(settings.currencyCode);
      final dateFormat = DateFormat(settings.dateFormat.pattern);

      final rows = <List<dynamic>>[
        [
          'Date',
          'Type',
          'Category',
          'Account',
          'To Account',
          'Amount (${currency.code})',
          'Note',
        ],
      ];

      for (final tx in txResult.dataOrNull!) {
        final signedRaw =
            tx.type == TransactionType.expense ? -tx.amount : tx.amount;
        final amountDisplay = currency.decimalDigits == 0
            ? signedRaw.toString()
            : (signedRaw / currency.smallestUnitMultiplier)
                .toStringAsFixed(currency.decimalDigits);

        rows.add([
          dateFormat.format(tx.date.toLocal()),
          tx.type.name,
          tx.categoryId != null ? (categories[tx.categoryId] ?? '') : '',
          accounts[tx.accountId] ?? '',
          tx.toAccountId != null ? (accounts[tx.toAccountId] ?? '') : '',
          amountDisplay,
          tx.note ?? '',
        ]);
      }

      // Prepend UTF-8 BOM so Excel opens accented French characters properly.
      final csvContent = '\uFEFF${csv.encode(rows)}';
      return Success(Uint8List.fromList(utf8.encode(csvContent)));
    } on Exception catch (e) {
      return Failure(ExportException('Failed to export CSV: $e'));
    }
  }
}
