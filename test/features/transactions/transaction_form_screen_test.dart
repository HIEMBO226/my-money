import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_money/core/theme/app_theme.dart';
import 'package:my_money/core/widgets/amount_input_field.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/database/database_provider.dart';
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/features/accounts/providers/account_providers.dart';
import 'package:my_money/features/transactions/providers/transaction_providers.dart';
import 'package:my_money/features/transactions/screens/transaction_form_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp(Widget child) {
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
        home: child,
      ),
    );
  }

  testWidgets('AmountInputField handles decimal EUR input accurately',
      (tester) async {
    var captured = 0;
    await tester.pumpWidget(
      buildTestApp(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AmountInputField(
              currencyCode: 'EUR',
              onChanged: (value) => captured = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_key_1')));
    await tester.tap(find.byKey(const Key('amount_key_2')));
    await tester.tap(find.byKey(const Key('amount_key_.')));
    await tester.tap(find.byKey(const Key('amount_key_5')));
    await tester.pumpAndSettle();

    expect(captured, 1250);

    await tester.tap(find.byKey(const Key('amount_key_backspace')));
    await tester.pumpAndSettle();
    expect(captured, 1200);
  });

  testWidgets('creates an expense using optimized keypad in minimal taps',
      (tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(accountControllerProvider).create(
          name: 'Espèces',
          type: AccountType.cash,
          iconCodePoint: Icons.payments.codePoint,
          colorValue: 0xFF4CAF50,
          initialBalance: 20000,
        );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp(const TransactionFormScreen()));
    await tester.pumpAndSettle();

    // Enter 5 000 FCFA using keypad (5, 0, 00) and tap Save
    await tester.tap(find.byKey(const Key('amount_key_5')));
    await tester.tap(find.byKey(const Key('amount_key_0')));
    await tester.tap(find.byKey(const Key('amount_key_00')));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    final savedResult = await container.read(getTransactionsUseCaseProvider)();
    final savedExpenses = savedResult.dataOrNull!
        .where((tx) => tx.amount == 5000)
        .toList();
    expect(savedExpenses.length, 1);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
