import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/recurring_providers.dart';
import '../widgets/recurring_tile.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  Future<void> _runDueNow(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final result = await ref.read(recurringControllerProvider).processDueNow();
    if (!context.mounted) return;

    result.when(
      success: (count) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recurringGeneratedCount(count))),
        );
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDatabase)),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
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
        await ref.read(recurringControllerProvider).delete(item.id);
    if (!context.mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recurringDeleted)),
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
    final recurringAsync = ref.watch(recurringTransactionsStreamProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? const [];
    final categories =
        ref.watch(categoriesStreamProvider(null)).value ?? const [];
    final currencyCode = ref.watch(activeCurrencyCodeProvider);
    final dateFormatPattern = ref.watch(activeDateFormatPatternProvider);

    final accountMap = {for (final a in accounts) a.id: a};
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: l10n.runDueNow,
            onPressed: () => _runDueNow(context, ref),
          ),
        ],
      ),
      body: recurringAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => ErrorStateWidget(
          message: l10n.errorDatabase,
          onRetry: () => ref.invalidate(recurringTransactionsStreamProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.repeat,
              title: l10n.noRecurring,
              subtitle: l10n.noRecurringSubtitle,
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.recurringForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.addRecurring),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return RecurringTile(
                item: item,
                currencyCode: currencyCode,
                dateFormatPattern: dateFormatPattern,
                account: accountMap[item.accountId],
                toAccount:
                    item.toAccountId != null ? accountMap[item.toAccountId] : null,
                category:
                    item.categoryId != null ? categoryMap[item.categoryId] : null,
                onTap: () => context.pushNamed(
                  RouteNames.recurringForm,
                  extra: item,
                ),
                onToggleActive: (value) => ref
                    .read(recurringControllerProvider)
                    .toggleActive(item, value),
                onDelete: () => _confirmDelete(context, ref, item),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addRecurringFab',
        onPressed: () => context.pushNamed(RouteNames.recurringForm),
        icon: const Icon(Icons.add),
        label: Text(l10n.addRecurring),
      ),
    );
  }
}
