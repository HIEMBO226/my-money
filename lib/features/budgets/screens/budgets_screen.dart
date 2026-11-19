import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/budget_providers.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_form_dialog.dart';
import '../widgets/budget_progress_bar.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  Future<void> _openForm(
    BuildContext context, {
    required DateTime selectedMonth,
    required List<Category> expenseCategories,
    required List<BudgetStatus> existingStatuses,
    Budget? existingBudget,
  }) async {
    final l10n = context.l10n;
    final available = existingBudget != null
        ? expenseCategories
            .where((c) => c.id == existingBudget.categoryId)
            .toList()
        : expenseCategories
            .where(
              (c) => !existingStatuses.any((s) => s.budget.categoryId == c.id),
            )
            .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allCategoriesBudgeted)),
      );
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => BudgetFormDialog(
        year: selectedMonth.year,
        month: selectedMonth.month,
        availableCategories: available,
        existingBudget: existingBudget,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.budgetSaved)),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result =
        await ref.read(budgetControllerProvider).deleteBudget(budget.id);
    if (!context.mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetDeleted)),
        );
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDatabase)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;
    final selectedMonth = ref.watch(budgetSelectedMonthProvider);
    final statusesAsync = ref.watch(budgetStatusesProvider);
    final expenseCategories =
        ref.watch(categoriesStreamProvider(TransactionType.expense)).value ??
            const <Category>[];
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    final statuses = statusesAsync.value ?? const <BudgetStatus>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navBudgets),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addBudget,
            onPressed: expenseCategories.isEmpty
                ? null
                : () => _openForm(
                      context,
                      selectedMonth: selectedMonth,
                      expenseCategories: expenseCategories,
                      existingStatuses: statuses,
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month navigation bar matching Dashboard style
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Container(
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
                        .read(budgetSelectedMonthProvider.notifier)
                        .previousMonth(),
                  ),
                  Text(
                    DateFormatter.formatMonthYear(selectedMonth, locale: locale),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: l10n.nextMonth,
                    onPressed: () => ref
                        .read(budgetSelectedMonthProvider.notifier)
                        .nextMonth(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: statusesAsync.when(
              loading: () => const LoadingStateWidget(),
              error: (_, _) => ErrorStateWidget(
                message: l10n.errorDatabase,
                onRetry: () => ref.invalidate(budgetsForMonthStreamProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.pie_chart_outline,
                    title: l10n.noBudgets,
                    subtitle: l10n.noBudgetsSubtitle,
                    action: FilledButton.icon(
                      onPressed: expenseCategories.isEmpty
                          ? null
                          : () => _openForm(
                                context,
                                selectedMonth: selectedMonth,
                                expenseCategories: expenseCategories,
                                existingStatuses: items,
                              ),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addBudget),
                    ),
                  );
                }

                final totalLimit = items.fold<int>(
                  0,
                  (sum, item) => sum + item.budget.amountLimit,
                );
                final totalSpent = items.fold<int>(
                  0,
                  (sum, item) => sum + item.spentAmount,
                );
                final totalRatio =
                    totalLimit <= 0 ? 0.0 : totalSpent / totalLimit;
                final totalAlertLevel =
                    totalRatio >= AppConstants.budgetCriticalThreshold
                        ? BudgetAlertLevel.exceeded
                        : totalRatio >= AppConstants.budgetWarningThreshold
                            ? BudgetAlertLevel.warning
                            : BudgetAlertLevel.normal;

                return ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      color: theme.colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.xl,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.budgetTotalMonthly,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${CurrencyFormatter.format(totalSpent, currencyCode: currencyCode)} / '
                                    '${CurrencyFormatter.format(totalLimit, currencyCode: currencyCode)}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(totalRatio * 100).round()} %',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BudgetProgressBar(
                              progress: totalRatio.clamp(0.0, 1.0),
                              alertLevel: totalAlertLevel,
                              percentage: (totalRatio * 100).round(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final status in items)
                      BudgetCard(
                        status: status,
                        currencyCode: currencyCode,
                        onEdit: () => _openForm(
                          context,
                          selectedMonth: selectedMonth,
                          expenseCategories: expenseCategories,
                          existingStatuses: items,
                          existingBudget: status.budget,
                        ),
                        onDelete: () =>
                            _confirmDelete(context, ref, status.budget),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
