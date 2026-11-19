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
import 'package:my_money/features/transactions/providers/transaction_providers.dart';
import 'package:my_money/features/transactions/screens/transactions_list_screen.dart';
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
        home: const TransactionsListScreen(),
      ),
    );
  }

  testWidgets('displays empty state when there are no transactions',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucune transaction'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('displays grouped transactions and filters via search bar',
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
      type: TransactionType.expense,
      amount: 3500,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_exp_food',
      note: 'Déjeuner boulangerie',
    );
    await txController.create(
      type: TransactionType.income,
      amount: 150000,
      date: DateTime.now(),
      accountId: accId,
      categoryId: 'cat_inc_salary',
      note: 'Virement salaire',
    );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text("Aujourd'hui"), findsOneWidget);
    expect(find.text('Alimentation'), findsOneWidget);
    expect(find.text('Salaire'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Search narrows down list live
    await tester.enterText(find.byType(TextField), 'boulangerie');
    await tester.pumpAndSettle();

    expect(find.text('Alimentation'), findsOneWidget);
    expect(find.text('Salaire'), findsNothing);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
