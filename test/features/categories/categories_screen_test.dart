import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_money/core/theme/app_theme.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/database/database_provider.dart';
import 'package:my_money/features/categories/screens/categories_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;

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
        home: const CategoriesScreen(),
      ),
    );
  }

  testWidgets('seeds and displays default expense and income categories',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Alimentation'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);

    // Switch to Income tab
    await tester.tap(find.text('Revenus'));
    await tester.pumpAndSettle();

    expect(find.text('Salaire'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('allows creating a custom category via dialog', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter une catégorie'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Abonnements');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // Verify category was saved and appears in the expense list.
    expect(find.text('Abonnements'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
