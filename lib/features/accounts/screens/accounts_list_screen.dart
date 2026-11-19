import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/account.dart';
import '../../../routing/route_names.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/account_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/transfer_dialog.dart';

class AccountsListScreen extends ConsumerWidget {
  const AccountsListScreen({super.key});

  Future<void> _openTransferDialog(
    BuildContext context,
    List<Account> accounts,
  ) async {
    final transferred = await showDialog<bool>(
      context: context,
      builder: (_) => TransferDialog(accounts: accounts),
    );
    if (transferred == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.transferSuccess)),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
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

    final result = await ref.read(accountControllerProvider).delete(account.id);
    if (!context.mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountDeleted)),
        );
      },
      failure: (exception) {
        final message = exception is ValidationException
            ? l10n.accountDeleteLinkedError
            : l10n.errorDatabase;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    final accounts = accountsAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        actions: [
          if (accounts.length >= 2)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.transfer,
              onPressed: () => _openTransferDialog(context, accounts),
            ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (error, _) => ErrorStateWidget(
          message: l10n.errorDatabase,
          onRetry: () => ref.invalidate(accountsStreamProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noAccounts,
              subtitle: l10n.noAccountsSubtitle,
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.accountForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.addAccount),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 88),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.xl,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalBalance,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            CurrencyFormatter.format(
                              totalBalance,
                              currencyCode: currencyCode,
                            ),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onPrimaryContainer,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              for (final account in items)
                AccountCard(
                  account: account,
                  currencyCode: currencyCode,
                  onEdit: () => context.pushNamed(
                    RouteNames.accountForm,
                    extra: account,
                  ),
                  onDelete: () => _confirmDelete(context, ref, account),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addAccountFab',
        onPressed: () => context.pushNamed(RouteNames.accountForm),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAccount),
      ),
    );
  }
}
