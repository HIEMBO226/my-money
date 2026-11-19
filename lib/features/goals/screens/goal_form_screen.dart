import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../domain/enums/currency.dart';
import '../../../domain/use_cases/goals/create_savings_goal.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/widgets/icon_picker.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/goal_providers.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({
    this.existingGoal,
    super.key,
  });

  final SavingsGoal? existingGoal;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();

  DateTime? _deadline;
  String? _accountId;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;
  bool _isSubmitting = false;
  bool _initializedAmounts = false;

  bool get _isEditing => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingGoal;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _deadline = existing?.deadline?.toLocal();
    _accountId = existing?.accountId;
    _selectedIconCodePoint = existing?.iconCodePoint ?? Icons.savings.codePoint;
    _selectedColorValue =
        existing?.colorValue ?? AppColors.categoryColors[1].toARGB32();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing && !_initializedAmounts) {
      _initializedAmounts = true;
      final currencyCode = ref.read(activeCurrencyCodeProvider);
      final currency = Currency.fromCode(currencyCode);
      final target =
          widget.existingGoal!.targetAmount / currency.smallestUnitMultiplier;
      final current =
          widget.existingGoal!.currentAmount / currency.smallestUnitMultiplier;
      _targetController.text = currency.decimalDigits == 0
          ? target.round().toString()
          : target.toStringAsFixed(currency.decimalDigits);
      _currentController.text = currency.decimalDigits == 0
          ? current.round().toString()
          : current.toStringAsFixed(currency.decimalDigits);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 90)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      setState(() {
        _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final l10n = context.l10n;
    final currencyCode = ref.read(activeCurrencyCodeProvider);
    final targetAmount = CurrencyFormatter.parseToSmallestUnit(
      _targetController.text,
      currencyCode: currencyCode,
    );
    final currentAmount = _currentController.text.trim().isEmpty
        ? 0
        : CurrencyFormatter.parseToSmallestUnit(
            _currentController.text,
            currencyCode: currencyCode,
          );

    final controller = ref.read(goalControllerProvider);
    final result = _isEditing
        ? await controller.update(
            widget.existingGoal!.copyWith(
              name: _nameController.text.trim(),
              targetAmount: targetAmount,
              currentAmount: currentAmount,
              deadline: _deadline?.toUtc(),
              clearDeadline: _deadline == null,
              accountId: _accountId,
              clearAccountId: _accountId == null,
              iconCodePoint: _selectedIconCodePoint,
              colorValue: _selectedColorValue,
            ),
          )
        : await controller.create(
            name: _nameController.text.trim(),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: _deadline?.toUtc(),
            accountId: _accountId,
            iconCodePoint: _selectedIconCodePoint,
            colorValue: _selectedColorValue,
          );

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? l10n.goalUpdated : l10n.goalCreated),
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
    final accounts = ref.watch(accountsStreamProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editGoal : l10n.addGoal),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: CreateSavingsGoal.maxGoalNameLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.goalName,
                hintText: l10n.goalNameHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredFieldError;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${l10n.targetAmount} ($currencyCode)',
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${l10n.currentAmount} ($currencyCode)',
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = CurrencyFormatter.parseToSmallestUnit(
                  value,
                  currencyCode: currencyCode,
                );
                if (parsed < 0) return l10n.invalidAmountError;
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l10n.deadlineOptional),
              subtitle: Text(
                _deadline == null
                    ? l10n.noDeadline
                    : DateFormatter.formatDate(
                        _deadline!,
                        locale: locale,
                        pattern: dateFormatPattern,
                      ),
              ),
              trailing: _deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.close,
                      onPressed: () => setState(() => _deadline = null),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _pickDeadline,
            ),
            if (accounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue:
                    accounts.any((a) => a.id == _accountId) ? _accountId : null,
                decoration: InputDecoration(
                  labelText: l10n.linkedAccountOptional,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(l10n.noLinkedAccount),
                  ),
                  ...accounts.map(
                    (a) => DropdownMenuItem<String?>(
                      value: a.id,
                      child: Text(a.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.selectColor, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ColorPickerGrid(
              selectedColorValue: _selectedColorValue,
              onSelected: (color) =>
                  setState(() => _selectedColorValue = color),
            ),
            const SizedBox(height: 20),
            Text(l10n.selectIcon, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            IconPickerGrid(
              icons: AppIcons.allIcons,
              selectedCodePoint: _selectedIconCodePoint,
              accentColor: Color(_selectedColorValue),
              onSelected: (codePoint) =>
                  setState(() => _selectedIconCodePoint = codePoint),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSubmitting ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
