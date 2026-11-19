import 'package:material_ui/material_ui.dart';

import '../enums/currency.dart';

enum AppDateFormat {
  ddMMyyyy(pattern: 'dd/MM/yyyy', sample: '18/11/2026'),
  mmDDyyyy(pattern: 'MM/dd/yyyy', sample: '11/18/2026'),
  yyyyMMdd(pattern: 'yyyy-MM-dd', sample: '2026-11-18');

  const AppDateFormat({required this.pattern, required this.sample});

  final String pattern;
  final String sample;

  static AppDateFormat fromName(String? value) {
    return AppDateFormat.values.firstWhere(
      (f) => f.name == value,
      orElse: () => AppDateFormat.ddMMyyyy,
    );
  }
}

enum AppThemePreference {
  system,
  light,
  dark;

  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  static AppThemePreference fromName(String? value) {
    return AppThemePreference.values.firstWhere(
      (t) => t.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.currencyCode = 'XOF',
    this.dateFormat = AppDateFormat.ddMMyyyy,
    this.themePreference = AppThemePreference.system,
    this.localeCode = 'fr',
  });

  final String currencyCode;
  final AppDateFormat dateFormat;
  final AppThemePreference themePreference;
  final String localeCode;

  Currency get currency => Currency.fromCode(currencyCode);

  Locale get locale => Locale(localeCode);

  ThemeMode get themeMode => themePreference.toThemeMode();

  AppSettings copyWith({
    String? currencyCode,
    AppDateFormat? dateFormat,
    AppThemePreference? themePreference,
    String? localeCode,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      dateFormat: dateFormat ?? this.dateFormat,
      themePreference: themePreference ?? this.themePreference,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.currencyCode == currencyCode &&
        other.dateFormat == dateFormat &&
        other.themePreference == themePreference &&
        other.localeCode == localeCode;
  }

  @override
  int get hashCode =>
      Object.hash(currencyCode, dateFormat, themePreference, localeCode);
}
