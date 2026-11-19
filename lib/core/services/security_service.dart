import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/entities/security_settings.dart';
import '../errors/app_exception.dart';

abstract interface class SecurityService {
  Future<SecuritySettings> loadSettings();

  Future<void> setPin(String pin);

  Future<bool> verifyPin(String pin);

  Future<void> removePin();

  Future<void> saveSettings(SecuritySettings settings);

  Future<bool> isBiometricsAvailable();

  Future<bool> authenticateWithBiometrics({required String reason});
}

abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class LocalSecurityService implements SecurityService {
  LocalSecurityService({
    SecureKeyValueStore? store,
    LocalAuthentication? localAuth,
  })  : _store = store ?? const FlutterSecureKeyValueStore(),
        _localAuth = localAuth ?? LocalAuthentication();

  final SecureKeyValueStore _store;
  final LocalAuthentication _localAuth;

  static const String _pinHashKey = 'my_money_pin_hash_v1';
  static const String _settingsKey = 'my_money_security_settings_v1';
  static const int pinLength = 4;
  static const int _hashIterations = 10000;

  static List<int> _derivePinHash(String pin, List<int> salt) {
    final pinBytes = utf8.encode(pin);
    var digest = Hmac(sha256, pinBytes).convert([...salt, 1]).bytes;
    for (var i = 1; i < _hashIterations; i++) {
      digest = Hmac(sha256, pinBytes).convert(digest).bytes;
    }
    return digest;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  @override
  Future<SecuritySettings> loadSettings() async {
    try {
      final raw = await _store.read(_settingsKey);
      final hasPin = (await _store.read(_pinHashKey)) != null;
      if (raw == null || raw.isEmpty) {
        return SecuritySettings(isPinEnabled: hasPin);
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SecuritySettings(
        isPinEnabled: hasPin,
        isBiometricsEnabled:
            hasPin && ((map['isBiometricsEnabled'] as bool?) ?? false),
        hideInAppSwitcher: (map['hideInAppSwitcher'] as bool?) ?? true,
        inactivityMinutes: (map['inactivityMinutes'] as int?) ?? 5,
      );
    } on Object {
      return const SecuritySettings();
    }
  }

  @override
  Future<void> saveSettings(SecuritySettings settings) async {
    try {
      final encoded = jsonEncode({
        'isBiometricsEnabled': settings.isBiometricsEnabled,
        'hideInAppSwitcher': settings.hideInAppSwitcher,
        'inactivityMinutes': settings.inactivityMinutes,
      });
      await _store.write(_settingsKey, encoded);
    } on Object {
      // Safely ignore unavailable platform storage in headless tests.
    }
  }

  @override
  Future<void> setPin(String pin) async {
    if (pin.length != pinLength || !RegExp(r'^\d+$').hasMatch(pin)) {
      throw const ValidationException('PIN must be exactly 4 numeric digits.');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = _derivePinHash(pin, salt);
    final payload = jsonEncode({
      'salt': base64Encode(salt),
      'hash': base64Encode(hash),
    });
    await _store.write(_pinHashKey, payload);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final raw = await _store.read(_pinHashKey);
      if (raw == null || raw.isEmpty) return false;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final salt = base64Decode(map['salt'] as String);
      final expectedHash = base64Decode(map['hash'] as String);
      final actualHash = _derivePinHash(pin, salt);
      return _constantTimeEquals(actualHash, expectedHash);
    } on Object {
      return false;
    }
  }

  @override
  Future<void> removePin() async {
    try {
      await _store.delete(_pinHashKey);
      final current = await loadSettings();
      await saveSettings(
        current.copyWith(isPinEnabled: false, isBiometricsEnabled: false),
      );
    } on Object {
      // Ignore unavailable storage in tests.
    }
  }

  @override
  Future<bool> isBiometricsAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics({required String reason}) async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Object {
      return false;
    }
  }
}
