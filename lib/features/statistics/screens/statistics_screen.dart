import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../dashboard/widgets/category_pie_chart.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../widgets/comparison_chart.dart';
import '../widgets/period_selector.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final brightness = theme.brightness;
    final period = ref.watch(statisticsPeriodProvider);
    final selectedType = ref.watch(statisticsTypeProvider);
    final statsAsync = ref.watch(statisticsDataProvider);
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStatistics),
      ),
      body: statsAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => ErrorStateWidget(
          message: l10n.errorDatabase,
          onRetry: () => ref.invalidate(statisticsTransactionsStreamProvider),
        ),
        data: (stats) {
          final netFormatted = CurrencyFormatter.format(
            stats.netBalance.abs(),
            currencyCode: currencyCode,
          );
          final signedNet = stats.netBalance > 0
              ? '+$netFormatted'
              : stats.netBalance < 0
                  ? '-$netFormatted'
                  : netFormatted;
          final netColor = stats.netBalance > 0
              ? AppColors.incomeText(brightness)
              : stats.netBalance < 0
                  ? AppColors.expenseText(brightness)
                  : theme.colorScheme.onSurface;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              PeriodSelector(
                selected: period,
                onSelected: (next) =>
                    ref.read(statisticsPeriodProvider.notifier).select(next),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatKpiCard(
                      label: l10n.incomesTab,
                      value: '+${CurrencyFormatter.format(
                        stats.totalIncome,
                        currencyCode: currencyCode,
                      )}',
                      valueColor: AppColors.incomeText(brightness),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatKpiCard(
                      label: l10n.expensesTab,
                      value: '-${CurrencyFormatter.format(
                        stats.totalExpense,
                        currencyCode: currencyCode,
                      )}',
                      valueColor: AppColors.expenseText(brightness),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _StatKpiCard(
                      label: l10n.netSavings,
                      value: signedNet,
                      valueColor: netColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatKpiCard(
                      label: l10n.savingsRate,
                      value: '${stats.savingsRate.toStringAsFixed(0)} %',
                      valueColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ComparisonChartCard(series: stats.monthlySeries),
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.expensesTab),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.incomesTab),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (selection) => ref
                    .read(statisticsTypeProvider.notifier)
                    .select(selection.first),
              ),
              const SizedBox(height: AppSpacing.md),
              CategoryPieChartCard(
                title: selectedType == TransactionType.expense
                    ? l10n.expensesByCategory
                    : l10n.incomesByCategory,
                items: stats.categoryBreakdown,
                currencyCode: currencyCode,
                emptyMessage: l10n.noDataForPeriod,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatKpiCard extends StatelessWidget {
  const _StatKpiCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2,
          vertical: AppSpacing.md,
        ),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
