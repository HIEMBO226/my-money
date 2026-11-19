import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/enums/currency.dart';
import '../extensions/context_extensions.dart';
import '../formatters/currency_formatter.dart';

/// Optimized numeric keypad for fast, accurate monetary amount entry.
/// Stores and emits values strictly as integers in the smallest currency unit.
class AmountInputField extends StatefulWidget {
  const AmountInputField({
    required this.currencyCode,
    required this.onChanged,
    this.initialAmount = 0,
    this.accentColor,
    super.key,
  });

  final String currencyCode;
  final int initialAmount;
  final Color? accentColor;
  final ValueChanged<int> onChanged;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  static const int _maxIntegerDigits = 10;

  late String _rawInput;

  Currency get _currency => Currency.fromCode(widget.currencyCode);

  @override
  void initState() {
    super.initState();
    _rawInput = _formatInitialRaw(widget.initialAmount);
  }

  String _formatInitialRaw(int amount) {
    if (amount <= 0) return '';
    final decimals = _currency.decimalDigits;
    if (decimals == 0) return amount.toString();
    final divisor = _currency.smallestUnitMultiplier;
    final whole = amount ~/ divisor;
    final frac = (amount % divisor).toString().padLeft(decimals, '0');
    final trimmedFrac = frac.replaceFirst(RegExp(r'0+$'), '');
    return trimmedFrac.isEmpty ? '$whole' : '$whole.$trimmedFrac';
  }

  int _parseRawToSmallestUnit(String raw) {
    if (raw.isEmpty) return 0;
    final decimals = _currency.decimalDigits;
    final parts = raw.split('.');
    final wholePart = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
    if (decimals == 0) return wholePart;

    var fracStr = parts.length > 1 ? parts[1] : '';
    if (fracStr.length > decimals) {
      fracStr = fracStr.substring(0, decimals);
    }
    fracStr = fracStr.padRight(decimals, '0');
    final fracPart = int.tryParse(fracStr) ?? 0;
    return wholePart * _currency.smallestUnitMultiplier + fracPart;
  }

  void _appendDigit(String digit) {
    HapticFeedback.selectionClick();
    final decimals = _currency.decimalDigits;
    final hasDot = _rawInput.contains('.');

    if (hasDot) {
      final fracPart = _rawInput.split('.')[1];
      if (fracPart.length >= decimals) return;
      _updateRaw('$_rawInput$digit');
      return;
    }

    if (_rawInput == '0') {
      _updateRaw(digit == '00' ? '0' : digit);
      return;
    }

    if (_rawInput.isEmpty && digit == '00') {
      return;
    }

    final candidate = '$_rawInput$digit';
    if (candidate.length > _maxIntegerDigits) return;
    _updateRaw(candidate);
  }

  void _appendDecimalPoint() {
    if (_currency.decimalDigits == 0) return;
    if (_rawInput.contains('.')) return;
    HapticFeedback.selectionClick();
    _updateRaw(_rawInput.isEmpty ? '0.' : '$_rawInput.');
  }

  void _backspace() {
    if (_rawInput.isEmpty) return;
    HapticFeedback.selectionClick();
    _updateRaw(_rawInput.substring(0, _rawInput.length - 1));
  }

  void _clear() {
    if (_rawInput.isEmpty) return;
    HapticFeedback.mediumImpact();
    _updateRaw('');
  }

  void _updateRaw(String next) {
    setState(() => _rawInput = next);
    widget.onChanged(_parseRawToSmallestUnit(next));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final amountValue = _parseRawToSmallestUnit(_rawInput);
    final formatted = CurrencyFormatter.format(
      amountValue,
      currencyCode: widget.currencyCode,
    );
    final accent = widget.accentColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(110),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: '${l10n.amount}: $formatted',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatted,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              if (_rawInput.isNotEmpty)
                IconButton(
                  key: const Key('amount_clear'),
                  onPressed: _clear,
                  tooltip: l10n.clearAmount,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _KeypadRow(
          children: [
            _KeypadButton(label: '1', onTap: () => _appendDigit('1')),
            _KeypadButton(label: '2', onTap: () => _appendDigit('2')),
            _KeypadButton(label: '3', onTap: () => _appendDigit('3')),
          ],
        ),
        const SizedBox(height: 8),
        _KeypadRow(
          children: [
            _KeypadButton(label: '4', onTap: () => _appendDigit('4')),
            _KeypadButton(label: '5', onTap: () => _appendDigit('5')),
            _KeypadButton(label: '6', onTap: () => _appendDigit('6')),
          ],
        ),
        const SizedBox(height: 8),
        _KeypadRow(
          children: [
            _KeypadButton(label: '7', onTap: () => _appendDigit('7')),
            _KeypadButton(label: '8', onTap: () => _appendDigit('8')),
            _KeypadButton(label: '9', onTap: () => _appendDigit('9')),
          ],
        ),
        const SizedBox(height: 8),
        _KeypadRow(
          children: [
            if (_currency.decimalDigits > 0)
              _KeypadButton(
                label: '.',
                onTap: _appendDecimalPoint,
              )
            else
              _KeypadButton(
                label: '00',
                onTap: () => _appendDigit('00'),
              ),
            _KeypadButton(label: '0', onTap: () => _appendDigit('0')),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.backspace,
                child: Material(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const Key('amount_key_backspace'),
                    onTap: _backspace,
                    onLongPress: _clear,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Center(
                        child: Icon(
                          Icons.backspace_outlined,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const _KeypadRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        children[0],
        const SizedBox(width: 8),
        children[1],
        const SizedBox(width: 8),
        children[2],
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Expanded(
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('amount_key_$label'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
