import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/extensions/category_localization_extensions.dart';
import 'package:my_money/domain/entities/category.dart';
import 'package:my_money/domain/entities/dashboard_summary.dart';
import 'package:my_money/domain/enums/transaction_type.dart';
import 'package:my_money/l10n/app_localizations.dart';

void main() {
  group('Category localization tests', () {
    testWidgets('translates default categories accurately in English',
        (tester) async {
      late AppLocalizations l10nEn;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Builder(
            builder: (context) {
              l10nEn = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify the 5 categories specifically highlighted by the user
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_food', name: 'Alimentation'),
        'Food',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_groceries', name: 'Courses'),
        'Groceries',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_housing', name: 'Logement'),
        'Housing',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_bills', name: 'Factures'),
        'Bills',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_education', name: 'Éducation'),
        'Education',
      );

      // Verify other expense & income categories
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_transport', name: 'Transport'),
        'Transportation',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_health', name: 'Santé'),
        'Health',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_leisure', name: 'Loisirs'),
        'Leisure',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_exp_shopping', name: 'Shopping'),
        'Shopping',
      );
      expect(
        l10nEn.categoryLocalizedName(
          id: 'cat_exp_other',
          name: 'Autres dépenses',
        ),
        'Other expenses',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_inc_salary', name: 'Salaire'),
        'Salary',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_inc_freelance', name: 'Freelance'),
        'Freelance',
      );
      expect(
        l10nEn.categoryLocalizedName(
          id: 'cat_inc_investment',
          name: 'Investissements',
        ),
        'Investments',
      );
      expect(
        l10nEn.categoryLocalizedName(id: 'cat_inc_gifts', name: 'Cadeaux'),
        'Gifts',
      );
      expect(
        l10nEn.categoryLocalizedName(
          id: 'cat_inc_other',
          name: 'Autres revenus',
        ),
        'Other income',
      );

      // Verify custom categories keep their name
      expect(
        l10nEn.categoryLocalizedName(
          id: 'custom_123',
          name: 'Abonnement Netflix',
        ),
        'Abonnement Netflix',
      );
    });

    testWidgets('keeps French names when locale is French', (tester) async {
      late AppLocalizations l10nFr;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('fr'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Builder(
            builder: (context) {
              l10nFr = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        l10nFr.categoryLocalizedName(id: 'cat_exp_food', name: 'Alimentation'),
        'Alimentation',
      );
      expect(
        l10nFr.categoryLocalizedName(id: 'cat_exp_groceries', name: 'Courses'),
        'Courses',
      );
      expect(
        l10nFr.categoryLocalizedName(id: 'cat_exp_housing', name: 'Logement'),
        'Logement',
      );
      expect(
        l10nFr.categoryLocalizedName(id: 'cat_exp_bills', name: 'Factures'),
        'Factures',
      );
      expect(
        l10nFr.categoryLocalizedName(id: 'cat_exp_education', name: 'Éducation'),
        'Éducation',
      );
    });

    testWidgets('Category.localizedName works with BuildContext in English',
        (tester) async {
      final now = DateTime.now();
      final category = Category(
        id: 'cat_exp_groceries',
        name: 'Courses',
        type: TransactionType.expense,
        iconCodePoint: 0xe59c,
        colorValue: 0xFF4CAF50,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      late String renderedName;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Builder(
            builder: (context) {
              renderedName = category.localizedName(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(renderedName, 'Groceries');
    });

    testWidgets('CategoryBreakdownItem.localizedName translates in English',
        (tester) async {
      const breakdown = CategoryBreakdownItem(
        categoryId: 'cat_exp_education',
        categoryName: 'Éducation',
        iconCodePoint: 0xe59c,
        colorValue: 0xFF3F51B5,
        amount: 25000,
        percentage: 25.0,
      );

      const uncategorized = CategoryBreakdownItem(
        categoryId: '__uncategorized__',
        categoryName: 'Sans catégorie',
        iconCodePoint: 0xe148,
        colorValue: 0xFF607D8B,
        amount: 10000,
        percentage: 10.0,
      );

      late String breakdownName;
      late String uncategorizedName;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Builder(
            builder: (context) {
              breakdownName = breakdown.localizedName(context);
              uncategorizedName = uncategorized.localizedName(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(breakdownName, 'Education');
      expect(uncategorizedName, 'Uncategorized');
    });
  });
}
