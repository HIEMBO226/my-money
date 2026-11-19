import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/database/seed/demo_seed.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../routing/route_names.dart';
import '../providers/settings_providers.dart';
import '../widgets/currency_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeLabel(BuildContext context, AppThemePreference pref) {
    final l10n = context.l10n;
    return switch (pref) {
      AppThemePreference.system => l10n.themeSystem,
      AppThemePreference.light => l10n.themeLight,
      AppThemePreference.dark => l10n.themeDark,
    };
  }

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => CurrencyPickerDialog(selectedCode: currentCode),
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setCurrency(selected);
    }
  }

  Future<void> _pickDateFormat(
    BuildContext context,
    WidgetRef ref,
    AppDateFormat current,
  ) async {
    final l10n = context.l10n;
    final selected = await showDialog<AppDateFormat>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dateFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppDateFormat.values.map((format) {
            return ListTile(
              title: Text(format.sample),
              subtitle: Text(format.pattern),
              trailing: format == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop(format),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setDateFormat(selected);
    }
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemePreference current,
  ) async {
    final l10n = context.l10n;
    final selected = await showDialog<AppThemePreference>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemePreference.values.map((pref) {
            return ListTile(
              title: Text(_themeLabel(dialogContext, pref)),
              trailing: pref == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop(pref),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setThemePreference(selected);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String currentLocale,
  ) async {
    final l10n = context.l10n;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageFrench),
              trailing: currentLocale == 'fr' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop('fr'),
            ),
            ListTile(
              title: Text(l10n.languageEnglish),
              trailing: currentLocale == 'en' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(dialogContext).pop('en'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setLocaleCode(selected);
    }
  }

  Future<void> _resetAllData(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetAllDataConfirmTitle),
        content: Text(l10n.resetAllDataConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final db = ref.read(appDatabaseProvider);
      await DemoSeed.clearAllData(db);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allDataReset)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorDatabase)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 96),
        children: [
          _SectionHeader(
            title: l10n.settingsManagementSection,
            theme: theme,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.account_balance_wallet_outlined,
                    color: Color(0xFF3B82F6),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.accountsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(l10n.manageAccountsSubtitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.pushNamed(RouteNames.accounts),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.category_outlined,
                    color: Color(0xFF10B981),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.categoriesTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(l10n.manageCategoriesSubtitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.pushNamed(RouteNames.categories),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.repeat,
                    color: Color(0xFFF97316),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.recurringTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(l10n.manageRecurringSubtitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.pushNamed(RouteNames.recurring),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.savings_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.savingsGoals,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(l10n.manageGoalsSubtitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.pushNamed(RouteNames.goals),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionHeader(
            title: l10n.settingsPreferencesSection,
            theme: theme,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.payments_outlined,
                    color: Color(0xFF0D9488),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${settings.currency.code} (${settings.currency.symbol})',
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      _pickCurrency(context, ref, settings.currencyCode),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.calendar_month_outlined,
                    color: Color(0xFF6366F1),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.dateFormat,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(settings.dateFormat.sample),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      _pickDateFormat(context, ref, settings.dateFormat),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.brightness_6_outlined,
                    color: Color(0xFFF59E0B),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.theme,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(_themeLabel(context, settings.themePreference)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      _pickTheme(context, ref, settings.themePreference),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.language_outlined,
                    color: Color(0xFF06B6D4),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.language,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    settings.localeCode == 'en'
                        ? l10n.languageEnglish
                        : l10n.languageFrench,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickLanguage(context, ref, settings.localeCode),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionHeader(
            title: l10n.settingsSecuritySection,
            theme: theme,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const AppBadge(
                icon: Icons.shield_outlined,
                color: Color(0xFF1E3A8A),
                size: 36,
                iconSize: 18,
              ),
              title: Text(
                l10n.securityTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(l10n.securitySubtitle),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.pushNamed(RouteNames.pinSetup),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionHeader(
            title: l10n.settingsDataSection,
            theme: theme,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.import_export_outlined,
                    color: Color(0xFF64748B),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.exportImportTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(l10n.exportImportSubtitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.pushNamed(RouteNames.exportImport),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const AppBadge(
                    icon: Icons.delete_sweep_outlined,
                    color: Color(0xFFEF4444),
                    size: 36,
                    iconSize: 18,
                  ),
                  title: Text(
                    l10n.resetAllData,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  subtitle: Text(l10n.resetAllDataSubtitle),
                  onTap: () => _resetAllData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.aboutAppSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
