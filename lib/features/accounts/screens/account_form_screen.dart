import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/account_type.dart';
import '../../categories/widgets/icon_picker.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/account_providers.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({
    this.existingAccount,
    super.key,
  });

  final Account? existingAccount;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _initialBalanceController = TextEditingController();

  late AccountType _selectedType;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingAccount != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAccount;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _selectedType = existing?.type ?? AccountType.cash;
    _selectedIconCodePoint =
        existing?.iconCodePoint ?? _defaultIconForType(_selectedType).codePoint;
    _selectedColorValue =
        existing?.colorValue ?? AppColors.categoryColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  IconData _defaultIconForType(AccountType type) {
    return switch (type) {
      AccountType.cash => Icons.payments,
      AccountType.bank => Icons.account_balance,
      AccountType.mobileMoney => Icons.phone_android,
      AccountType.savings => Icons.savings,
    };
  }

  String _localizedType(BuildContext context, AccountType type) {
    final l10n = context.l10n;
    return switch (type) {
      AccountType.cash => l10n.accountTypeCash,
      AccountType.bank => l10n.accountTypeBank,
      AccountType.mobileMoney => l10n.accountTypeMobileMoney,
      AccountType.savings => l10n.accountTypeSavings,
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final controller = ref.read(accountControllerProvider);
    final l10n = context.l10n;
    final currencyCode = ref.read(activeCurrencyCodeProvider);

    final result = _isEditing
        ? await controller.update(
            widget.existingAccount!.copyWith(
              name: _nameController.text.trim(),
              type: _selectedType,
              iconCodePoint: _selectedIconCodePoint,
              colorValue: _selectedColorValue,
            ),
          )
        : await controller.create(
            name: _nameController.text.trim(),
            type: _selectedType,
            iconCodePoint: _selectedIconCodePoint,
            colorValue: _selectedColorValue,
            initialBalance: _initialBalanceController.text.trim().isEmpty
                ? 0
                : CurrencyFormatter.parseToSmallestUnit(
                    _initialBalanceController.text,
                    currencyCode: currencyCode,
                  ),
            initialBalanceNote: l10n.initialBalanceNote,
          );

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? l10n.accountUpdated : l10n.accountCreated,
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
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.addAccount),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: AppConstants.maxAccountNameLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.accountName,
                hintText: l10n.accountNameHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredFieldError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.accountType, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(_localizedType(context, type)),
                  avatar: Icon(_defaultIconForType(type), size: 18),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = type;
                      if (!_isEditing) {
                        _selectedIconCodePoint =
                            _defaultIconForType(type).codePoint;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${l10n.initialBalance} ($currencyCode)',
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
            ],
            const SizedBox(height: 24),
            Text(l10n.selectColor, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ColorPickerGrid(
              selectedColorValue: _selectedColorValue,
              onSelected: (color) => setState(() => _selectedColorValue = color),
            ),
            const SizedBox(height: 24),
            Text(l10n.selectIcon, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            IconPickerGrid(
              icons: AppIcons.accountIcons,
              selectedCodePoint: _selectedIconCodePoint,
              accentColor: Color(_selectedColorValue),
              onSelected: (codePoint) =>
                  setState(() => _selectedIconCodePoint = codePoint),
            ),
            const SizedBox(height: 32),
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
