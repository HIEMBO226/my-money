import '../enums/transaction_type.dart';
import 'attachment.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.toAccountId,
    this.note,
    this.recurringTransactionId,
    this.attachments = const [],
  });

  final String id;
  final TransactionType type;

  /// Amount in the smallest currency unit (strictly positive integer).
  final int amount;

  /// Transaction timestamp stored in UTC.
  final DateTime date;
  final String accountId;
  final String? categoryId;
  final String? toAccountId;
  final String? note;
  final String? recurringTransactionId;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? accountId,
    String? categoryId,
    bool clearCategoryId = false,
    String? toAccountId,
    bool clearToAccountId = false,
    String? note,
    bool clearNote = false,
    String? recurringTransactionId,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      note: clearNote ? null : (note ?? this.note),
      recurringTransactionId:
          recurringTransactionId ?? this.recurringTransactionId,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.date == date &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.toAccountId == toAccountId &&
        other.note == note &&
        other.recurringTransactionId == recurringTransactionId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        type,
        amount,
        date,
        accountId,
        categoryId,
        toAccountId,
        note,
        recurringTransactionId,
        createdAt,
        updatedAt,
      );
}
