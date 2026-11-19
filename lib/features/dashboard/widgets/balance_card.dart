import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.totalBalance,
    required this.accountCount,
    required this.currencyCode,
    required this.onTapAccounts,
    super.key,
  });

  final int totalBalance;
  final int accountCount;
  final String currencyCode;
  final VoidCallback onTapAccounts;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final formattedBalance = CurrencyFormatter.format(
      totalBalance,
      currencyCode: currencyCode,
    );

    // High contrast container colors
    final containerColor = colorScheme.primaryContainer;
    final onContainerColor = colorScheme.onPrimaryContainer;

    return MergeSemantics(
      child: Card(
        color: containerColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xl,
          side: BorderSide(
            color: onContainerColor.withAlpha(isDark ? 50 : 30),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTapAccounts,
          borderRadius: AppBorderRadius.xl,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs + 2),
                          decoration: BoxDecoration(
                            color: onContainerColor.withAlpha(isDark ? 40 : 25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: onContainerColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            l10n.totalBalance,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: onContainerColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: onContainerColor.withAlpha(isDark ? 40 : 25),
                        borderRadius: AppBorderRadius.round,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.accountsCount(accountCount),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: onContainerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: onContainerColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formattedBalance,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onContainerColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
