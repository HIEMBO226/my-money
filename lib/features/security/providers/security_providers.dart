import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/security_service.dart';
import '../../../domain/entities/security_settings.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return LocalSecurityService();
});

class SecurityState {
  const SecurityState({
    this.settings = const SecuritySettings(),
    this.isLocked = false,
    this.isBiometricsAvailable = false,
    this.isInitialized = false,
  });

  final SecuritySettings settings;
  final bool isLocked;
  final bool isBiometricsAvailable;
  final bool isInitialized;

  SecurityState copyWith({
    SecuritySettings? settings,
    bool? isLocked,
    bool? isBiometricsAvailable,
    bool? isInitialized,
  }) {
    return SecurityState(
      settings: settings ?? this.settings,
      isLocked: isLocked ?? this.isLocked,
      isBiometricsAvailable:
          isBiometricsAvailable ?? this.isBiometricsAvailable,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SecurityNotifier extends Notifier<SecurityState> {
  @override
  SecurityState build() {
    _initialize();
    return const SecurityState();
  }

  Future<void> _initialize() async {
    final service = ref.read(securityServiceProvider);
    final settings = await service.loadSettings();
    if (!ref.mounted) return;
    // Lock immediately once settings load (before querying biometric hardware).
    state = state.copyWith(
      settings: settings,
      isLocked: settings.isPinEnabled,
      isInitialized: true,
    );
    final biometricsAvailable = await service.isBiometricsAvailable();
    if (!ref.mounted) return;
    state = state.copyWith(isBiometricsAvailable: biometricsAvailable);
  }

  Future<void> setupPin(String pin) async {
    final service = ref.read(securityServiceProvider);
    await service.setPin(pin);
    final updated = state.settings.copyWith(isPinEnabled: true);
    await service.saveSettings(updated);
    if (!ref.mounted) return;
    state = state.copyWith(settings: updated, isLocked: false);
  }

  Future<bool> verifyPin(String pin) {
    return ref.read(securityServiceProvider).verifyPin(pin);
  }

  Future<bool> unlockWithPin(String pin) async {
    final valid = await ref.read(securityServiceProvider).verifyPin(pin);
    if (valid && ref.mounted) {
      state = state.copyWith(isLocked: false);
    }
    return valid;
  }

  Future<bool> unlockWithBiometrics({required String reason}) async {
    if (!state.settings.isBiometricsEnabled || !state.isBiometricsAvailable) {
      return false;
    }
    final authenticated = await ref
        .read(securityServiceProvider)
        .authenticateWithBiometrics(reason: reason);
    if (authenticated && ref.mounted) {
      state = state.copyWith(isLocked: false);
    }
    return authenticated;
  }

  Future<void> removePin() async {
    await ref.read(securityServiceProvider).removePin();
    if (!ref.mounted) return;
    state = state.copyWith(
      settings: state.settings.copyWith(
        isPinEnabled: false,
        isBiometricsEnabled: false,
      ),
      isLocked: false,
    );
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final updated = state.settings.copyWith(isBiometricsEnabled: enabled);
    await ref.read(securityServiceProvider).saveSettings(updated);
    if (!ref.mounted) return;
    state = state.copyWith(settings: updated);
  }

  Future<void> setHideInAppSwitcher(bool enabled) async {
    final updated = state.settings.copyWith(hideInAppSwitcher: enabled);
    await ref.read(securityServiceProvider).saveSettings(updated);
    if (!ref.mounted) return;
    state = state.copyWith(settings: updated);
  }

  Future<void> setInactivityMinutes(int minutes) async {
    final updated = state.settings.copyWith(inactivityMinutes: minutes);
    await ref.read(securityServiceProvider).saveSettings(updated);
    if (!ref.mounted) return;
    state = state.copyWith(settings: updated);
  }

  void lockNow() {
    if (state.settings.isPinEnabled && !state.isLocked) {
      state = state.copyWith(isLocked: true);
    }
  }
}

final securityProvider =
    NotifierProvider<SecurityNotifier, SecurityState>(SecurityNotifier.new);
