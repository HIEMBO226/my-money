import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_progress_card.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  Future<void> _openContributeDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    String currencyCode,
  ) async {
    final l10n = context.l10n;
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _ContributeDialog(currencyCode: currencyCode),
    );

    if (amount == null || !context.mounted) return;

    final result = await ref.read(goalControllerProvider).contribute(
          goalId: goal.id,
          amount: amount,
        );
    if (!context.mounted) return;

    result.when(
      success: (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isCompleted ? l10n.goalCompleted : l10n.contributionAdded,
            ),
          ),
        );
      },
      failure: (exception) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
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

    final result = await ref.read(goalControllerProvider).delete(goal.id);
    if (!context.mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.goalDeleted)),
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
    final theme = context.theme;
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final accounts = ref.watch(accountsStreamProvider).value ?? const [];
    final currencyCode = ref.watch(activeCurrencyCodeProvider);
    final dateFormatPattern = ref.watch(activeDateFormatPatternProvider);
    final accountMap = {for (final a in accounts) a.id: a};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savingsGoals),
      ),
      body: goalsAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => ErrorStateWidget(
          message: l10n.errorDatabase,
          onRetry: () => ref.invalidate(savingsGoalsStreamProvider),
        ),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.savings_outlined,
              title: l10n.noGoals,
              subtitle: l10n.noGoalsSubtitle,
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.goalForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.addGoal),
              ),
            );
          }

          final totalSaved =
              goals.fold<int>(0, (sum, g) => sum + g.currentAmount);
          final totalTarget =
              goals.fold<int>(0, (sum, g) => sum + g.targetAmount);

          return ListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 96),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                color: theme.colorScheme.tertiaryContainer,
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
                          l10n.totalSaved,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${CurrencyFormatter.format(totalSaved, currencyCode: currencyCode)} / '
                          '${CurrencyFormatter.format(totalTarget, currencyCode: currencyCode)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (final goal in goals)
                GoalProgressCard(
                  goal: goal,
                  currencyCode: currencyCode,
                  dateFormatPattern: dateFormatPattern,
                  linkedAccount:
                      goal.accountId != null ? accountMap[goal.accountId] : null,
                  onContribute: () =>
                      _openContributeDialog(context, ref, goal, currencyCode),
                  onEdit: () => context.pushNamed(
                    RouteNames.goalForm,
                    extra: goal,
                  ),
                  onDelete: () => _confirmDelete(context, ref, goal),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addGoalFab',
        onPressed: () => context.pushNamed(RouteNames.goalForm),
        icon: const Icon(Icons.add),
        label: Text(l10n.addGoal),
      ),
    );
  }
}

class _ContributeDialog extends StatefulWidget {
  const _ContributeDialog({required this.currencyCode});

  final String currencyCode;

  @override
  State<_ContributeDialog> createState() => _ContributeDialogState();
}

class _ContributeDialogState extends State<_ContributeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.contributeTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${l10n.amount} (${widget.currencyCode})',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.requiredFieldError;
            }
            final parsed = CurrencyFormatter.parseToSmallestUnit(
              value,
              currencyCode: widget.currencyCode,
            );
            if (parsed <= 0) return l10n.invalidAmountError;
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final parsed = CurrencyFormatter.parseToSmallestUnit(
              _amountController.text,
              currencyCode: widget.currencyCode,
            );
            Navigator.of(context).pop(parsed);
          },
          child: Text(l10n.contribute),
        ),
      ],
    );
  }
}
