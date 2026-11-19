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
import 'package:my_money/features/goals/providers/goal_providers.dart';
import 'package:my_money/features/goals/screens/goals_list_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    await initializeDateFormatting('fr');
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
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
        home: const GoalsListScreen(),
      ),
    );
  }

  testWidgets('renders goals, accepts contribution to reach 100% and passes a11y',
      (tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(goalControllerProvider).create(
          name: 'Ordinateur',
          targetAmount: 100000,
          currentAmount: 60000,
          deadline: DateTime.now().add(const Duration(days: 30)),
          iconCodePoint: Icons.laptop_mac.codePoint,
          colorValue: 0xFF2196F3,
        );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Ordinateur'), findsOneWidget);
    expect(find.text('60 %'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Contribute remaining 40 000 via dialog
    await tester.tap(find.text('Contribuer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '40000');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Contribuer'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('100 %'), findsOneWidget);
    expect(find.text('Objectif atteint !'), findsWidgets);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
