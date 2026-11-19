import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/transaction_type.dart';
import '../providers/category_providers.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/category_tile.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TransactionType get _activeType => _tabController.index == 0
      ? TransactionType.expense
      : TransactionType.income;

  Future<void> _openForm({Category? existing}) async {
    final l10n = context.l10n;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CategoryFormDialog(
        initialType: existing?.type ?? _activeType,
        existingCategory: existing,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? l10n.categoryCreated : l10n.categoryUpdated,
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Category category) async {
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

    if (confirmed != true || !mounted) return;

    final result =
        await ref.read(categoryControllerProvider).delete(category.id);
    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryDeleted)),
        );
      },
      failure: (exception) {
        final message = exception is ValidationException
            ? (category.isDefault
                ? l10n.categoryDeleteDefaultError
                : l10n.categoryDeleteUsedError)
            : l10n.errorDatabase;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.expensesTab),
            Tab(text: l10n.incomesTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryListTab(
            type: TransactionType.expense,
            onEdit: (category) => _openForm(existing: category),
            onDelete: _confirmDelete,
            onAdd: _openForm,
          ),
          _CategoryListTab(
            type: TransactionType.income,
            onEdit: (category) => _openForm(existing: category),
            onDelete: _confirmDelete,
            onAdd: _openForm,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addCategoryFab',
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
      ),
    );
  }
}

class _CategoryListTab extends ConsumerWidget {
  const _CategoryListTab({
    required this.type,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  final TransactionType type;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesStreamProvider(type));

    return categoriesAsync.when(
      loading: () => const LoadingStateWidget(),
      error: (error, _) => ErrorStateWidget(
        message: l10n.errorDatabase,
        onRetry: () => ref.invalidate(categoriesStreamProvider(type)),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.category_outlined,
            title: l10n.noCategories,
            subtitle: l10n.noCategoriesSubtitle,
            action: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addCategory),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryTile(
              category: category,
              onEdit: () => onEdit(category),
              onDelete: category.isDefault ? null : () => onDelete(category),
            );
          },
        );
      },
    );
  }
}
