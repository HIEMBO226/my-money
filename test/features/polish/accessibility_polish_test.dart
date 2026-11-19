import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_money/core/theme/app_theme.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/database/database_provider.dart';
import 'package:my_money/data/database/seed/demo_seed.dart';
import 'package:my_money/domain/entities/app_settings.dart';
import 'package:my_money/domain/repositories/settings_repository.dart';
import 'package:my_money/features/budgets/screens/budgets_screen.dart';
import 'package:my_money/features/dashboard/screens/dashboard_screen.dart';
import 'package:my_money/features/settings/providers/settings_providers.dart';
import 'package:my_money/features/settings/screens/settings_screen.dart';
import 'package:my_money/features/transactions/screens/transactions_list_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  _InMemorySettingsRepository()
      : _stored = const AppSettings(dateFormat: AppDateFormat.yyyyMMdd);

  AppSettings _stored;

  @override
  Future<AppSettings> loadSettings() async => _stored;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _stored = settings;
  }
}

void main() {
  late AppDatabase db;

  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DemoSeed.seed(db, currencyCode: 'EUR');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildDarkScaledApp(
    Widget home, {
    double textScale = 1.6,
    SettingsRepository? settingsRepo,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWithValue(
          settingsRepo ?? _InMemorySettingsRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          );
        },
        home: home,
      ),
    );
  }

  Future<void> cleanupDriftTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('DashboardScreen passes WCAG in dark mode at 1.6x text scale',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildDarkScaledApp(const DashboardScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await cleanupDriftTree(tester);
  });

  testWidgets(
      'TransactionsListScreen passes WCAG in dark mode at 1.6x text scale',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildDarkScaledApp(const TransactionsListScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await cleanupDriftTree(tester);
  });

  testWidgets('BudgetsScreen passes WCAG in dark mode at 1.6x text scale',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildDarkScaledApp(const BudgetsScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await cleanupDriftTree(tester);
  });

  testWidgets(
      'SettingsScreen hides demo seed action, shows reset & passes dark mode WCAG',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildDarkScaledApp(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Scroll to the data section and verify demo seed is gone while reset remains.
    await tester.scrollUntilVisible(
      find.text('Réinitialiser toutes les données'),
      250,
    );
    expect(find.text('Charger les données de démonstration'), findsNothing);
    expect(find.text('Réinitialiser toutes les données'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('My money'), 200);
    expect(find.text('My money'), findsOneWidget);

    semantics.dispose();
    await cleanupDriftTree(tester);
  });
}
