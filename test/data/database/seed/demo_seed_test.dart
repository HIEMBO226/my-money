import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/extensions/date_extensions.dart';
import 'package:my_money/data/database/app_database.dart';
import 'package:my_money/data/database/seed/default_categories.dart';
import 'package:my_money/data/database/seed/demo_seed.dart';
import 'package:my_money/data/repositories/budget_repository_impl.dart';
import 'package:my_money/data/repositories/category_repository_impl.dart';
import 'package:my_money/data/repositories/transaction_repository_impl.dart';
import 'package:my_money/domain/entities/budget.dart';
import 'package:my_money/domain/entities/transaction_filter.dart';
import 'package:my_money/domain/use_cases/budgets/get_budgets.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds 6 months of realistic XOF demo data and is idempotent', () async {
    final fixedNow = DateTime(2026, 6, 15, 12);

    final summary1 = await DemoSeed.seed(
      db,
      currencyCode: 'XOF',
      now: fixedNow,
    );

    expect(summary1.accountsCount, 4);
    expect(summary1.transactionsCount, greaterThanOrEqualTo(60));
    expect(summary1.budgetsCount, 4);
    expect(summary1.recurringCount, 3);
    expect(summary1.goalsCount, 3);

    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final budgets = await db.select(db.budgets).get();
    final recurring = await db.select(db.recurringTransactions).get();
    final goals = await db.select(db.savingsGoals).get();

    expect(accounts.length, 4);
    expect(categories.length, DefaultCategories.items.length);
    expect(transactions.length, summary1.transactionsCount);
    expect(budgets.length, 4);
    expect(recurring.length, 3);
    expect(goals.length, 3);

    // Check budgets cover all 3 alert levels (normal, warning, exceeded).
    final budgetRepo = BudgetRepositoryImpl(db);
    final txRepo = TransactionRepositoryImpl(db);
    final catRepo = CategoryRepositoryImpl(db);
    final getBudgets = GetBudgets(budgetRepo);

    final monthBudgets =
        (await budgetRepo.getBudgetsForMonth(year: 2026, month: 6)).dataOrNull!;
    final monthRef = DateTime(2026, 6);
    final monthTxs = (await txRepo.getTransactions(
      filter: TransactionFilter(
        startDate: monthRef.startOfMonth,
        endDate: monthRef.endOfMonth,
        limit: 500,
      ),
    ))
        .dataOrNull!;
    final allCats = (await catRepo.getCategories()).dataOrNull!;
    final statuses = getBudgets.computeStatuses(
      budgets: monthBudgets,
      monthTransactions: monthTxs,
      categories: allCats,
    );
    final levels = statuses.map((s) => s.alertLevel).toSet();
    expect(
      levels,
      containsAll([
        BudgetAlertLevel.normal,
        BudgetAlertLevel.warning,
        BudgetAlertLevel.exceeded,
      ]),
    );

    // Check recurring items have future due dates relative to fixedNow.
    for (final rec in recurring) {
      expect(
        rec.nextDueDate,
        greaterThan(fixedNow.toUtc().millisecondsSinceEpoch),
      );
    }

    // Re-running seed should be idempotent (no duplicates).
    final summary2 = await DemoSeed.seed(
      db,
      currencyCode: 'XOF',
      now: fixedNow,
    );
    expect(summary2.transactionsCount, summary1.transactionsCount);
    expect((await db.select(db.transactions).get()).length,
        summary1.transactionsCount);
    expect((await db.select(db.accounts).get()).length, 4);
  });

  test('scales amounts appropriately for 2-decimal currencies (EUR)', () async {
    final fixedNow = DateTime(2026, 6, 15, 12);
    await DemoSeed.seed(db, currencyCode: 'EUR', now: fixedNow);

    final txs = await db.select(db.transactions).get();
    // Monthly salary = 2600 EUR = 260000 cents
    final salaries = txs.where((t) => t.categoryId == 'cat_inc_salary');
    expect(salaries, isNotEmpty);
    expect(salaries.first.amount, 260000);
  });

  test('clearAllData removes all user records and keeps default categories',
      () async {
    await DemoSeed.seed(db, currencyCode: 'XOF', now: DateTime(2026, 6, 15));
    expect((await db.select(db.accounts).get()).length, 4);

    await DemoSeed.clearAllData(db);

    expect(await db.select(db.accounts).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.budgets).get(), isEmpty);
    expect(await db.select(db.recurringTransactions).get(), isEmpty);
    expect(await db.select(db.savingsGoals).get(), isEmpty);
    expect(
      (await db.select(db.categories).get()).length,
      DefaultCategories.items.length,
    );
  });
}
