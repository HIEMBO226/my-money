import 'package:drift/drift.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/enums/transaction_type.dart';
import '../app_database.dart';

class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.colorValue,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final TransactionType type;
  final IconData icon;
  final int colorValue;
  final int sortOrder;
}

abstract final class DefaultCategories {
  static const List<DefaultCategorySeed> items = [
    // Expense categories
    DefaultCategorySeed(
      id: 'cat_exp_food',
      name: 'Alimentation',
      type: TransactionType.expense,
      icon: Icons.restaurant,
      colorValue: 0xFFFF9800,
      sortOrder: 0,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_groceries',
      name: 'Courses',
      type: TransactionType.expense,
      icon: Icons.shopping_cart,
      colorValue: 0xFF4CAF50,
      sortOrder: 1,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_transport',
      name: 'Transport',
      type: TransactionType.expense,
      icon: Icons.directions_car,
      colorValue: 0xFF2196F3,
      sortOrder: 2,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_housing',
      name: 'Logement',
      type: TransactionType.expense,
      icon: Icons.home,
      colorValue: 0xFF795548,
      sortOrder: 3,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_bills',
      name: 'Factures',
      type: TransactionType.expense,
      icon: Icons.receipt_long,
      colorValue: 0xFF607D8B,
      sortOrder: 4,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_health',
      name: 'Santé',
      type: TransactionType.expense,
      icon: Icons.local_hospital,
      colorValue: 0xFFF44336,
      sortOrder: 5,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_leisure',
      name: 'Loisirs',
      type: TransactionType.expense,
      icon: Icons.movie,
      colorValue: 0xFF9C27B0,
      sortOrder: 6,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_shopping',
      name: 'Shopping',
      type: TransactionType.expense,
      icon: Icons.shopping_bag,
      colorValue: 0xFFE91E63,
      sortOrder: 7,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_education',
      name: 'Éducation',
      type: TransactionType.expense,
      icon: Icons.school,
      colorValue: 0xFF3F51B5,
      sortOrder: 8,
    ),
    DefaultCategorySeed(
      id: 'cat_exp_other',
      name: 'Autres dépenses',
      type: TransactionType.expense,
      icon: Icons.category,
      colorValue: 0xFF009688,
      sortOrder: 9,
    ),

    // Income categories
    DefaultCategorySeed(
      id: 'cat_inc_salary',
      name: 'Salaire',
      type: TransactionType.income,
      icon: Icons.work,
      colorValue: 0xFF4CAF50,
      sortOrder: 0,
    ),
    DefaultCategorySeed(
      id: 'cat_inc_freelance',
      name: 'Freelance',
      type: TransactionType.income,
      icon: Icons.laptop_mac,
      colorValue: 0xFF00BCD4,
      sortOrder: 1,
    ),
    DefaultCategorySeed(
      id: 'cat_inc_investment',
      name: 'Investissements',
      type: TransactionType.income,
      icon: Icons.trending_up,
      colorValue: 0xFF2196F3,
      sortOrder: 2,
    ),
    DefaultCategorySeed(
      id: 'cat_inc_gifts',
      name: 'Cadeaux',
      type: TransactionType.income,
      icon: Icons.card_giftcard,
      colorValue: 0xFFFF5722,
      sortOrder: 3,
    ),
    DefaultCategorySeed(
      id: 'cat_inc_other',
      name: 'Autres revenus',
      type: TransactionType.income,
      icon: Icons.attach_money,
      colorValue: 0xFF009688,
      sortOrder: 4,
    ),
  ];

  static List<CategoriesCompanion> toCompanions(int nowMillis) {
    return items
        .map(
          (item) => CategoriesCompanion.insert(
            id: item.id,
            type: item.type.index,
            name: item.name,
            iconCodePoint: item.icon.codePoint,
            colorValue: item.colorValue,
            isDefault: const Value(true),
            sortOrder: Value(item.sortOrder),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
        )
        .toList();
  }
}
