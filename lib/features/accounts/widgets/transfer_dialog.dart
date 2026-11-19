import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/account_providers.dart';

class TransferDialog extends ConsumerStatefulWidget {
  const TransferDialog({
    required this.accounts,
    super.key,
  });

  final List<Account> accounts;

  @override
  ConsumerState<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _fromAccountId;
  late String _toAccountId;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fromAccountId = widget.accounts.first.id;
    _toAccountId = widget.accounts.length > 1
        ? widget.accounts[1].id
        : widget.accounts.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccountId == _toAccountId) {
      setState(() => _errorText = l10n.transferSameAccountError);
      return;
    }

    final currencyCode = ref.read(activeCurrencyCodeProvider);
    final amount = CurrencyFormatter.parseToSmallestUnit(
      _amountController.text,
      currencyCode: currencyCode,
    );

    if (amount <= 0) {
      setState(() => _errorText = l10n.invalidAmountError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final result = await ref.read(accountControllerProvider).transfer(
          fromAccountId: _fromAccountId,
          toAccountId: _toAccountId,
          amount: amount,
          note: _noteController.text,
        );

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (exception) {
        setState(() {
          _isSubmitting = false;
          _errorText = exception.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyCode = ref.watch(activeCurrencyCodeProvider);

    return AlertDialog(
      title: Text(l10n.transferTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId,
                decoration: InputDecoration(labelText: l10n.fromAccount),
                items: widget.accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fromAccountId = value;
                      _errorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                decoration: InputDecoration(labelText: l10n.toAccount),
                items: widget.accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _toAccountId = value;
                      _errorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLength: AppConstants.maxNoteLength,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  counterText: '',
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: TextStyle(color: context.colorScheme.error),
                ),
              ],
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
          child: Text(l10n.transfer),
        ),
      ],
    );
  }
}
