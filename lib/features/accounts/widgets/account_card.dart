import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/account_type.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.account,
    required this.currencyCode,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Account account;
  final String currencyCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _localizedType(BuildContext context, AccountType type) {
    final l10n = context.l10n;
    return switch (type) {
      AccountType.cash => l10n.accountTypeCash,
      AccountType.bank => l10n.accountTypeBank,
      AccountType.mobileMoney => l10n.accountTypeMobileMoney,
      AccountType.savings => l10n.accountTypeSavings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final accentColor = Color(account.colorValue);

    final formattedBalance = CurrencyFormatter.format(
      account.balance,
      currencyCode: currencyCode,
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs + 2,
        ),
        leading: AppBadge(
          icon: AppIcons.fromCodePoint(account.iconCodePoint),
          color: accentColor,
          size: 44,
          iconSize: 22,
        ),
        title: Text(
          account.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          _localizedType(context, account.type),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedBalance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: account.balance < 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
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
        onTap: onEdit,
      ),
    );
  }
}
