import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database_provider.dart';
import '../../../data/repositories/settings_repository_impl.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/use_cases/export/backup_to_json.dart';
import '../../../domain/use_cases/export/export_csv.dart';
import '../../../domain/use_cases/export/export_pdf.dart';
import '../../../domain/use_cases/export/restore_from_json.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadPersisted();
    return const AppSettings();
  }

  Future<void> _loadPersisted() async {
    final repo = ref.read(settingsRepositoryProvider);
    final loaded = await repo.loadSettings();
    if (ref.mounted) {
      state = loaded;
    }
  }

  Future<void> setCurrency(String currencyCode) async {
    state = state.copyWith(currencyCode: currencyCode);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> setDateFormat(AppDateFormat format) async {
    state = state.copyWith(dateFormat: format);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    state = state.copyWith(themePreference: preference);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> setLocaleCode(String localeCode) async {
    state = state.copyWith(localeCode: localeCode);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

final activeCurrencyCodeProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.currencyCode));
});

final activeDateFormatPatternProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.dateFormat.pattern));
});

final exportCsvUseCaseProvider = Provider<ExportCsv>((ref) {
  return ExportCsv(
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

final exportPdfUseCaseProvider = Provider<ExportPdf>((ref) {
  return ExportPdf(
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

final backupToJsonUseCaseProvider = Provider<BackupToJson>((ref) {
  return BackupToJson(ref.watch(appDatabaseProvider));
});

final restoreFromJsonUseCaseProvider = Provider<RestoreFromJson>((ref) {
  return RestoreFromJson(ref.watch(appDatabaseProvider));
});
