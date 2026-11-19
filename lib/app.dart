import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/recurring/providers/recurring_providers.dart';
import 'features/security/widgets/app_security_gate.dart';
import 'features/settings/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

class MyMoneyApp extends ConsumerWidget {
  const MyMoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Automatically generate any due recurring transactions on app startup.
    ref.watch(processDueRecurringOnStartupProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: goRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,
      builder: (context, child) {
        return AppSecurityGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
