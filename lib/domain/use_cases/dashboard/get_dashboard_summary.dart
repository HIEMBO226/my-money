import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../entities/account.dart';
import '../../entities/category.dart';
import '../../entities/dashboard_summary.dart';
import '../../entities/transaction.dart';
import '../../enums/transaction_type.dart';
import 'get_category_breakdown.dart';

class GetDashboardSummary {
  const GetDashboardSummary([
    this._categoryBreakdown = const GetCategoryBreakdown(),
  ]);

  final GetCategoryBreakdown _categoryBreakdown;

  DashboardSummary call({
    required List<Account> accounts,
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime referenceMonth,
    int trendMonths = AppConstants.trendMonths,
    int recentLimit = 5,
    String uncategorizedLabel = 'Sans catégorie',
  }) {
    final totalBalance =
        accounts.fold<int>(0, (sum, account) => sum + account.balance);

    final monthStart = referenceMonth.startOfMonth;
    final monthEnd = referenceMonth.endOfMonth;

    var monthlyIncome = 0;
    var monthlyExpense = 0;

    for (final tx in transactions) {
      final localDate = tx.date.toLocal();
      if (localDate.isBefore(monthStart) || localDate.isAfter(monthEnd)) {
        continue;
      }
      if (tx.type == TransactionType.income) {
        monthlyIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        monthlyExpense += tx.amount;
      }
    }

    final categoryMap = {for (final c in categories) c.id: c};
    final breakdown = _categoryBreakdown(
      transactions: transactions,
      categoryMap: categoryMap,
      type: TransactionType.expense,
      startDate: monthStart,
      endDate: monthEnd,
      uncategorizedLabel: uncategorizedLabel,
    );

    final trend = computeMonthlyTrend(
      transactions: transactions,
      endMonth: referenceMonth,
      months: trendMonths,
    );

    final sortedRecent = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return DashboardSummary(
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      categoryBreakdown: breakdown,
      monthlyTrend: trend,
      recentTransactions: sortedRecent.take(recentLimit).toList(),
    );
  }

  List<MonthlyTrendPoint> computeMonthlyTrend({
    required List<Transaction> transactions,
    required DateTime endMonth,
    int months = AppConstants.trendMonths,
  }) {
    final buckets = <(int, int), ({int income, int expense})>{};
    final orderedKeys = <(int, int)>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(endMonth.year, endMonth.month - i);
      final key = (monthDate.year, monthDate.month);
      orderedKeys.add(key);
      buckets[key] = (income: 0, expense: 0);
    }

    for (final tx in transactions) {
      if (tx.type == TransactionType.transfer) continue;
      final local = tx.date.toLocal();
      final key = (local.year, local.month);
      final current = buckets[key];
      if (current == null) continue;

      if (tx.type == TransactionType.income) {
        buckets[key] = (
          income: current.income + tx.amount,
          expense: current.expense,
        );
      } else if (tx.type == TransactionType.expense) {
        buckets[key] = (
          income: current.income,
          expense: current.expense + tx.amount,
        );
      }
    }

    return orderedKeys.map((key) {
      final totals = buckets[key]!;
      return MonthlyTrendPoint(
        year: key.$1,
        month: key.$2,
        income: totals.income,
        expense: totals.expense,
      );
    }).toList();
  }
}
