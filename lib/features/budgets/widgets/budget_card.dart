import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/budget.dart';
import 'budget_progress_bar.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.status,
    required this.currencyCode,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final BudgetStatus status;
  final String currencyCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final brightness = theme.brightness;
    final category = status.category;

    final accentColor = Color(
      category?.colorValue ?? AppColors.categoryColors.first.toARGB32(),
    );

    final spentFormatted = CurrencyFormatter.format(
      status.spentAmount,
      currencyCode: currencyCode,
    );
    final limitFormatted = CurrencyFormatter.format(
      status.budget.amountLimit,
      currencyCode: currencyCode,
    );
    final remaining = status.remainingAmount;
    final remainingLabel = remaining >= 0
        ? '${l10n.budgetRemaining}: '
            '${CurrencyFormatter.format(remaining, currencyCode: currencyCode)}'
        : l10n.budgetOverBy(
            CurrencyFormatter.format(
              remaining.abs(),
              currencyCode: currencyCode,
            ),
          );

    final statusColor = switch (status.alertLevel) {
      BudgetAlertLevel.normal => AppColors.incomeText(brightness),
      BudgetAlertLevel.warning => AppColors.warningText(brightness),
      BudgetAlertLevel.exceeded => AppColors.expenseText(brightness),
    };

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      child: InkWell(
        borderRadius: AppBorderRadius.lg,
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBadge(
                    icon: AppIcons.fromCodePoint(
                      category?.iconCodePoint ?? Icons.category.codePoint,
                    ),
                    color: accentColor,
                    size: 42,
                    iconSize: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.localizedName(context) ?? l10n.uncategorized,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '$spentFormatted / $limitFormatted',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${status.percentage} %',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.edit,
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              l10n.delete,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              BudgetProgressBar(
                progress: status.clampedProgress,
                alertLevel: status.alertLevel,
                percentage: status.percentage,
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      remainingLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: remaining < 0
                            ? AppColors.expenseText(brightness)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (status.alertLevel != BudgetAlertLevel.normal)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status.alertLevel == BudgetAlertLevel.exceeded
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          status.alertLevel == BudgetAlertLevel.exceeded
                              ? l10n.budgetExceeded
                              : l10n.budgetWarning,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
