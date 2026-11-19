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
import 'package:my_money/features/categories/providers/category_providers.dart';
import 'package:my_money/features/dashboard/screens/dashboard_screen.dart';
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
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets('renders populated dashboard with charts and passes a11y checks',
      (tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(categoryRepositoryProvider).seedDefaultCategories();
    final accRes = await container.read(accountControllerProvider).create(
          name: 'Banque',
          type: AccountType.bank,
          iconCodePoint: Icons.account_balance.codePoint,
          colorValue: 0xFF2196F3,
          initialBalance: 100000,
        );
    final accId = accRes.dataOrNull!.id;

    final txController = container.read(transactionControllerProvider);
    await txController.create(
      type: TransactionType.income,
      amount: 200000,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_inc_salary',
    );
    await txController.create(
      type: TransactionType.expense,
      amount: 45000,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_exp_food',
      note: 'Courses semaine',
    );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('My money'), findsOneWidget);
    expect(find.text('Solde total'), findsOneWidget);
    expect(find.text('Revenus du mois'), findsOneWidget);
    expect(find.text('Dépenses du mois'), findsOneWidget);
    expect(find.text('Dépenses par catégorie'), findsOneWidget);
    expect(find.text('Alimentation'), findsWidgets);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
