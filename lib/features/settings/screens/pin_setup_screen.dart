import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../security/providers/security_providers.dart';
import '../../security/widgets/pin_pad.dart';

enum _PinFlowMode {
  idle,
  createFirst,
  createConfirm,
  verifyBeforeChange,
  verifyBeforeDisable,
}

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinPadKey = GlobalKey<PinPadState>();
  _PinFlowMode _mode = _PinFlowMode.idle;
  String? _firstPin;
  String? _errorText;

  static const List<int> _timeoutOptions = [0, 1, 5, 15];

  String _timeoutLabel(BuildContext context, int minutes) {
    final l10n = context.l10n;
    return minutes == 0 ? l10n.autoLockImmediate : l10n.autoLockMinutes(minutes);
  }

  void _startFlow(_PinFlowMode mode) {
    setState(() {
      _mode = mode;
      _firstPin = null;
      _errorText = null;
    });
    _pinPadKey.currentState?.clear();
  }

  Future<void> _onPinCompleted(String pin) async {
    final l10n = context.l10n;
    final notifier = ref.read(securityProvider.notifier);

    switch (_mode) {
      case _PinFlowMode.createFirst:
        setState(() {
          _firstPin = pin;
          _mode = _PinFlowMode.createConfirm;
          _errorText = null;
        });
        _pinPadKey.currentState?.clear();

      case _PinFlowMode.createConfirm:
        if (pin != _firstPin) {
          setState(() {
            _errorText = l10n.pinMismatchError;
            _firstPin = null;
            _mode = _PinFlowMode.createFirst;
          });
          _pinPadKey.currentState?.clear();
          return;
        }
        await notifier.setupPin(pin);
        if (!mounted) return;
        setState(() {
          _mode = _PinFlowMode.idle;
          _firstPin = null;
          _errorText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pinSavedSuccess)),
        );

      case _PinFlowMode.verifyBeforeChange:
        final valid = await notifier.verifyPin(pin);
        if (!mounted) return;
        if (!valid) {
          setState(() => _errorText = l10n.wrongPinError);
          _pinPadKey.currentState?.clear();
          return;
        }
        _startFlow(_PinFlowMode.createFirst);

      case _PinFlowMode.verifyBeforeDisable:
        final valid = await notifier.verifyPin(pin);
        if (!mounted) return;
        if (!valid) {
          setState(() => _errorText = l10n.wrongPinError);
          _pinPadKey.currentState?.clear();
          return;
        }
        await notifier.removePin();
        if (!mounted) return;
        setState(() {
          _mode = _PinFlowMode.idle;
          _errorText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pinRemovedSuccess)),
        );

      case _PinFlowMode.idle:
        break;
    }
  }

  Future<void> _pickTimeout(int currentMinutes) async {
    final l10n = context.l10n;
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.autoLockTimeout),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _timeoutOptions.map((minutes) {
            return ListTile(
              title: Text(_timeoutLabel(dialogContext, minutes)),
              trailing:
                  minutes == currentMinutes ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop(minutes),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(securityProvider.notifier).setInactivityMinutes(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final securityState = ref.watch(securityProvider);
    final settings = securityState.settings;

    if (_mode != _PinFlowMode.idle) {
      final prompt = switch (_mode) {
        _PinFlowMode.createFirst => l10n.enterNewPin,
        _PinFlowMode.createConfirm => l10n.confirmNewPin,
        _PinFlowMode.verifyBeforeChange ||
        _PinFlowMode.verifyBeforeDisable =>
          l10n.enterCurrentPin,
        _PinFlowMode.idle => '',
      };

      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.pin),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.cancel,
            onPressed: () => setState(() => _mode = _PinFlowMode.idle),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prompt,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PinPad(
                  key: _pinPadKey,
                  errorText: _errorText,
                  onCompleted: _onPinCompleted,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.securityTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (!settings.isPinEnabled)
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(l10n.enablePin),
              subtitle: Text(l10n.pinDisabledStatus),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _startFlow(_PinFlowMode.createFirst),
            )
          else ...[
            ListTile(
              leading: Icon(
                Icons.verified_user_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.changePin),
              subtitle: Text(l10n.pinEnabledStatus),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _startFlow(_PinFlowMode.verifyBeforeChange),
            ),
            ListTile(
              leading: Icon(
                Icons.lock_open_outlined,
                color: theme.colorScheme.error,
              ),
              title: Text(l10n.disablePin),
              onTap: () => _startFlow(_PinFlowMode.verifyBeforeDisable),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.lockNow),
              onTap: () => ref.read(securityProvider.notifier).lockNow(),
            ),
            const Divider(height: 24),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.biometrics),
              subtitle: Text(
                securityState.isBiometricsAvailable
                    ? l10n.biometricsSubtitle
                    : l10n.biometricsUnavailable,
              ),
              value: settings.isBiometricsEnabled,
              onChanged: securityState.isBiometricsAvailable
                  ? (value) => ref
                      .read(securityProvider.notifier)
                      .setBiometricsEnabled(value)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l10n.autoLockTimeout),
              subtitle: Text(_timeoutLabel(context, settings.inactivityMinutes)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTimeout(settings.inactivityMinutes),
            ),
          ],
          const Divider(height: 24),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: Text(l10n.hideInAppSwitcher),
            subtitle: Text(l10n.hideInAppSwitcherSubtitle),
            value: settings.hideInAppSwitcher,
            onChanged: (value) => ref
                .read(securityProvider.notifier)
                .setHideInAppSwitcher(value),
          ),
        ],
      ),
    );
  }
}
