import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../domain/entities/dashboard_summary.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../categories/providers/category_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

enum StatisticsPeriod {
  thisMonth,
  threeMonths,
  sixMonths,
  thisYear;

  int get monthCount {
    final now = DateTime.now();
    return switch (this) {
      StatisticsPeriod.thisMonth => 1,
      StatisticsPeriod.threeMonths => 3,
      StatisticsPeriod.sixMonths => 6,
      StatisticsPeriod.thisYear => now.month,
    };
  }

  ({DateTime start, DateTime end}) dateRange([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    return switch (this) {
      StatisticsPeriod.thisMonth => (
          start: now.startOfMonth,
          end: now.endOfMonth,
        ),
      StatisticsPeriod.threeMonths => (
          start: DateTime(now.year, now.month - 2).startOfMonth,
          end: now.endOfMonth,
        ),
      StatisticsPeriod.sixMonths => (
          start: DateTime(now.year, now.month - 5).startOfMonth,
          end: now.endOfMonth,
        ),
      StatisticsPeriod.thisYear => (
          start: DateTime(now.year).startOfMonth,
          end: now.endOfMonth,
        ),
    };
  }
}

class StatisticsData {
  const StatisticsData({
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.monthlySeries,
  });

  final int totalIncome;
  final int totalExpense;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<MonthlyTrendPoint> monthlySeries;

  int get netBalance => totalIncome - totalExpense;

  double get savingsRate =>
      totalIncome <= 0 ? 0.0 : ((totalIncome - totalExpense) / totalIncome) * 100;
}

class StatisticsPeriodNotifier extends Notifier<StatisticsPeriod> {
  @override
  StatisticsPeriod build() => StatisticsPeriod.sixMonths;

  void select(StatisticsPeriod period) => state = period;
}

class StatisticsTypeNotifier extends Notifier<TransactionType> {
  @override
  TransactionType build() => TransactionType.expense;

  void select(TransactionType type) {
    if (type != TransactionType.transfer) {
      state = type;
    }
  }
}

final statisticsPeriodProvider =
    NotifierProvider<StatisticsPeriodNotifier, StatisticsPeriod>(
  StatisticsPeriodNotifier.new,
);

final statisticsTypeProvider =
    NotifierProvider<StatisticsTypeNotifier, TransactionType>(
  StatisticsTypeNotifier.new,
);

final statisticsTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((ref) {
  final period = ref.watch(statisticsPeriodProvider);
  final range = period.dateRange();

  return ref.watch(getTransactionsUseCaseProvider).watch(
        filter: TransactionFilter(
          startDate: range.start,
          endDate: range.end,
          limit: 10000,
        ),
      );
});

final statisticsDataProvider = Provider<AsyncValue<StatisticsData>>((ref) {
  final period = ref.watch(statisticsPeriodProvider);
  final selectedType = ref.watch(statisticsTypeProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider(null));
  final transactionsAsync = ref.watch(statisticsTransactionsStreamProvider);
  final getBreakdown = ref.watch(getCategoryBreakdownUseCaseProvider);
  final getSummary = ref.watch(getDashboardSummaryUseCaseProvider);

  if (categoriesAsync.hasError) {
    return AsyncValue.error(
      categoriesAsync.error!,
      categoriesAsync.stackTrace!,
    );
  }
  if (transactionsAsync.hasError) {
    return AsyncValue.error(
      transactionsAsync.error!,
      transactionsAsync.stackTrace!,
    );
  }
  if (!categoriesAsync.hasValue || !transactionsAsync.hasValue) {
    return const AsyncValue.loading();
  }

  final transactions = transactionsAsync.value!;
  final categories = categoriesAsync.value!;
  final categoryMap = {for (final c in categories) c.id: c};
  final range = period.dateRange();

  var totalIncome = 0;
  var totalExpense = 0;
  for (final tx in transactions) {
    if (tx.type == TransactionType.income) {
      totalIncome += tx.amount;
    } else if (tx.type == TransactionType.expense) {
      totalExpense += tx.amount;
    }
  }

  final breakdown = getBreakdown(
    transactions: transactions,
    categoryMap: categoryMap,
    type: selectedType,
    startDate: range.start,
    endDate: range.end,
  );

  final series = getSummary.computeMonthlyTrend(
    transactions: transactions,
    endMonth: DateTime.now(),
    months: period.monthCount,
  );

  return AsyncValue.data(
    StatisticsData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categoryBreakdown: breakdown,
      monthlySeries: series,
    ),
  );
});
