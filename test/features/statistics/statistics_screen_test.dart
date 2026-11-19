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
import 'package:my_money/features/statistics/screens/statistics_screen.dart';
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
        home: const StatisticsScreen(),
      ),
    );
  }

  testWidgets('renders statistics, switches period and type, passes a11y',
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
        );
    final accId = accRes.dataOrNull!.id;

    final txController = container.read(transactionControllerProvider);
    await txController.create(
      type: TransactionType.income,
      amount: 100000,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_inc_salary',
    );
    await txController.create(
      type: TransactionType.expense,
      amount: 25000,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_exp_transport',
    );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Statistiques'), findsOneWidget);
    expect(find.text('Revenus vs Dépenses'), findsOneWidget);
    expect(find.text('75 %'), findsOneWidget);

    // Switch period chip
    await tester.tap(find.text('Ce mois'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
