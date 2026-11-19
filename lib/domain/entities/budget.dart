import '../../core/constants/app_constants.dart';
import 'category.dart';

enum BudgetAlertLevel {
  normal,
  warning,
  exceeded,
}

class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.year,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;

  /// Monthly budget limit in the smallest currency unit.
  final int amountLimit;
  final int year;
  final int month;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget copyWith({
    String? id,
    String? categoryId,
    int? amountLimit,
    int? year,
    int? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountLimit: amountLimit ?? this.amountLimit,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.amountLimit == amountLimit &&
        other.year == year &&
        other.month == month &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        categoryId,
        amountLimit,
        year,
        month,
        createdAt,
        updatedAt,
      );
}

class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.spentAmount,
    this.category,
  });

  final Budget budget;
  final Category? category;
  final int spentAmount;

  int get remainingAmount => budget.amountLimit - spentAmount;

  double get ratio =>
      budget.amountLimit <= 0 ? 0.0 : spentAmount / budget.amountLimit;

  double get clampedProgress => ratio.clamp(0.0, 1.0);

  int get percentage => (ratio * 100).round();

  BudgetAlertLevel get alertLevel {
    if (ratio >= AppConstants.budgetCriticalThreshold) {
      return BudgetAlertLevel.exceeded;
    }
    if (ratio >= AppConstants.budgetWarningThreshold) {
      return BudgetAlertLevel.warning;
    }
    return BudgetAlertLevel.normal;
  }
}

class BudgetAlertEvent {
  const BudgetAlertEvent({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.alertLevel,
    required this.spentAmount,
    required this.amountLimit,
    required this.percentage,
  });

  final String budgetId;
  final String categoryId;
  final String categoryName;
  final BudgetAlertLevel alertLevel;
  final int spentAmount;
  final int amountLimit;
  final int percentage;
}
