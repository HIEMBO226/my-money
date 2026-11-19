import '../enums/transaction_type.dart';

class Category {
  const Category({
    required this.id,
    required this.type,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  final String id;
  final TransactionType type;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category copyWith({
    String? id,
    TransactionType? type,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.type == type &&
        other.name == name &&
        other.iconCodePoint == iconCodePoint &&
        other.colorValue == colorValue &&
        other.isDefault == isDefault &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        type,
        name,
        iconCodePoint,
        colorValue,
        isDefault,
        sortOrder,
        createdAt,
        updatedAt,
      );
}
