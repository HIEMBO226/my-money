import 'package:drift/drift.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/enums/account_type.dart';
import '../../../domain/enums/currency.dart';
import '../../../domain/enums/recurrence_frequency.dart';
import '../../../domain/enums/transaction_type.dart';
import '../app_database.dart';
import 'default_categories.dart';

class DemoSeedSummary {
  const DemoSeedSummary({
    required this.accountsCount,
    required this.transactionsCount,
    required this.budgetsCount,
    required this.recurringCount,
    required this.goalsCount,
  });

  final int accountsCount;
  final int transactionsCount;
  final int budgetsCount;
  final int recurringCount;
  final int goalsCount;
}

/// Populates a realistic 6-month offline dataset for demonstration and QA.
/// Exposed in the UI strictly in `kDebugMode`.
abstract final class DemoSeed {
  static const String _bankAccountId = 'demo_acc_bank';
  static const String _cashAccountId = 'demo_acc_cash';
  static const String _mobileMoneyAccountId = 'demo_acc_mobile';
  static const String _savingsAccountId = 'demo_acc_savings';

  /// Scales a nominal "euro-like" integer amount into the target currency's
  /// smallest integer unit so demo figures look natural for both XOF (0 dec)
  /// and EUR/USD/etc. (2-3 dec).
  static int _scaleAmount(int euroEquivalent, Currency currency) {
    if (currency.decimalDigits == 0) {
      // Roughly 1 EUR ≈ 650 FCFA, rounded cleanly to multiples of 500
      return euroEquivalent * 500;
    }
    return euroEquivalent * currency.smallestUnitMultiplier;
  }

