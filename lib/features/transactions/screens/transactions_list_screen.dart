import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_filters.dart';
import '../widgets/transaction_tile.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet(
    List<Account> accounts,
    List<Category> categories,
    String currencyCode,
    String dateFormatPattern,
  ) async {
    final currentFilter = ref.read(transactionFilterProvider);
    final updated = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionFiltersSheet(
        initialFilter: currentFilter,
        accounts: accounts,
        categories: categories,
        currencyCode: currencyCode,
        dateFormatPattern: dateFormatPattern,
      ),
    );
    if (updated != null) {
      ref.read(transactionFilterProvider.notifier).applyFilter(updated);
    }
  }

  List<_ListEntry> _buildGroupedEntries(List<Transaction> transactions) {
    final entries = <_ListEntry>[];
    DateTime? currentDay;
    var dayNet = 0;
    var headerIndex = -1;

    for (final tx in transactions) {
      final local = tx.date.toLocal();
      final dayKey = DateTime(local.year, local.month, local.day);
      if (currentDay == null || currentDay != dayKey) {
        if (headerIndex >= 0) {
          entries[headerIndex] = _DateHeaderEntry(currentDay!, dayNet);
        }
        currentDay = dayKey;
        dayNet = 0;
        headerIndex = entries.length;
        entries.add(_DateHeaderEntry(dayKey, 0));
      }

      if (tx.type == TransactionType.income) {
        dayNet += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        dayNet -= tx.amount;
      }
      entries.add(_TransactionRowEntry(tx));
    }

    if (headerIndex >= 0 && currentDay != null) {
      entries[headerIndex] = _DateHeaderEntry(currentDay, dayNet);
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(transactionFilterProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? const [];
    final categories =
        ref.watch(categoriesStreamProvider(null)).value ?? const [];
    final currencyCode = ref.watch(activeCurrencyCodeProvider);
    final dateFormatPattern = ref.watch(activeDateFormatPatternProvider);

    final accountMap = {for (final a in accounts) a.id: a};
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTransactions),
        actions: [
          IconButton(
            tooltip: l10n.filter,
            onPressed: () => _openFilterSheet(
              accounts,
              categories,
              currencyCode,
              dateFormatPattern,
            ),
            icon: Badge(
              isLabelVisible: filter.activeFilterCount > 0,
              label: Text('${filter.activeFilterCount}'),
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchTransactionsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: l10n.close,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionFilterProvider.notifier)
                              .setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref
                    .read(transactionFilterProvider.notifier)
                    .setSearchQuery(value);
                setState(() {});
              },
            ),
          ),
          if (filter.activeFilterCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.filter_alt_off, size: 18),
                  label: Text(l10n.resetFilters),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(transactionFilterProvider.notifier).reset();
                    setState(() {});
                  },
                ),
              ),
            ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const LoadingStateWidget(),
              error: (_, _) => ErrorStateWidget(
                message: l10n.errorDatabase,
                onRetry: () => ref.invalidate(transactionsStreamProvider),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  if (filter.hasActiveFilters) {
                    return EmptyStateWidget(
                      icon: Icons.search_off,
                      title: l10n.noMatchingTransactions,
                      subtitle: l10n.noMatchingTransactionsSubtitle,
                      action: FilledButton.tonal(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(transactionFilterProvider.notifier).reset();
                          setState(() {});
                        },
                        child: Text(l10n.resetFilters),
                      ),
                    );
                  }
                  return EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.noTransactions,
                    subtitle: l10n.noTransactionsSubtitle,
                  );
                }

                final grouped = _buildGroupedEntries(transactions);
                final canLoadMore = transactions.length >= filter.limit;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: grouped.length + (canLoadMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == grouped.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: OutlinedButton(
                          onPressed: () => ref
                              .read(transactionFilterProvider.notifier)
                              .loadMore(),
                          child: Text(l10n.loadMore),
                        ),
                      );
                    }

                    final item = grouped[index];
                    return switch (item) {
                      _DateHeaderEntry(:final date, :final netAmount) =>
                        _DateSectionHeader(
                          date: date,
                          netAmount: netAmount,
                          currencyCode: currencyCode,
                          locale: locale,
                          dateFormatPattern: dateFormatPattern,
                          theme: theme,
                        ),
                      _TransactionRowEntry(:final transaction) =>
                        TransactionTile(
                          transaction: transaction,
                          currencyCode: currencyCode,
                          account: accountMap[transaction.accountId],
                          toAccount: transaction.toAccountId != null
                              ? accountMap[transaction.toAccountId]
                              : null,
                          category: transaction.categoryId != null
                              ? categoryMap[transaction.categoryId]
                              : null,
                          onTap: () => context.pushNamed(
                            RouteNames.transactionForm,
                            extra: transaction,
                          ),
                        ),
                    };
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

sealed class _ListEntry {
  const _ListEntry();
}

final class _DateHeaderEntry extends _ListEntry {
  const _DateHeaderEntry(this.date, this.netAmount);
  final DateTime date;
  final int netAmount;
}

final class _TransactionRowEntry extends _ListEntry {
  const _TransactionRowEntry(this.transaction);
  final Transaction transaction;
}

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({
    required this.date,
    required this.netAmount,
    required this.currencyCode,
    required this.locale,
    required this.dateFormatPattern,
    required this.theme,
  });

  final DateTime date;
  final int netAmount;
  final String currencyCode;
  final String locale;
  final String dateFormatPattern;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final formattedNet = CurrencyFormatter.format(
      netAmount.abs(),
      currencyCode: currencyCode,
    );
    final signedNet = netAmount > 0
        ? '+$formattedNet'
        : netAmount < 0
            ? '-$formattedNet'
            : formattedNet;
    final netColor = netAmount > 0
        ? AppColors.incomeText(theme.brightness)
        : netAmount < 0
            ? AppColors.expenseText(theme.brightness)
            : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      header: true,
      child: Container(
        color: theme.colorScheme.surfaceContainerLow.withAlpha(120),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                DateFormatter.formatRelative(
                  date,
                  locale: locale,
                  pattern: dateFormatPattern,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (netAmount != 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                signedNet,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: netColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
