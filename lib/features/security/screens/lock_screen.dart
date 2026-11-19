import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../providers/security_providers.dart';
import '../widgets/pin_pad.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinPadKey = GlobalKey<PinPadState>();
  String? _errorText;
  bool _promptedBiometrics = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_promptedBiometrics) {
      _promptedBiometrics = true;
      final state = ref.read(securityProvider);
      if (state.settings.isBiometricsEnabled && state.isBiometricsAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _authenticateBiometrics();
        });
      }
    }
  }

  Future<void> _onPinEntered(String pin) async {
    final unlocked =
        await ref.read(securityProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    if (!unlocked) {
      setState(() => _errorText = context.l10n.wrongPinError);
      _pinPadKey.currentState?.clear();
    }
  }

  Future<void> _authenticateBiometrics() async {
    final reason = context.l10n.biometricsReason;
    await ref
        .read(securityProvider.notifier)
        .unlockWithBiometrics(reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final securityState = ref.watch(securityProvider);
    final showBiometrics = securityState.settings.isBiometricsEnabled &&
        securityState.isBiometricsAvailable;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBadge(
                  icon: Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 72,
                  iconSize: 32,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.enterPinToUnlock,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PinPad(
                  key: _pinPadKey,
                  errorText: _errorText,
                  onCompleted: _onPinEntered,
                  onBiometricsPressed:
                      showBiometrics ? _authenticateBiometrics : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
