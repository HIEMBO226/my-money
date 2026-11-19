import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _settingsKey = 'my_money_app_settings_v1';

  @override
  Future<AppSettings> loadSettings() async {
    try {
      final raw = await _storage.read(key: _settingsKey);
      if (raw == null || raw.isEmpty) return const AppSettings();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings(
        currencyCode: (map['currencyCode'] as String?) ?? 'XOF',
        dateFormat: AppDateFormat.fromName(map['dateFormat'] as String?),
        themePreference:
            AppThemePreference.fromName(map['themePreference'] as String?),
        localeCode: (map['localeCode'] as String?) ?? 'fr',
      );
    } on Object {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final encoded = jsonEncode({
        'currencyCode': settings.currencyCode,
        'dateFormat': settings.dateFormat.name,
        'themePreference': settings.themePreference.name,
        'localeCode': settings.localeCode,
      });
      await _storage.write(key: _settingsKey, value: encoded);
    } on Object {
      // Safely ignore unavailable platform storage in headless tests.
    }
  }
}
