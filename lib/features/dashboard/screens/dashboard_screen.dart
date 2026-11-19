import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../transactions/widgets/transaction_tile.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/trend_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;
    final selectedMonth = ref.watch(dashboardSelectedMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? const [];
    final categories =
        ref.watch(categoriesStreamProvider(null)).value ?? const [];
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    final accountMap = {for (final a in accounts) a.id: a};
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
      ),
      body: summaryAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => ErrorStateWidget(
          message: l10n.errorDatabase,
          onRetry: () {
            ref.invalidate(accountsStreamProvider);
            ref.invalidate(dashboardTransactionsStreamProvider);
          },
        ),
        data: (summary) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              96,
            ),
            children: [
              // Month navigation bar
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: AppBorderRadius.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: l10n.previousMonth,
                      onPressed: () => ref
                          .read(dashboardSelectedMonthProvider.notifier)
                          .previousMonth(),
                    ),
                    Text(
                      DateFormatter.formatMonthYear(
                        selectedMonth,
                        locale: locale,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: l10n.nextMonth,
                      onPressed: () => ref
                          .read(dashboardSelectedMonthProvider.notifier)
                          .nextMonth(),
                    ),
                  ],
                ),
              ),

              BalanceCard(
                totalBalance: summary.totalBalance,
                accountCount: accounts.length,
                currencyCode: currencyCode,
                onTapAccounts: () => context.pushNamed(RouteNames.accounts),
              ),
              const SizedBox(height: AppSpacing.md),

              if (accounts.isEmpty && summary.recentTransactions.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                EmptyStateWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.noAccounts,
                  subtitle: l10n.welcomeDashboardSubtitle,
                  action: FilledButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.accountForm),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addAccount),
                  ),
                ),
              ] else ...[
                MonthlySummaryCard(
                  income: summary.monthlyIncome,
                  expense: summary.monthlyExpense,
                  currencyCode: currencyCode,
                ),
                const SizedBox(height: AppSpacing.md),
                CategoryPieChartCard(
                  title: l10n.expensesByCategory,
                  items: summary.categoryBreakdown,
                  currencyCode: currencyCode,
                  emptyMessage: l10n.noExpensesThisMonth,
                ),
                const SizedBox(height: AppSpacing.md),
                TrendChartCard(
                  points: summary.monthlyTrend,
                  currencyCode: currencyCode,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.recentTransactions,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.transactions),
                      child: Text(l10n.seeAll),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (summary.recentTransactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: Text(
                          l10n.noTransactions,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0;
                            i < summary.recentTransactions.length;
                            i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 68),
                          TransactionTile(
                            transaction: summary.recentTransactions[i],
                            currencyCode: currencyCode,
                            account:
                                accountMap[summary.recentTransactions[i].accountId],
                            toAccount: summary.recentTransactions[i].toAccountId !=
                                    null
                                ? accountMap[
                                    summary.recentTransactions[i].toAccountId]
                                : null,
                            category:
                                summary.recentTransactions[i].categoryId != null
                                    ? categoryMap[
                                        summary.recentTransactions[i].categoryId]
                                    : null,
                            onTap: () => context.pushNamed(
                              RouteNames.transactionForm,
                              extra: summary.recentTransactions[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
