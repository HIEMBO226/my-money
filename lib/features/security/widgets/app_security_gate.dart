import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/security_providers.dart';
import '../screens/lock_screen.dart';

/// Wraps the app to provide:
/// 1. Lock screen overlay when PIN protection is active & locked
/// 2. Privacy curtain when backgrounded/inactive (recent apps overview)
/// 3. Automatic lock after configured inactivity timeout
class AppSecurityGate extends ConsumerStatefulWidget {
  const AppSecurityGate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AppSecurityGate> createState() => _AppSecurityGateState();
}

class _AppSecurityGateState extends ConsumerState<AppSecurityGate>
    with WidgetsBindingObserver {
  bool _showPrivacyCurtain = false;
  DateTime? _backgroundedAt;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer(SecurityState state) {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;

    if (!state.settings.isPinEnabled ||
        state.isLocked ||
        state.settings.inactivityMinutes <= 0) {
      return;
    }

    _inactivityTimer = Timer(
      Duration(minutes: state.settings.inactivityMinutes),
      () {
        if (mounted) {
          ref.read(securityProvider.notifier).lockNow();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final securityState = ref.read(securityProvider);
    final settings = securityState.settings;

    switch (lifecycleState) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (settings.hideInAppSwitcher && !_showPrivacyCurtain) {
          setState(() => _showPrivacyCurtain = true);
        }
      case AppLifecycleState.paused:
        _backgroundedAt = DateTime.now();
        _inactivityTimer?.cancel();
        if (settings.hideInAppSwitcher && !_showPrivacyCurtain) {
          setState(() => _showPrivacyCurtain = true);
        }
        if (settings.isPinEnabled && settings.inactivityMinutes == 0) {
          ref.read(securityProvider.notifier).lockNow();
        }
      case AppLifecycleState.resumed:
        if (_showPrivacyCurtain) {
          setState(() => _showPrivacyCurtain = false);
        }
        if (settings.isPinEnabled && _backgroundedAt != null) {
          final elapsed = DateTime.now().difference(_backgroundedAt!);
          if (elapsed >= Duration(minutes: settings.inactivityMinutes)) {
            ref.read(securityProvider.notifier).lockNow();
          }
        }
        _backgroundedAt = null;
        _resetInactivityTimer(ref.read(securityProvider));
      case AppLifecycleState.detached:
        _inactivityTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);

    ref.listen<SecurityState>(securityProvider, (prev, next) {
      if (prev?.isLocked != next.isLocked ||
          prev?.settings.isPinEnabled != next.settings.isPinEnabled ||
          prev?.settings.inactivityMinutes != next.settings.inactivityMinutes) {
        _resetInactivityTimer(next);
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetInactivityTimer(securityState),
      child: Stack(
        children: [
          widget.child,
          if (securityState.isLocked)
            const Positioned.fill(child: LockScreen()),
          if (_showPrivacyCurtain)
            const Positioned.fill(child: _PrivacyCurtain()),
        ],
      ),
    );
  }
}

class _PrivacyCurtain extends StatelessWidget {
  const _PrivacyCurtain();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
