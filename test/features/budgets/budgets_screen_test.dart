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
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/features/accounts/providers/account_providers.dart';
import 'package:my_money/features/budgets/providers/budget_providers.dart';
import 'package:my_money/features/budgets/screens/budgets_screen.dart';
import 'package:my_money/features/categories/providers/category_providers.dart';
import 'package:my_money/features/transactions/providers/transaction_providers.dart';
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
        home: const BudgetsScreen(),
      ),
    );
  }

  testWidgets('renders empty state and creates a budget via dialog',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucun budget défini'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(find.text('Ajouter un budget'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '50000');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Budget mensuel total'), findsOneWidget);
    expect(find.text('Alimentation'), findsOneWidget);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('shows warning and exceeded indicators with WCAG compliance',
      (tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(categoryRepositoryProvider).seedDefaultCategories();
    final accRes = await container.read(accountControllerProvider).create(
          name: 'Espèces',
          type: AccountType.cash,
          iconCodePoint: Icons.payments.codePoint,
          colorValue: 0xFF4CAF50,
        );
    final accId = accRes.dataOrNull!.id;
    final now = DateTime.now();

    final budgetController = container.read(budgetControllerProvider);
    await budgetController.saveBudget(
      categoryId: 'cat_exp_food',
      amountLimit: 10000,
      year: now.year,
      month: now.month,
    );
    await budgetController.saveBudget(
      categoryId: 'cat_exp_transport',
      amountLimit: 10000,
      year: now.year,
      month: now.month,
    );

    final txController = container.read(transactionControllerProvider);
    await txController.create(
      type: TransactionType.expense,
      amount: 8500,
      date: now,
      accountId: accId,
      categoryId: 'cat_exp_food',
    );
    await txController.create(
      type: TransactionType.expense,
      amount: 12000,
      date: now,
      accountId: accId,
      categoryId: 'cat_exp_transport',
    );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('85 %'), findsOneWidget);
    expect(find.text('120 %'), findsOneWidget);
    expect(find.text('Attention : 80 % du budget atteint'), findsOneWidget);
    expect(find.text('Budget dépassé'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
