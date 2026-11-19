import '../enums/recurrence_frequency.dart';
import '../enums/transaction_type.dart';

class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.frequency,
    required this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.toAccountId,
    this.note,
    this.endDate,
    this.isActive = true,
  });

  final String id;
  final TransactionType type;

  /// Amount in the smallest currency unit.
  final int amount;
  final String accountId;
  final String? categoryId;
  final String? toAccountId;
  final String? note;
  final RecurrenceFrequency frequency;

  /// Next scheduled execution timestamp in UTC.
  final DateTime nextDueDate;

  /// Optional inclusive end date in UTC.
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Computes the next UTC due date from [current], clamping month-end days
  /// cleanly (e.g. Jan 31 -> Feb 28/29, Feb 29 -> Feb 28 on non-leap years).
  static DateTime computeNextDueDate(
    DateTime current,
    RecurrenceFrequency frequency,
  ) {
    final utc = current.toUtc();
    return switch (frequency) {
      RecurrenceFrequency.daily => DateTime.utc(
          utc.year,
          utc.month,
          utc.day + 1,
          utc.hour,
          utc.minute,
          utc.second,
        ),
      RecurrenceFrequency.weekly => DateTime.utc(
          utc.year,
          utc.month,
          utc.day + 7,
          utc.hour,
          utc.minute,
          utc.second,
        ),
      RecurrenceFrequency.monthly => _addMonthsClamped(utc, 1),
      RecurrenceFrequency.yearly => _addMonthsClamped(utc, 12),
    };
  }

  static DateTime _addMonthsClamped(DateTime utc, int monthsToAdd) {
    final zeroBasedMonth = (utc.month - 1) + monthsToAdd;
    final targetYear = utc.year + (zeroBasedMonth ~/ 12);
    final targetMonth = (zeroBasedMonth % 12) + 1;
    final lastDayOfTargetMonth = DateTime.utc(targetYear, targetMonth + 1, 0).day;
    final clampedDay =
        utc.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : utc.day;

    return DateTime.utc(
      targetYear,
      targetMonth,
      clampedDay,
      utc.hour,
      utc.minute,
      utc.second,
    );
  }

  RecurringTransaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? accountId,
    String? categoryId,
    bool clearCategoryId = false,
    String? toAccountId,
    bool clearToAccountId = false,
    String? note,
    bool clearNote = false,
    RecurrenceFrequency? frequency,
    DateTime? nextDueDate,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      note: clearNote ? null : (note ?? this.note),
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringTransaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.toAccountId == toAccountId &&
        other.note == note &&
        other.frequency == frequency &&
        other.nextDueDate == nextDueDate &&
        other.endDate == endDate &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        type,
        amount,
        accountId,
        categoryId,
        toAccountId,
        note,
        frequency,
        nextDueDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
      );
}
