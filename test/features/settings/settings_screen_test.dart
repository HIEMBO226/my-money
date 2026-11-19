import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_money/core/theme/app_theme.dart';
import 'package:my_money/domain/entities/app_settings.dart';
import 'package:my_money/domain/repositories/settings_repository.dart';
import 'package:my_money/features/settings/providers/settings_providers.dart';
import 'package:my_money/features/settings/screens/settings_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  AppSettings _stored = const AppSettings();

  @override
  Future<AppSettings> loadSettings() async => _stored;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _stored = settings;
  }
}

void main() {
  testWidgets('renders settings, updates currency and passes WCAG checks',
      (tester) async {
    final repo = _InMemorySettingsRepository();

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('XOF (FCFA)'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Change currency to EUR
    await tester.scrollUntilVisible(find.text('Devise'), 200);
    await tester.tap(find.text('Devise'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Euro (EUR)'));
    await tester.pumpAndSettle();

    expect(find.text('EUR (€)'), findsOneWidget);

    semantics.dispose();
  });
}
