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
import 'package:my_money/domain/enums/account_type.dart';
import 'package:my_money/features/accounts/providers/account_providers.dart';
import 'package:my_money/features/accounts/screens/accounts_list_screen.dart';
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
        home: const AccountsListScreen(),
      ),
    );
  }

  testWidgets('displays empty state when no accounts exist', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucun compte'), findsOneWidget);
    expect(find.text('Ajouter un compte'), findsWidgets);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('renders accounts and total balance reactively', (tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final controller = container.read(accountControllerProvider);
    await controller.create(
      name: 'Compte courant',
      type: AccountType.bank,
      iconCodePoint: Icons.account_balance.codePoint,
      colorValue: 0xFF2196F3,
      initialBalance: 50000,
    );
    await controller.create(
      name: 'Orange Money',
      type: AccountType.mobileMoney,
      iconCodePoint: Icons.phone_android.codePoint,
      colorValue: 0xFFFF9800,
      initialBalance: 25000,
    );

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Compte courant'), findsOneWidget);
    expect(find.text('Orange Money'), findsOneWidget);
    expect(find.text('Solde total'), findsOneWidget);
    // Transfer action appears when >= 2 accounts exist.
    expect(find.byTooltip('Transférer'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
