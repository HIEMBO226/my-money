import 'transaction.dart';

class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.categoryId,
    required this.categoryName,
    required this.iconCodePoint,
    required this.colorValue,
    required this.amount,
    required this.percentage,
  });

  final String categoryId;
  final String categoryName;
  final int iconCodePoint;
  final int colorValue;

  /// Total amount in the smallest currency unit.
  final int amount;

  /// Percentage share from 0.0 to 100.0.
  final double percentage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryBreakdownItem &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.iconCodePoint == iconCodePoint &&
        other.colorValue == colorValue &&
        other.amount == amount &&
        other.percentage == percentage;
  }

  @override
  int get hashCode => Object.hash(
        categoryId,
        categoryName,
        iconCodePoint,
        colorValue,
        amount,
        percentage,
      );
}

class MonthlyTrendPoint {
  const MonthlyTrendPoint({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  final int year;
  final int month;
  final int income;
  final int expense;

  int get net => income - expense;

  DateTime get date => DateTime(year, month);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyTrendPoint &&
        other.year == year &&
        other.month == month &&
        other.income == income &&
        other.expense == expense;
  }

  @override
  int get hashCode => Object.hash(year, month, income, expense);
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.recentTransactions,
  });

  final int totalBalance;
  final int monthlyIncome;
  final int monthlyExpense;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<MonthlyTrendPoint> monthlyTrend;
  final List<Transaction> recentTransactions;

  int get monthlyNet => monthlyIncome - monthlyExpense;
}
