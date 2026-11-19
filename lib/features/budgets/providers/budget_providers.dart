import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/budget_repository_impl.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../domain/repositories/budget_repository.dart';
import '../../../domain/use_cases/budgets/check_budget_alerts.dart';
import '../../../domain/use_cases/budgets/delete_budget.dart';
import '../../../domain/use_cases/budgets/get_budgets.dart';
import '../../../domain/use_cases/budgets/set_budget.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetRepositoryImpl(db);
});

final getBudgetsUseCaseProvider = Provider<GetBudgets>((ref) {
  return GetBudgets(ref.watch(budgetRepositoryProvider));
});

final setBudgetUseCaseProvider = Provider<SetBudget>((ref) {
  return SetBudget(ref.watch(budgetRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudget>((ref) {
  return DeleteBudget(ref.watch(budgetRepositoryProvider));
});

final checkBudgetAlertsUseCaseProvider = Provider<CheckBudgetAlerts>((ref) {
  return CheckBudgetAlerts(
    ref.watch(budgetRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

class BudgetMonthNotifier extends Notifier<DateTime> {
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
}

final budgetSelectedMonthProvider =
    NotifierProvider<BudgetMonthNotifier, DateTime>(
  BudgetMonthNotifier.new,
);

final budgetsForMonthStreamProvider = StreamProvider<List<Budget>>((ref) {
  final selectedMonth = ref.watch(budgetSelectedMonthProvider);
  return ref.watch(getBudgetsUseCaseProvider).watch(
        year: selectedMonth.year,
        month: selectedMonth.month,
      );
});

final budgetMonthExpensesStreamProvider =
    StreamProvider<List<Transaction>>((ref) {
  final selectedMonth = ref.watch(budgetSelectedMonthProvider);
  return ref.watch(getTransactionsUseCaseProvider).watch(
        filter: TransactionFilter(
          type: TransactionType.expense,
          startDate: selectedMonth.startOfMonth,
          endDate: selectedMonth.endOfMonth,
          limit: 5000,
        ),
      );
});

final budgetStatusesProvider = Provider<AsyncValue<List<BudgetStatus>>>((ref) {
  final budgetsAsync = ref.watch(budgetsForMonthStreamProvider);
  final expensesAsync = ref.watch(budgetMonthExpensesStreamProvider);
  final categoriesAsync =
      ref.watch(categoriesStreamProvider(TransactionType.expense));
  final getBudgets = ref.watch(getBudgetsUseCaseProvider);

  if (budgetsAsync.hasError) {
    return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
  }
  if (expensesAsync.hasError) {
    return AsyncValue.error(expensesAsync.error!, expensesAsync.stackTrace!);
  }
  if (categoriesAsync.hasError) {
    return AsyncValue.error(
      categoriesAsync.error!,
      categoriesAsync.stackTrace!,
    );
  }
  if (!budgetsAsync.hasValue ||
      !expensesAsync.hasValue ||
      !categoriesAsync.hasValue) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    getBudgets.computeStatuses(
      budgets: budgetsAsync.value!,
      monthTransactions: expensesAsync.value!,
      categories: categoriesAsync.value!,
    ),
  );
});

final budgetControllerProvider = Provider<BudgetController>((ref) {
  return BudgetController(
    ref.watch(setBudgetUseCaseProvider),
    ref.watch(deleteBudgetUseCaseProvider),
    ref.watch(checkBudgetAlertsUseCaseProvider),
    ref.watch(notificationServiceProvider),
  );
});

class BudgetController {
  const BudgetController(
    this._setBudget,
    this._deleteBudget,
    this._checkBudgetAlerts,
    this._notificationService,
  );

  final SetBudget _setBudget;
  final DeleteBudget _deleteBudget;
  final CheckBudgetAlerts _checkBudgetAlerts;
  final NotificationService _notificationService;

  Future<Result<Budget>> saveBudget({
    required String categoryId,
    required int amountLimit,
    required int year,
    required int month,
  }) {
    return _setBudget(
      categoryId: categoryId,
      amountLimit: amountLimit,
      year: year,
      month: month,
    );
  }

  Future<Result<void>> deleteBudget(String id) => _deleteBudget(id);

  /// Checks if an expense triggered a 80% or 100% budget alert and dispatches
  /// a local OS notification. Returns the [BudgetAlertEvent] if triggered.
  Future<BudgetAlertEvent?> checkAndNotify({
    required String categoryId,
    required DateTime transactionDate,
    required String currencyCode,
    required String warningTitle,
    required String exceededTitle,
    required String Function(
      String category,
      int percentage,
      String spent,
      String limit,
    ) bodyBuilder,
  }) async {
    final local = transactionDate.toLocal();
    final result = await _checkBudgetAlerts(
      categoryId: categoryId,
      year: local.year,
      month: local.month,
    );
    final alert = result.dataOrNull;
    if (alert == null) return null;

    final title = alert.alertLevel == BudgetAlertLevel.exceeded
        ? exceededTitle
        : warningTitle;
    final body = bodyBuilder(
      alert.categoryName,
      alert.percentage,
      CurrencyFormatter.format(alert.spentAmount, currencyCode: currencyCode),
      CurrencyFormatter.format(alert.amountLimit, currencyCode: currencyCode),
    );

    await _notificationService.showBudgetAlert(
      id: alert.budgetId.hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
    );
    return alert;
  }
}
