import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../domain/enums/currency.dart';
import '../../../domain/enums/recurrence_frequency.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/recurring_providers.dart';

class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({
    this.existing,
    super.key,
  });

  final RecurringTransaction? existing;

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  late RecurrenceFrequency _frequency;
  late DateTime _nextDueDate;
  DateTime? _endDate;
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  bool _isSubmitting = false;
  bool _initializedAmount = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? TransactionType.expense;
    _frequency = existing?.frequency ?? RecurrenceFrequency.monthly;
    _nextDueDate = existing?.nextDueDate.toLocal() ?? DateTime.now();
    _endDate = existing?.endDate?.toLocal();
    _accountId = existing?.accountId;
    _toAccountId = existing?.toAccountId;
    _categoryId = existing?.categoryId;
    _noteController.text = existing?.note ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing && !_initializedAmount) {
      _initializedAmount = true;
      final currencyCode = ref.read(activeCurrencyCodeProvider);
      final currency = Currency.fromCode(currencyCode);
      final value = widget.existing!.amount / currency.smallestUnitMultiplier;
      _amountController.text = currency.decimalDigits == 0
          ? value.round().toString()
          : value.toStringAsFixed(currency.decimalDigits);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _frequencyLabel(BuildContext context, RecurrenceFrequency frequency) {
    final l10n = context.l10n;
    return switch (frequency) {
      RecurrenceFrequency.daily => l10n.frequencyDaily,
      RecurrenceFrequency.weekly => l10n.frequencyWeekly,
      RecurrenceFrequency.monthly => l10n.frequencyMonthly,
      RecurrenceFrequency.yearly => l10n.frequencyYearly,
    };
  }

  Future<void> _pickNextDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _nextDueDate = DateTime(picked.year, picked.month, picked.day, 9);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _nextDueDate.add(const Duration(days: 30)),
      firstDate: _nextDueDate,
      lastDate: DateTime(_nextDueDate.year + 20),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  Future<void> _save(
    List<Account> accounts,
    List<Category> categories,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final currencyCode = ref.read(activeCurrencyCodeProvider);
    final amount = CurrencyFormatter.parseToSmallestUnit(
      _amountController.text,
      currencyCode: currencyCode,
    );

    final resolvedAccountId =
        _accountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    if (resolvedAccountId == null) return;

    String? resolvedToAccountId;
    String? resolvedCategoryId;

    if (_type == TransactionType.transfer) {
      resolvedToAccountId = _toAccountId ??
          accounts
              .where((a) => a.id != resolvedAccountId)
              .map((a) => a.id)
              .firstOrNull;
      if (resolvedToAccountId == null ||
          resolvedToAccountId == resolvedAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferSameAccountError)),
        );
        return;
      }
    } else {
      resolvedCategoryId = _categoryId ??
          (categories.isNotEmpty ? categories.first.id : null);
      if (resolvedCategoryId == null) return;
    }

    setState(() => _isSubmitting = true);

    final controller = ref.read(recurringControllerProvider);
    final result = _isEditing
        ? await controller.update(
            widget.existing!.copyWith(
              type: _type,
              amount: amount,
              accountId: resolvedAccountId,
              categoryId: resolvedCategoryId,
              clearCategoryId: _type == TransactionType.transfer,
              toAccountId: resolvedToAccountId,
              clearToAccountId: _type != TransactionType.transfer,
              note: _noteController.text.trim(),
              clearNote: _noteController.text.trim().isEmpty,
              frequency: _frequency,
              nextDueDate: _nextDueDate.toUtc(),
              endDate: _endDate?.toUtc(),
              clearEndDate: _endDate == null,
            ),
          )
        : await controller.create(
            type: _type,
            amount: amount,
            accountId: resolvedAccountId,
            categoryId: resolvedCategoryId,
            toAccountId: resolvedToAccountId,
            note: _noteController.text,
            frequency: _frequency,
            nextDueDate: _nextDueDate.toUtc(),
            endDate: _endDate?.toUtc(),
          );

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? l10n.recurringUpdated : l10n.recurringCreated,
            ),
          ),
        );
        Navigator.of(context).pop(true);
      },
      failure: (exception) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;
    final currencyCode = ref.watch(activeCurrencyCodeProvider);
    final dateFormatPattern = ref.watch(activeDateFormatPatternProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final catType =
        _type == TransactionType.transfer ? TransactionType.expense : _type;
    final categories =
        ref.watch(categoriesStreamProvider(catType)).value ?? const <Category>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editRecurring : l10n.addRecurring),
      ),
      body: accountsAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => Center(child: Text(l10n.errorDatabase)),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noAccounts,
              subtitle: l10n.noAccountsPrompt,
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.accountForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.addAccount),
              ),
            );
          }

          final activeAccountId = accounts.any((a) => a.id == _accountId)
              ? _accountId!
              : accounts.first.id;
          final activeToAccountId = _toAccountId != null &&
                  accounts.any(
                    (a) => a.id == _toAccountId && a.id != activeAccountId,
                  )
              ? _toAccountId
              : accounts
                  .where((a) => a.id != activeAccountId)
                  .map((a) => a.id)
                  .firstOrNull;
          final activeCategoryId = categories.any((c) => c.id == _categoryId)
              ? _categoryId
              : (categories.isNotEmpty ? categories.first.id : null);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<TransactionType>(
                  segments: [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(l10n.transactionTypeExpense),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(l10n.transactionTypeIncome),
                    ),
                    if (accounts.length >= 2)
                      ButtonSegment(
                        value: TransactionType.transfer,
                        label: Text(l10n.transactionTypeTransfer),
                      ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                      _categoryId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${l10n.amount} ($currencyCode)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.requiredFieldError;
                    }
                    final parsed = CurrencyFormatter.parseToSmallestUnit(
                      value,
                      currencyCode: currencyCode,
                    );
                    if (parsed <= 0) return l10n.invalidAmountError;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(l10n.frequency, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RecurrenceFrequency.values.map((freq) {
                    return ChoiceChip(
                      label: Text(_frequencyLabel(context, freq)),
                      selected: _frequency == freq,
                      onSelected: (_) => setState(() => _frequency = freq),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (_type != TransactionType.transfer &&
                    activeCategoryId != null) ...[
                  DropdownButtonFormField<String>(
                    initialValue: activeCategoryId,
                    decoration: InputDecoration(labelText: l10n.category),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.localizedName(context)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _categoryId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  initialValue: activeAccountId,
                  decoration: InputDecoration(
                    labelText: _type == TransactionType.transfer
                        ? l10n.fromAccount
                        : l10n.account,
                  ),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _accountId = value);
                  },
                ),
                if (_type == TransactionType.transfer &&
                    activeToAccountId != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: activeToAccountId,
                    decoration: InputDecoration(labelText: l10n.toAccount),
                    items: accounts
                        .where((a) => a.id != activeAccountId)
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _toAccountId = value);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(100),
                    ),
                  ),
                  leading: const Icon(Icons.event_repeat),
                  title: Text(l10n.nextDueDate),
                  subtitle: Text(
                    DateFormatter.formatDate(
                      _nextDueDate,
                      locale: locale,
                      pattern: dateFormatPattern,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickNextDueDate,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(100),
                    ),
                  ),
                  leading: const Icon(Icons.event_busy_outlined),
                  title: Text(l10n.endDateOptional),
                  subtitle: Text(
                    _endDate == null
                        ? l10n.noEndDate
                        : DateFormatter.formatDate(
                            _endDate!,
                            locale: locale,
                            pattern: dateFormatPattern,
                          ),
                  ),
                  trailing: _endDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: l10n.close,
                          onPressed: () => setState(() => _endDate = null),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _pickEndDate,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLength: AppConstants.maxNoteLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.note,
                    hintText: l10n.noteHint,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      _isSubmitting ? null : () => _save(accounts, categories),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
