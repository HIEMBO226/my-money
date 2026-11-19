import '../../core/constants/app_constants.dart';
import '../enums/transaction_type.dart';

class TransactionFilter {
  const TransactionFilter({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.accountId,
    this.categoryId,
    this.type,
    this.minAmount,
    this.maxAmount,
    this.limit = AppConstants.pageSize,
    this.offset = 0,
  });

  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? accountId;
  final String? categoryId;
  final TransactionType? type;
  final int? minAmount;
  final int? maxAmount;
  final int limit;
  final int offset;

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.trim().isNotEmpty) ||
      startDate != null ||
      endDate != null ||
      accountId != null ||
      categoryId != null ||
      type != null ||
      minAmount != null ||
      maxAmount != null;

  int get activeFilterCount {
    var count = 0;
    if (startDate != null || endDate != null) count++;
    if (accountId != null) count++;
    if (categoryId != null) count++;
    if (type != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }

  TransactionFilter copyWith({
    String? searchQuery,
    bool clearSearchQuery = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? accountId,
    bool clearAccountId = false,
    String? categoryId,
    bool clearCategoryId = false,
    TransactionType? type,
    bool clearType = false,
    int? minAmount,
    bool clearMinAmount = false,
    int? maxAmount,
    bool clearMaxAmount = false,
    int? limit,
    int? offset,
  }) {
    return TransactionFilter(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      type: clearType ? null : (type ?? this.type),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilter &&
        other.searchQuery == searchQuery &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.type == type &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        startDate,
        endDate,
        accountId,
        categoryId,
        type,
        minAmount,
        maxAmount,
        limit,
        offset,
      );
}
