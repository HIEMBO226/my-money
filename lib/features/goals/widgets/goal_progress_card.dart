import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/savings_goal.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    required this.goal,
    required this.currencyCode,
    required this.onContribute,
    required this.onEdit,
    required this.onDelete,
    this.linkedAccount,
    this.dateFormatPattern,
    super.key,
  });

  final SavingsGoal goal;
  final String currencyCode;
  final Account? linkedAccount;
  final String? dateFormatPattern;
  final VoidCallback onContribute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final brightness = theme.brightness;
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;

    final accentColor = Color(goal.colorValue);

    final currentFormatted = CurrencyFormatter.format(
      goal.currentAmount,
      currencyCode: currencyCode,
    );
    final targetFormatted = CurrencyFormatter.format(
      goal.targetAmount,
      currencyCode: currencyCode,
    );
    final remainingFormatted = CurrencyFormatter.format(
      goal.remainingAmount,
      currencyCode: currencyCode,
    );

    final daysLeft = goal.daysRemaining();
    String? deadlineLabel;
    Color deadlineColor = theme.colorScheme.onSurfaceVariant;
    if (goal.deadline != null && daysLeft != null) {
      final dateStr = DateFormatter.formatDate(
        goal.deadline!,
        locale: locale,
        pattern: dateFormatPattern,
      );
      if (goal.isCompleted) {
        deadlineLabel = dateStr;
      } else if (daysLeft < 0) {
        deadlineLabel = '${l10n.deadlinePassed} ($dateStr)';
        deadlineColor = AppColors.expenseText(brightness);
      } else {
        deadlineLabel = '${l10n.daysRemaining(daysLeft)} ($dateStr)';
      }
    }

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
                    icon: AppIcons.fromCodePoint(goal.iconCodePoint),
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
                          goal.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (linkedAccount != null)
                          Text(
                            linkedAccount!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${goal.percentage} %',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: goal.isCompleted
                          ? AppColors.incomeText(brightness)
                          : theme.colorScheme.primary,
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
              Semantics(
                label: '${goal.name}: ${goal.percentage} %',
                child: ClipRRect(
                  borderRadius: AppBorderRadius.sm,
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 50 : 80),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? AppColors.income : accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '$currentFormatted / $targetFormatted',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (goal.isCompleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.incomeText(brightness),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.goalCompleted,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.incomeText(brightness),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '${l10n.budgetRemaining}: $remainingFormatted',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (deadlineLabel != null) ...[
                const SizedBox(height: AppSpacing.xs + 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: deadlineColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      deadlineLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: deadlineColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (!goal.isCompleted) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: onContribute,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.contribute),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
