import 'package:flutter/widgets.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../l10n/app_localizations.dart';

extension AppLocalizationsCategoryExtension on AppLocalizations {
  /// Returns the localized name for a category based on its [id] or raw [name].
  /// If it is a custom category, [name] is returned untouched.
  String categoryLocalizedName({String? id, required String name}) {
    final lowerId = id?.trim().toLowerCase() ?? '';
    final lowerName = name.trim().toLowerCase();

    if (lowerId == 'cat_exp_food' ||
        lowerName == 'alimentation' ||
        lowerName == 'food') {
      return categoryFood;
    }
    if (lowerId == 'cat_exp_groceries' ||
        lowerName == 'courses' ||
        lowerName == 'groceries') {
      return categoryGroceries;
    }
    if (lowerId == 'cat_exp_transport' ||
        lowerName == 'transport' ||
        lowerName == 'transportation') {
      return categoryTransport;
    }
    if (lowerId == 'cat_exp_housing' ||
        lowerName == 'logement' ||
        lowerName == 'housing') {
      return categoryHousing;
    }
    if (lowerId == 'cat_exp_bills' ||
        lowerName == 'factures' ||
        lowerName == 'bills' ||
        lowerName == 'bills & utilities') {
      return categoryBills;
    }
    if (lowerId == 'cat_exp_health' ||
        lowerName == 'santé' ||
        lowerName == 'sante' ||
        lowerName == 'health' ||
        lowerName == 'healthcare') {
      return categoryHealth;
    }
    if (lowerId == 'cat_exp_leisure' ||
        lowerName == 'loisirs' ||
        lowerName == 'leisure' ||
        lowerName == 'entertainment') {
      return categoryLeisure;
    }
    if (lowerId == 'cat_exp_shopping' ||
        lowerName == 'shopping') {
      return categoryShopping;
    }
    if (lowerId == 'cat_exp_education' ||
        lowerName == 'éducation' ||
        lowerName == 'education') {
      return categoryEducation;
    }
    if (lowerId == 'cat_exp_other' ||
        lowerName == 'autres dépenses' ||
        lowerName == 'autres depenses' ||
        lowerName == 'other expenses') {
      return categoryOtherExpense;
    }
    if (lowerId == 'cat_inc_salary' ||
        lowerName == 'salaire' ||
        lowerName == 'salary') {
      return categorySalary;
    }
    if (lowerId == 'cat_inc_freelance' ||
        lowerName == 'freelance') {
      return categoryFreelance;
    }
    if (lowerId == 'cat_inc_investment' ||
        lowerName == 'investissements' ||
        lowerName == 'investments') {
      return categoryInvestment;
    }
    if (lowerId == 'cat_inc_gifts' ||
        lowerName == 'cadeaux' ||
        lowerName == 'gifts') {
      return categoryGifts;
    }
    if (lowerId == 'cat_inc_other' ||
        lowerName == 'autres revenus' ||
        lowerName == 'other income') {
      return categoryOtherIncome;
    }

    return name;
  }
}

extension CategoryLocalizationExtension on Category {
  /// Returns the localized name of the category for the given [BuildContext].
  String localizedName(BuildContext context) {
    return AppLocalizations.of(context).categoryLocalizedName(id: id, name: name);
  }
}

extension CategoryBreakdownItemLocalizationExtension on CategoryBreakdownItem {
  /// Returns the localized name of the category for this breakdown item.
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (categoryId == '__uncategorized__' ||
        categoryName.toLowerCase() == 'sans catégorie' ||
        categoryName.toLowerCase() == 'uncategorized') {
      return l10n.uncategorized;
    }
    return l10n.categoryLocalizedName(id: categoryId, name: categoryName);
  }
}
