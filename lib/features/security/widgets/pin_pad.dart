import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/security_service.dart';
import '../../../core/theme/app_dimensions.dart';

class PinPad extends StatefulWidget {
  const PinPad({
    required this.onCompleted,
    this.errorText,
    this.onBiometricsPressed,
    this.pinLength = LocalSecurityService.pinLength,
    super.key,
  });

  final ValueChanged<String> onCompleted;
  final String? errorText;
  final VoidCallback? onBiometricsPressed;
  final int pinLength;

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> {
  String _pin = '';

  void clear() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = '');
    }
  }

  void _append(String digit) {
    if (_pin.length >= widget.pinLength) return;
    HapticFeedback.selectionClick();
    final next = '$_pin$digit';
    setState(() => _pin = next);
    if (next.length == widget.pinLength) {
      widget.onCompleted(next);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: l10n.pinDigitEntered(_pin.length, widget.pinLength),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                final filled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.errorText != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 24,
            child: widget.errorText != null
                ? Semantics(
                    liveRegion: true,
                    child: Text(
                      widget.errorText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PinRow(
            children: [
              _PinKey(label: '1', onTap: () => _append('1')),
              _PinKey(label: '2', onTap: () => _append('2')),
              _PinKey(label: '3', onTap: () => _append('3')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PinRow(
            children: [
              _PinKey(label: '4', onTap: () => _append('4')),
              _PinKey(label: '5', onTap: () => _append('5')),
              _PinKey(label: '6', onTap: () => _append('6')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PinRow(
            children: [
              _PinKey(label: '7', onTap: () => _append('7')),
              _PinKey(label: '8', onTap: () => _append('8')),
              _PinKey(label: '9', onTap: () => _append('9')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PinRow(
            children: [
              if (widget.onBiometricsPressed != null)
                Expanded(
                  child: Semantics(
                    button: true,
                    label: l10n.useBiometrics,
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHigh.withAlpha(120),
                      borderRadius: AppBorderRadius.lg,
                      child: InkWell(
                        key: const Key('pin_key_biometrics'),
                        onTap: widget.onBiometricsPressed,
                        borderRadius: AppBorderRadius.lg,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: const Center(
                            child: Icon(
                              Icons.fingerprint,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
              _PinKey(label: '0', onTap: () => _append('0')),
              Expanded(
                child: Semantics(
                  button: true,
                  label: l10n.backspace,
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHigh.withAlpha(120),
                    borderRadius: AppBorderRadius.lg,
                    child: InkWell(
                      key: const Key('pin_key_backspace'),
                      onTap: _backspace,
                      borderRadius: AppBorderRadius.lg,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
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
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        children[0],
        const SizedBox(width: AppSpacing.md),
        children[1],
        const SizedBox(width: AppSpacing.md),
        children[2],
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Expanded(
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh.withAlpha(120),
        borderRadius: AppBorderRadius.lg,
        child: InkWell(
          key: Key('pin_key_$label'),
          onTap: onTap,
          borderRadius: AppBorderRadius.lg,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
