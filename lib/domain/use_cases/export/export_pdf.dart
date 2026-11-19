import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../entities/app_settings.dart';
import '../../entities/transaction_filter.dart';
import '../../enums/transaction_type.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/transaction_repository.dart';

class ExportPdf {
  const ExportPdf(
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository,
  );

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  static const String _regularFontAsset = 'assets/fonts/NotoSans-Regular.ttf';
  static const String _boldFontAsset = 'assets/fonts/NotoSans-Bold.ttf';

  Future<pw.ThemeData> _loadUnicodeTheme() async {
    final regularData = await rootBundle.load(_regularFontAsset);
    final boldData = await rootBundle.load(_boldFontAsset);
    final regularFont = pw.Font.ttf(regularData);
    final boldFont = pw.Font.ttf(boldData);
    return pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );
  }

  /// Normalizes narrow no-break spaces to standard spaces for crisp PDF layout.
  String _formatAmount(int amount, String currencyCode) {
    return CurrencyFormatter.format(amount, currencyCode: currencyCode)
        .replaceAll('\u202F', ' ')
        .replaceAll('\u00A0', ' ');
  }

  Future<Result<Uint8List>> call({
    required AppSettings settings,
    TransactionFilter filter = const TransactionFilter(limit: 5000),
  }) async {
    try {
      final txResult =
          await _transactionRepository.getTransactions(filter: filter);
      if (txResult.isFailure) return Failure(txResult.exceptionOrNull!);

      final accResult = await _accountRepository.getAccounts();
      if (accResult.isFailure) return Failure(accResult.exceptionOrNull!);

      final catResult = await _categoryRepository.getCategories();
      if (catResult.isFailure) return Failure(catResult.exceptionOrNull!);

      final theme = await _loadUnicodeTheme();

      final accounts = accResult.dataOrNull!;
      final accountNames = {for (final a in accounts) a.id: a.name};
      final categoryNames = {
        for (final c in catResult.dataOrNull!) c.id: c.name,
      };
      final transactions = txResult.dataOrNull!;
      final currencyCode = settings.currencyCode;
      final dateFormat = DateFormat(settings.dateFormat.pattern);

      final totalBalance =
          accounts.fold<int>(0, (sum, acc) => sum + acc.balance);
      var totalIncome = 0;
      var totalExpense = 0;
      for (final tx in transactions) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          totalExpense += tx.amount;
        }
      }

      final doc = pw.Document(
        title: '${AppConstants.appName} — Rapport financier',
        author: AppConstants.appName,
        theme: theme,
      );

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  AppConstants.appName,
                  style: const pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  dateFormat.format(DateTime.now()),
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                _summaryBox(
                  'Solde total',
                  _formatAmount(totalBalance, currencyCode),
                  PdfColors.blue50,
                ),
                pw.SizedBox(width: 8),
                _summaryBox(
                  'Revenus',
                  '+${_formatAmount(totalIncome, currencyCode)}',
                  PdfColors.green50,
                ),
                pw.SizedBox(width: 8),
                _summaryBox(
                  'Dépenses',
                  '-${_formatAmount(totalExpense, currencyCode)}',
                  PdfColors.red50,
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            if (accounts.isNotEmpty) ...[
              pw.Text(
                'Comptes',
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: const pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                headers: const ['Compte', 'Type', 'Solde'],
                data: accounts
                    .map(
                      (a) => [
                        a.name,
                        a.type.name,
                        _formatAmount(a.balance, currencyCode),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Text(
              'Transactions (${transactions.length})',
              style: const pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (transactions.isEmpty)
              pw.Text(
                'Aucune transaction.',
                style: const pw.TextStyle(color: PdfColors.grey600),
              )
            else
              pw.TableHelper.fromTextArray(
                headerStyle: const pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                headers: const [
                  'Date',
                  'Type',
                  'Catégorie',
                  'Compte',
                  'Montant',
                  'Note',
                ],
                data: transactions.map((tx) {
                  final prefix = switch (tx.type) {
                    TransactionType.income => '+',
                    TransactionType.expense => '-',
                    TransactionType.transfer => '',
                  };
                  return [
                    dateFormat.format(tx.date.toLocal()),
                    tx.type.name,
                    tx.categoryId != null
                        ? (categoryNames[tx.categoryId] ?? '-')
                        : '-',
                    accountNames[tx.accountId] ?? '-',
                    '$prefix${_formatAmount(tx.amount, currencyCode)}',
                    tx.note ?? '',
                  ];
                }).toList(),
              ),
          ],
        ),
      );

      final bytes = await doc.save();
      return Success(bytes);
    } on Exception catch (e) {
      return Failure(ExportException('Failed to export PDF: $e'));
    }
  }

  pw.Widget _summaryBox(String label, String value, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
