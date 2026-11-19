import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../domain/enums/recurrence_frequency.dart';
import '../../../domain/enums/transaction_type.dart';

class RecurringTile extends StatelessWidget {
  const RecurringTile({
    required this.item,
    required this.currencyCode,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
    this.category,
    this.account,
    this.toAccount,
    this.dateFormatPattern,
    super.key,
  });

  final RecurringTransaction item;
  final String currencyCode;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final String? dateFormatPattern;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onDelete;

  String _frequencyLabel(BuildContext context, RecurrenceFrequency frequency) {
    final l10n = context.l10n;
    return switch (frequency) {
      RecurrenceFrequency.daily => l10n.frequencyDaily,
      RecurrenceFrequency.weekly => l10n.frequencyWeekly,
      RecurrenceFrequency.monthly => l10n.frequencyMonthly,
      RecurrenceFrequency.yearly => l10n.frequencyYearly,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final brightness = theme.brightness;
    final locale = Localizations.localeOf(context).languageCode;

    final isTransfer = item.type == TransactionType.transfer;
    final badgeColor = isTransfer
        ? AppColors.transfer
        : Color(
            category?.colorValue ?? AppColors.categoryColors.first.toARGB32(),
          );

    final title = item.note != null && item.note!.isNotEmpty
        ? item.note!
        : isTransfer
            ? '${account?.name ?? l10n.account} → ${toAccount?.name ?? l10n.account}'
            : (category?.localizedName(context) ?? l10n.uncategorized);

    final formattedBase = CurrencyFormatter.format(
      item.amount,
      currencyCode: currencyCode,
    );
    final signedAmount = switch (item.type) {
      TransactionType.income => '+$formattedBase',
      TransactionType.expense => '-$formattedBase',
      TransactionType.transfer => formattedBase,
    };
    final amountColor = switch (item.type) {
      TransactionType.income => AppColors.incomeText(brightness),
      TransactionType.expense => AppColors.expenseText(brightness),
      TransactionType.transfer => AppColors.transferText(brightness),
    };

    final freqText = _frequencyLabel(context, item.frequency);
    final nextDateText = DateFormatter.formatDate(
      item.nextDueDate,
      locale: locale,
      pattern: dateFormatPattern,
    );
    final subtitle = item.isActive
        ? '$freqText • ${l10n.nextDueDate}: $nextDateText'
        : '$freqText • ${l10n.recurringPaused}';

    final iconData = isTransfer
        ? Icons.swap_horiz
        : AppIcons.fromCodePoint(
            category?.iconCodePoint ?? Icons.repeat.codePoint,
          );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      child: InkWell(
        borderRadius: AppBorderRadius.lg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              AppBadge(
                icon: iconData,
                color: item.isActive
                    ? badgeColor
                    : theme.colorScheme.outlineVariant,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      signedAmount,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: l10n.recurringActiveLabel(title),
                child: Switch(
                  value: item.isActive,
                  onChanged: onToggleActive,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: '${l10n.delete} $title',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
