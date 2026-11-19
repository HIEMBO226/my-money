import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/domain/entities/account.dart';
import 'package:my_money/domain/entities/category.dart';
import 'package:my_money/domain/entities/transaction.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/domain/use_cases/dashboard/get_category_breakdown.dart';
import 'package:my_money/domain/use_cases/dashboard/get_dashboard_summary.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 12);

  final categories = [
    Category(
      id: 'cat-food',
      type: TransactionType.expense,
      name: 'Alimentation',
      iconCodePoint: 0xe532,
      colorValue: 0xFFFF9800,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'cat-transport',
      type: TransactionType.expense,
      name: 'Transport',
      iconCodePoint: 0xe1d7,
      colorValue: 0xFF2196F3,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'cat-salary',
      type: TransactionType.income,
      name: 'Salaire',
      iconCodePoint: 0xe6f2,
      colorValue: 0xFF4CAF50,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final accounts = [
    Account(
      id: 'acc-1',
      name: 'Banque',
      type: AccountType.bank,
      iconCodePoint: 0xe069,
      colorValue: 0xFF2196F3,
      balance: 200000,
      createdAt: now,
      updatedAt: now,
    ),
    Account(
      id: 'acc-2',
      name: 'Espèces',
      type: AccountType.cash,
      iconCodePoint: 0xe227,
      colorValue: 0xFF4CAF50,
      balance: 50000,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final transactions = [
    Transaction(
      id: 'tx-1',
      type: TransactionType.income,
      amount: 300000,
      date: DateTime.utc(2026, 11, 1, 12),
      accountId: 'acc-1',
      categoryId: 'cat-salary',
      createdAt: now,
      updatedAt: now,
    ),
    Transaction(
      id: 'tx-2',
      type: TransactionType.expense,
      amount: 60000,
      date: DateTime.utc(2026, 11, 5, 12),
      accountId: 'acc-1',
      categoryId: 'cat-food',
      createdAt: now,
      updatedAt: now,
    ),
    Transaction(
      id: 'tx-3',
      type: TransactionType.expense,
      amount: 40000,
      date: DateTime.utc(2026, 11, 10, 12),
      accountId: 'acc-2',
      categoryId: 'cat-transport',
      createdAt: now,
      updatedAt: now,
    ),
    // Transfer should NOT count toward monthly income or expense
    Transaction(
      id: 'tx-transfer',
      type: TransactionType.transfer,
      amount: 50000,
      date: DateTime.utc(2026, 11, 12, 12),
      accountId: 'acc-1',
      toAccountId: 'acc-2',
      createdAt: now,
      updatedAt: now,
    ),
    // Previous month expense
    Transaction(
      id: 'tx-oct',
      type: TransactionType.expense,
      amount: 25000,
      date: DateTime.utc(2026, 10, 15, 12),
      accountId: 'acc-1',
      categoryId: 'cat-food',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  group('GetDashboardSummary', () {
    test('computes balance, monthly totals, breakdown and 6-month trend', () {
      const useCase = GetDashboardSummary();
      final summary = useCase(
        accounts: accounts,
        transactions: transactions,
        categories: categories,
        referenceMonth: DateTime(2026, 11),
      );

      expect(summary.totalBalance, 250000);
      expect(summary.monthlyIncome, 300000);
      expect(summary.monthlyExpense, 100000);
      expect(summary.monthlyNet, 200000);

      // Category breakdown sorted descending: Food 60%, Transport 40%
      expect(summary.categoryBreakdown.length, 2);
      expect(summary.categoryBreakdown[0].categoryId, 'cat-food');
      expect(summary.categoryBreakdown[0].percentage, closeTo(60.0, 0.01));
      expect(summary.categoryBreakdown[1].categoryId, 'cat-transport');
      expect(summary.categoryBreakdown[1].percentage, closeTo(40.0, 0.01));

      // 6-month trend: June 2026 -> November 2026
      expect(summary.monthlyTrend.length, 6);
      expect(summary.monthlyTrend.first.month, 6);
      expect(summary.monthlyTrend[4].month, 10);
      expect(summary.monthlyTrend[4].expense, 25000);
      expect(summary.monthlyTrend[5].month, 11);
      expect(summary.monthlyTrend[5].income, 300000);
      expect(summary.monthlyTrend[5].expense, 100000);
    });

    test('handles year boundaries correctly in trend computation', () {
      const useCase = GetDashboardSummary();
      final trend = useCase.computeMonthlyTrend(
        transactions: const [],
        endMonth: DateTime(2026, 2),
      );

      expect(trend.length, 6);
      expect(trend.first.year, 2025);
      expect(trend.first.month, 9);
      expect(trend.last.year, 2026);
      expect(trend.last.month, 2);
    });
  });

  group('GetCategoryBreakdown', () {
    test('returns empty list for transfer type', () {
      const useCase = GetCategoryBreakdown();
      final result = useCase(
        transactions: transactions,
        categoryMap: {for (final c in categories) c.id: c},
        type: TransactionType.transfer,
      );
      expect(result, isEmpty);
    });
  });
}
