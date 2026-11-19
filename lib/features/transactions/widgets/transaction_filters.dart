import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/enums/transaction_type.dart';

class TransactionFiltersSheet extends StatefulWidget {
  const TransactionFiltersSheet({
    required this.initialFilter,
    required this.accounts,
    required this.categories,
    required this.currencyCode,
    this.dateFormatPattern,
    super.key,
  });

  final TransactionFilter initialFilter;
  final List<Account> accounts;
  final List<Category> categories;
  final String currencyCode;
  final String? dateFormatPattern;

  @override
  State<TransactionFiltersSheet> createState() =>
      _TransactionFiltersSheetState();
}

class _TransactionFiltersSheetState extends State<TransactionFiltersSheet> {
  late TransactionType? _type;
  late String? _accountId;
  late String? _categoryId;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _type = f.type;
    _accountId = f.accountId;
    _categoryId = f.categoryId;
    _startDate = f.startDate;
    _endDate = f.endDate;
    _minController = TextEditingController(
      text: f.minAmount != null ? f.minAmount.toString() : '',
    );
    _maxController = TextEditingController(
      text: f.maxAmount != null ? f.maxAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!.toLocal(), end: _endDate!.toLocal())
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start.startOfDay;
        _endDate = picked.end.endOfDay;
      });
    }
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.startOfMonth;
      _endDate = now.endOfMonth;
    });
  }

  void _selectLastMonth() {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    setState(() {
      _startDate = prev.startOfMonth;
      _endDate = prev.endOfMonth;
    });
  }

  void _selectLast30Days() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 30)).startOfDay;
      _endDate = now.endOfDay;
    });
  }

  void _apply() {
    final minVal = _minController.text.trim().isEmpty
        ? null
        : CurrencyFormatter.parseToSmallestUnit(
            _minController.text,
            currencyCode: widget.currencyCode,
          );
    final maxVal = _maxController.text.trim().isEmpty
        ? null
        : CurrencyFormatter.parseToSmallestUnit(
            _maxController.text,
            currencyCode: widget.currencyCode,
          );

    Navigator.of(context).pop(
      widget.initialFilter.copyWith(
        type: _type,
        clearType: _type == null,
        accountId: _accountId,
        clearAccountId: _accountId == null,
        categoryId: _categoryId,
        clearCategoryId: _categoryId == null,
        startDate: _startDate,
        clearStartDate: _startDate == null,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        minAmount: minVal,
        clearMinAmount: minVal == null,
        maxAmount: maxVal,
        clearMaxAmount: maxVal == null,
      ),
    );
  }

  void _reset() {
    Navigator.of(context).pop(
      TransactionFilter(searchQuery: widget.initialFilter.searchQuery),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;

    final periodLabel = _startDate != null && _endDate != null
        ? '${DateFormatter.formatDate(_startDate!, locale: locale, pattern: widget.dateFormatPattern)} — '
            '${DateFormatter.formatDate(_endDate!, locale: locale, pattern: widget.dateFormatPattern)}'
        : l10n.allPeriods;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filtersTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(l10n.resetFilters),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.selectType,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: Text(l10n.allTypes),
                    selected: _type == null,
                    onSelected: (_) => setState(() => _type = null),
                  ),
                  ChoiceChip(
                    label: Text(l10n.transactionTypeExpense),
                    selected: _type == TransactionType.expense,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.expense),
                  ),
                  ChoiceChip(
                    label: Text(l10n.transactionTypeIncome),
                    selected: _type == TransactionType.income,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.income),
                  ),
                  ChoiceChip(
                    label: Text(l10n.transactionTypeTransfer),
                    selected: _type == TransactionType.transfer,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.transfer),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.period,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                periodLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionChip(
                    label: Text(l10n.allPeriods),
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                  ),
                  ActionChip(
                    label: Text(l10n.thisMonth),
                    onPressed: _selectThisMonth,
                  ),
                  ActionChip(
                    label: Text(l10n.lastMonth),
                    onPressed: _selectLastMonth,
                  ),
                  ActionChip(
                    label: Text(l10n.last30Days),
                    onPressed: _selectLast30Days,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.date_range, size: 18),
                    label: Text(l10n.customPeriod),
                    onPressed: _pickCustomDateRange,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String?>(
                initialValue: _accountId,
                decoration: InputDecoration(labelText: l10n.account),
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(l10n.allAccounts),
                  ),
                  ...widget.accounts.map(
                    (acc) => DropdownMenuItem<String?>(
                      value: acc.id,
                      child: Text(acc.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(l10n.allCategories),
                  ),
                  ...widget.categories.map(
                    (cat) => DropdownMenuItem<String?>(
                      value: cat.id,
                      child: Text(cat.localizedName(context)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.amountRange,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: '${l10n.minAmount} (${widget.currencyCode})',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _maxController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: '${l10n.maxAmount} (${widget.currencyCode})',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: _apply,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(l10n.applyFilters),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
