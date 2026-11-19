import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.currencyCode,
    required this.onTap,
    this.category,
    this.account,
    this.toAccount,
    super.key,
  });

  final Transaction transaction;
  final String currencyCode;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final brightness = theme.brightness;

    final isTransfer = transaction.type == TransactionType.transfer;
    final badgeColor = isTransfer
        ? AppColors.transfer
        : Color(category?.colorValue ?? AppColors.categoryColors.first.toARGB32());

    final iconData = isTransfer
        ? Icons.swap_horiz
        : AppIcons.fromCodePoint(
            category?.iconCodePoint ?? Icons.category.codePoint,
          );

    final title = isTransfer
        ? '${account?.name ?? l10n.account} → ${toAccount?.name ?? l10n.account}'
        : (category?.localizedName(context) ?? l10n.uncategorized);

    final subtitleParts = <String>[];
    if (!isTransfer && account != null) {
      subtitleParts.add(account!.name);
    }
    if (transaction.note != null && transaction.note!.isNotEmpty) {
      subtitleParts.add(transaction.note!);
    }

    final formattedBase = CurrencyFormatter.format(
      transaction.amount,
      currencyCode: currencyCode,
    );
    final signedAmount = switch (transaction.type) {
      TransactionType.income => '+$formattedBase',
      TransactionType.expense => '-$formattedBase',
      TransactionType.transfer => formattedBase,
    };

    final amountColor = switch (transaction.type) {
      TransactionType.income => AppColors.incomeText(brightness),
      TransactionType.expense => AppColors.expenseText(brightness),
      TransactionType.transfer => AppColors.transferText(brightness),
    };

    return MergeSemantics(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: AppBadge(
          icon: iconData,
          color: badgeColor,
          size: 42,
          iconSize: 20,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitleParts.isNotEmpty || transaction.attachments.isNotEmpty
            ? Row(
                children: [
                  if (subtitleParts.isNotEmpty)
                    Flexible(
                      child: Text(
                        subtitleParts.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (transaction.attachments.isNotEmpty) ...[
                    if (subtitleParts.isNotEmpty)
                      const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.attach_file,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: l10n.attachment,
                    ),
                  ],
                ],
              )
            : null,
        trailing: Text(
          signedAmount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
