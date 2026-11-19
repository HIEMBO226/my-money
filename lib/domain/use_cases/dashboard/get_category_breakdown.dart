import '../../entities/category.dart';
import '../../entities/dashboard_summary.dart';
import '../../entities/transaction.dart';
import '../../enums/transaction_type.dart';

class GetCategoryBreakdown {
  const GetCategoryBreakdown();

  /// Computes category totals and percentages for [type] within [startDate]..[endDate].
  List<CategoryBreakdownItem> call({
    required List<Transaction> transactions,
    required Map<String, Category> categoryMap,
    required TransactionType type,
    DateTime? startDate,
    DateTime? endDate,
    String uncategorizedLabel = 'Sans catégorie',
    int uncategorizedIconCodePoint = 0xe148,
    int uncategorizedColorValue = 0xFF607D8B,
  }) {
    if (type == TransactionType.transfer) return const [];

    final totalsByCategory = <String, int>{};
    var grandTotal = 0;

    for (final tx in transactions) {
      if (tx.type != type) continue;
      final localDate = tx.date.toLocal();
      if (startDate != null && localDate.isBefore(startDate)) continue;
      if (endDate != null && localDate.isAfter(endDate)) continue;

      final key = tx.categoryId ?? '__uncategorized__';
      totalsByCategory[key] = (totalsByCategory[key] ?? 0) + tx.amount;
      grandTotal += tx.amount;
    }

    if (grandTotal <= 0) return const [];

    final items = totalsByCategory.entries.map((entry) {
      final category = categoryMap[entry.key];
      return CategoryBreakdownItem(
        categoryId: entry.key,
        categoryName: category?.name ?? uncategorizedLabel,
        iconCodePoint: category?.iconCodePoint ?? uncategorizedIconCodePoint,
        colorValue: category?.colorValue ?? uncategorizedColorValue,
        amount: entry.value,
        percentage: (entry.value / grandTotal) * 100.0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return items;
  }
}
