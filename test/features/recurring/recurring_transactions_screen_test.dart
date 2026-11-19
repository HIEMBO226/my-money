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
import 'package:my_money/domain/enums/recurrence_frequency.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/features/accounts/providers/account_providers.dart';
import 'package:my_money/features/categories/providers/category_providers.dart';
import 'package:my_money/features/recurring/providers/recurring_providers.dart';
import 'package:my_money/features/recurring/screens/recurring_transactions_screen.dart';
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
        home: const RecurringTransactionsScreen(),
      ),
    );
  }

  testWidgets('renders recurring list, toggles active state and passes a11y',
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

    await container.read(recurringControllerProvider).create(
          type: TransactionType.expense,
          amount: 120000,
          accountId: accRes.dataOrNull!.id,
          categoryId: 'cat_exp_housing',
          note: 'Loyer',
          frequency: RecurrenceFrequency.monthly,
          nextDueDate: DateTime.now().add(const Duration(days: 10)),
        );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Loyer'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Pause recurring transaction via Switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.textContaining('En pause'), findsOneWidget);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
