import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../domain/entities/dashboard_summary.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/use_cases/dashboard/get_category_breakdown.dart';
import '../../../domain/use_cases/dashboard/get_dashboard_summary.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

final getCategoryBreakdownUseCaseProvider =
    Provider<GetCategoryBreakdown>((ref) => const GetCategoryBreakdown());

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary(ref.watch(getCategoryBreakdownUseCaseProvider));
});

class DashboardMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void resetToCurrent() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }
}

final dashboardSelectedMonthProvider =
    NotifierProvider<DashboardMonthNotifier, DateTime>(
  DashboardMonthNotifier.new,
);

/// Watches all transactions covering the 6-month trend window ending on the selected month.
final dashboardTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((ref) {
  final selectedMonth = ref.watch(dashboardSelectedMonthProvider);
  final windowStart = DateTime(
    selectedMonth.year,
    selectedMonth.month - (AppConstants.trendMonths - 1),
  ).startOfMonth;
  final windowEnd = selectedMonth.endOfMonth;

  return ref.watch(getTransactionsUseCaseProvider).watch(
        filter: TransactionFilter(
          startDate: windowStart,
          endDate: windowEnd,
          limit: 5000,
        ),
      );
});

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final accountsAsync = ref.watch(accountsStreamProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider(null));
  final transactionsAsync = ref.watch(dashboardTransactionsStreamProvider);
  final selectedMonth = ref.watch(dashboardSelectedMonthProvider);
  final getSummary = ref.watch(getDashboardSummaryUseCaseProvider);

  if (accountsAsync.hasError) {
    return AsyncValue.error(accountsAsync.error!, accountsAsync.stackTrace!);
  }
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

  if (!accountsAsync.hasValue ||
      !categoriesAsync.hasValue ||
      !transactionsAsync.hasValue) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    getSummary(
      accounts: accountsAsync.value!,
      transactions: transactionsAsync.value!,
      categories: categoriesAsync.value!,
      referenceMonth: selectedMonth,
    ),
  );
});
