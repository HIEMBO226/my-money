import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/currency.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/budget_providers.dart';

class BudgetFormDialog extends ConsumerStatefulWidget {
  const BudgetFormDialog({
    required this.year,
    required this.month,
    required this.availableCategories,
    this.existingBudget,
    super.key,
  });

  final int year;
  final int month;
  final List<Category> availableCategories;
  final Budget? existingBudget;

  @override
  ConsumerState<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends ConsumerState<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _selectedCategoryId;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingBudget != null;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.existingBudget?.categoryId ??
        widget.availableCategories.first.id;
    _amountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing && _amountController.text.isEmpty) {
      final currencyCode = ref.read(activeCurrencyCodeProvider);
      final currency = Currency.fromCode(currencyCode);
      final value =
          widget.existingBudget!.amountLimit / currency.smallestUnitMultiplier;
      _amountController.text = currency.decimalDigits == 0
          ? value.round().toString()
          : value.toStringAsFixed(currency.decimalDigits);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final currencyCode = ref.read(activeCurrencyCodeProvider);
    final amountLimit = CurrencyFormatter.parseToSmallestUnit(
      _amountController.text,
      currencyCode: currencyCode,
    );

    final result = await ref.read(budgetControllerProvider).saveBudget(
          categoryId: _selectedCategoryId,
          amountLimit: amountLimit,
          year: widget.year,
          month: widget.month,
        );

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(true),
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
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    return AlertDialog(
      title: Text(_isEditing ? l10n.editBudget : l10n.addBudget),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: widget.availableCategories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.localizedName(context)),
                      ),
                    )
                    .toList(),
                onChanged: _isEditing
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedCategoryId = value);
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${l10n.budgetLimit} ($currencyCode)',
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
