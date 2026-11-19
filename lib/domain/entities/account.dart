import '../enums/account_type.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
    this.balance = 0,
  });

  final String id;
  final String name;
  final AccountType type;
  final int iconCodePoint;
  final int colorValue;
  final int sortOrder;

  /// Computed balance in the smallest currency unit.
  final int balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    int? iconCodePoint,
    int? colorValue,
    int? sortOrder,
    int? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.iconCodePoint == iconCodePoint &&
        other.colorValue == colorValue &&
        other.sortOrder == sortOrder &&
        other.balance == balance &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        type,
        iconCodePoint,
        colorValue,
        sortOrder,
        balance,
        createdAt,
        updatedAt,
      );
}