  static Future<DemoSeedSummary> seed(
    AppDatabase db, {
    required String currencyCode,
    DateTime? now,
  }) async {
    final currency = Currency.fromCode(currencyCode);
    final referenceLocal = (now ?? DateTime.now()).toLocal();
    final nowUtcMillis = referenceLocal.toUtc().millisecondsSinceEpoch;

    int a(int euroUnits) => _scaleAmount(euroUnits, currency);

    return db.transaction(() async {
      // 1. Ensure default categories exist.
      await db.batch((batch) {
        batch.insertAll(
          db.categories,
          DefaultCategories.toCompanions(nowUtcMillis),
          mode: InsertMode.insertOrIgnore,
        );
      });

      // 2. Remove any previous demo rows cleanly in FK-safe order.
      await (db.delete(db.transactions)
            ..where((t) => t.id.like('demo_%')))
          .go();
      await (db.delete(db.budgets)..where((b) => b.id.like('demo_%'))).go();
      await (db.delete(db.recurringTransactions)
            ..where((r) => r.id.like('demo_%')))
          .go();
      await (db.delete(db.savingsGoals)..where((g) => g.id.like('demo_%')))
          .go();
      await (db.delete(db.accounts)..where((ac) => ac.id.like('demo_%'))).go();

      // 3. Seed 4 diverse accounts.
      final accounts = [
        AccountsCompanion.insert(
          id: _bankAccountId,
          name: 'Compte courant',
          type: AccountType.bank.index,
          iconCodePoint: Icons.account_balance.codePoint,
          colorValue: 0xFF1565C0,
          sortOrder: const Value(0),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        AccountsCompanion.insert(
          id: _cashAccountId,
          name: 'Espèces',
          type: AccountType.cash.index,
          iconCodePoint: Icons.payments.codePoint,
          colorValue: 0xFF2E7D32,
          sortOrder: const Value(1),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        AccountsCompanion.insert(
          id: _mobileMoneyAccountId,
          name: 'Mobile Money',
          type: AccountType.mobileMoney.index,
          iconCodePoint: Icons.phone_android.codePoint,
          colorValue: 0xFFEF6C00,
          sortOrder: const Value(2),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        AccountsCompanion.insert(
          id: _savingsAccountId,
          name: 'Épargne',
          type: AccountType.savings.index,
          iconCodePoint: Icons.savings.codePoint,
          colorValue: 0xFF00796B,
          sortOrder: const Value(3),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
      ];

      await db.batch((batch) {
        batch.insertAll(
          db.accounts,
          accounts,
          mode: InsertMode.insertOrReplace,
        );
      });

      // 4. Seed 6 months of realistic transactions (UTC timestamps).
      final transactions = <TransactionsCompanion>[];
      int txSeq = 0;

      void addTx({
        required TransactionType type,
        required int amountUnits,
        required DateTime localDate,
        required String accountId,
        String? categoryId,
        String? toAccountId,
        String? note,
      }) {
        // Clamp future dates inside current month to today so the ledger stays realistic.
        final clampedLocal = localDate.isAfter(referenceLocal)
            ? DateTime(
                referenceLocal.year,
                referenceLocal.month,
                referenceLocal.day,
                localDate.hour,
                localDate.minute,
              )
            : localDate;
        txSeq++;
        transactions.add(
          TransactionsCompanion.insert(
            id: 'demo_tx_${txSeq.toString().padLeft(3, '0')}',
            type: type.index,
            amount: a(amountUnits),
            date: clampedLocal.toUtc().millisecondsSinceEpoch,
            accountId: accountId,
            categoryId: Value(categoryId),
            toAccountId: Value(toAccountId),
            note: Value(note),
            createdAt: nowUtcMillis,
            updatedAt: nowUtcMillis,
          ),
        );
      }

      // Generate 5 previous months + current month (offset 5 down to 0).
      for (int offset = 5; offset >= 0; offset--) {
        final monthDate = DateTime(
          referenceLocal.year,
          referenceLocal.month - offset,
        );
        final y = monthDate.year;
        final m = monthDate.month;
        final isCurrentMonth = offset == 0;

        // Salary on the 1st of each month
        addTx(
          type: TransactionType.income,
          amountUnits: 2600,
          localDate: DateTime(y, m, 1, 9),
          accountId: _bankAccountId,
          categoryId: 'cat_inc_salary',
          note: 'Salaire mensuel',
        );

        // Occasional freelance income on even offsets
        if (offset.isEven) {
          addTx(
            type: TransactionType.income,
            amountUnits: 420 + (offset * 40),
            localDate: DateTime(y, m, isCurrentMonth ? 3 : 14, 15),
            accountId: _mobileMoneyAccountId,
            categoryId: 'cat_inc_freelance',
            note: 'Mission conseil',
          );
        }

        // Housing / rent
        addTx(
          type: TransactionType.expense,
          amountUnits: 850,
          localDate: DateTime(y, m, 2, 10),
          accountId: _bankAccountId,
          categoryId: 'cat_exp_housing',
          note: 'Loyer mensuel',
        );

        // Utilities / bills
        addTx(
          type: TransactionType.expense,
          amountUnits: 110 + (offset % 3) * 15,
          localDate: DateTime(y, m, isCurrentMonth ? 4 : 6, 11),
          accountId: _bankAccountId,
          categoryId: 'cat_exp_bills',
          note: 'Électricité & Internet',
        );

        // Groceries (2 entries per month)
        addTx(
          type: TransactionType.expense,
          amountUnits: 165,
          localDate: DateTime(y, m, isCurrentMonth ? 3 : 8, 17, 30),
          accountId: _bankAccountId,
          categoryId: 'cat_exp_groceries',
          note: 'Supermarché',
        );
        addTx(
          type: TransactionType.expense,
          amountUnits: 140 + (offset % 2) * 20,
          localDate: DateTime(y, m, isCurrentMonth ? 5 : 21, 18),
          accountId: _cashAccountId,
          categoryId: 'cat_exp_groceries',
          note: 'Marché hebdomadaire',
        );

        // Food / restaurants
        addTx(
          type: TransactionType.expense,
          amountUnits: 85,
          localDate: DateTime(y, m, isCurrentMonth ? 2 : 11, 13),
          accountId: _cashAccountId,
          categoryId: 'cat_exp_food',
          note: 'Déjeuners bureau',
        );
        addTx(
          type: TransactionType.expense,
          amountUnits: 60,
          localDate: DateTime(y, m, isCurrentMonth ? 6 : 19, 20, 15),
          accountId: _mobileMoneyAccountId,
          categoryId: 'cat_exp_food',
          note: 'Dîner entre amis',
        );

        // Transport
        addTx(
          type: TransactionType.expense,
          amountUnits: 90,
          localDate: DateTime(y, m, isCurrentMonth ? 3 : 9, 8, 30),
          accountId: _mobileMoneyAccountId,
          categoryId: 'cat_exp_transport',
          note: 'Abonnement transport & carburant',
        );

        // Leisure (higher in current month to showcase >100% budget alert)
        addTx(
          type: TransactionType.expense,
          amountUnits: isCurrentMonth ? 165 : 95,
          localDate: DateTime(y, m, isCurrentMonth ? 4 : 16, 19),
          accountId: _bankAccountId,
          categoryId: 'cat_exp_leisure',
          note: isCurrentMonth ? 'Concert & cinéma' : 'Sorties week-end',
        );

        // Health or shopping
        if (offset % 2 == 1) {
          addTx(
            type: TransactionType.expense,
            amountUnits: 75,
            localDate: DateTime(y, m, 15, 16),
            accountId: _bankAccountId,
            categoryId: 'cat_exp_health',
            note: 'Pharmacie',
          );
        } else {
          addTx(
            type: TransactionType.expense,
            amountUnits: 120,
            localDate: DateTime(y, m, isCurrentMonth ? 5 : 22, 14, 30),
            accountId: _bankAccountId,
            categoryId: 'cat_exp_shopping',
            note: 'Vêtements',
          );
        }

        // Transfers: Bank -> Savings & Bank -> Cash/Mobile Money
        addTx(
          type: TransactionType.transfer,
          amountUnits: 400,
          localDate: DateTime(y, m, isCurrentMonth ? 2 : 5, 12),
          accountId: _bankAccountId,
          toAccountId: _savingsAccountId,
          note: 'Épargne mensuelle',
        );
        addTx(
          type: TransactionType.transfer,
          amountUnits: 250,
          localDate: DateTime(y, m, 1, 14),
          accountId: _bankAccountId,
          toAccountId: _cashAccountId,
          note: 'Retrait espèces',
        );
        addTx(
          type: TransactionType.transfer,
          amountUnits: 150,
          localDate: DateTime(y, m, 2, 16),
          accountId: _bankAccountId,
          toAccountId: _mobileMoneyAccountId,
          note: 'Recharge Mobile Money',
        );
      }

      await db.batch((batch) {
        batch.insertAll(
          db.transactions,
          transactions,
          mode: InsertMode.insertOrReplace,
        );
      });

      // 5. Seed current-month budgets covering normal, warning (>=80%), and exceeded (>=100%).
      final currentYear = referenceLocal.year;
      final currentMonth = referenceLocal.month;
      final demoBudgets = [
        // Food spent = 145 -> limit 250 (~58%, normal)
        ('demo_bgt_food', 'cat_exp_food', 250),
        // Groceries spent = 305 -> limit 350 (~87%, warning)
        ('demo_bgt_groceries', 'cat_exp_groceries', 350),
        // Leisure spent = 165 -> limit 150 (110%, exceeded)
        ('demo_bgt_leisure', 'cat_exp_leisure', 150),
        // Transport spent = 90 -> limit 200 (45%, normal)
        ('demo_bgt_transport', 'cat_exp_transport', 200),
      ];

      for (final (id, categoryId, limitUnits) in demoBudgets) {
        // Delete any non-demo budget on the same unique (year, month, category) key.
        await (db.delete(db.budgets)
              ..where(
                (b) =>
                    b.year.equals(currentYear) &
                    b.month.equals(currentMonth) &
                    b.categoryId.equals(categoryId),
              ))
            .go();

        await db.into(db.budgets).insert(
              BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                amountLimit: a(limitUnits),
                year: currentYear,
                month: currentMonth,
                createdAt: nowUtcMillis,
                updatedAt: nowUtcMillis,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 6. Seed 3 upcoming recurring rules (future nextDueDate so startup does not duplicate).
      final nextMonthFirst = DateTime(currentYear, currentMonth + 1, 1, 9);
      final nextMonthSecond = DateTime(currentYear, currentMonth + 1, 2, 10);
      final nextWeek = referenceLocal.add(const Duration(days: 7));

      final recurring = [
        RecurringTransactionsCompanion.insert(
          id: 'demo_rec_salary',
          type: TransactionType.income.index,
          amount: a(2600),
          accountId: _bankAccountId,
          categoryId: const Value('cat_inc_salary'),
          note: const Value('Salaire mensuel'),
          frequency: RecurrenceFrequency.monthly.index,
          nextDueDate: nextMonthFirst.toUtc().millisecondsSinceEpoch,
          isActive: const Value(true),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        RecurringTransactionsCompanion.insert(
          id: 'demo_rec_rent',
          type: TransactionType.expense.index,
          amount: a(850),
          accountId: _bankAccountId,
          categoryId: const Value('cat_exp_housing'),
          note: const Value('Loyer mensuel'),
          frequency: RecurrenceFrequency.monthly.index,
          nextDueDate: nextMonthSecond.toUtc().millisecondsSinceEpoch,
          isActive: const Value(true),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        RecurringTransactionsCompanion.insert(
          id: 'demo_rec_streaming',
          type: TransactionType.expense.index,
          amount: a(18),
          accountId: _mobileMoneyAccountId,
          categoryId: const Value('cat_exp_leisure'),
          note: const Value('Abonnement streaming'),
          frequency: RecurrenceFrequency.weekly.index,
          nextDueDate: nextWeek.toUtc().millisecondsSinceEpoch,
          isActive: const Value(false),
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
      ];

      await db.batch((batch) {
        batch.insertAll(
          db.recurringTransactions,
          recurring,
          mode: InsertMode.insertOrReplace,
        );
      });

      // 7. Seed 3 savings goals (in progress, early progress, completed).
      final goals = [
        SavingsGoalsCompanion.insert(
          id: 'demo_goal_emergency',
          name: "Fonds d'urgence",
          targetAmount: a(3000),
          currentAmount: Value(a(1950)),
          deadline: Value(
            referenceLocal
                .add(const Duration(days: 180))
                .toUtc()
                .millisecondsSinceEpoch,
          ),
          accountId: const Value(_savingsAccountId),
          colorValue: 0xFF00796B,
          iconCodePoint: Icons.savings.codePoint,
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        SavingsGoalsCompanion.insert(
          id: 'demo_goal_vacation',
          name: "Vacances d'été",
          targetAmount: a(1200),
          currentAmount: Value(a(420)),
          deadline: Value(
            referenceLocal
                .add(const Duration(days: 120))
                .toUtc()
                .millisecondsSinceEpoch,
          ),
          accountId: const Value(_savingsAccountId),
          colorValue: 0xFF1565C0,
          iconCodePoint: Icons.flight.codePoint,
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
        SavingsGoalsCompanion.insert(
          id: 'demo_goal_phone',
          name: 'Nouveau téléphone',
          targetAmount: a(600),
          currentAmount: Value(a(600)),
          deadline: Value(
            referenceLocal
                .add(const Duration(days: 30))
                .toUtc()
                .millisecondsSinceEpoch,
          ),
          colorValue: 0xFF2E7D32,
          iconCodePoint: Icons.phone_android.codePoint,
          createdAt: nowUtcMillis,
          updatedAt: nowUtcMillis,
        ),
      ];

      await db.batch((batch) {
        batch.insertAll(
          db.savingsGoals,
          goals,
          mode: InsertMode.insertOrReplace,
        );
      });

      return DemoSeedSummary(
        accountsCount: accounts.length,
        transactionsCount: transactions.length,
        budgetsCount: demoBudgets.length,
        recurringCount: recurring.length,
        goalsCount: goals.length,
      );
    });
  }

  /// Clears all user data in FK-safe order and restores the default categories.
  static Future<void> clearAllData(AppDatabase db) async {
    final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.delete(db.attachments).go();
      await db.delete(db.transactions).go();
      await db.delete(db.budgets).go();
      await db.delete(db.recurringTransactions).go();
      await db.delete(db.savingsGoals).go();
      await db.delete(db.accounts).go();
      await db.delete(db.categories).go();

      await db.batch((batch) {
        batch.insertAll(
          db.categories,
          DefaultCategories.toCompanions(nowUtcMillis),
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }
}
