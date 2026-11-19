class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.colorValue,
    required this.iconCodePoint,
    required this.createdAt,
    required this.updatedAt,
    this.currentAmount = 0,
    this.deadline,
    this.accountId,
  });

  final String id;
  final String name;

  /// Target amount in the smallest currency unit.
  final int targetAmount;

  /// Accumulated amount in the smallest currency unit.
  final int currentAmount;

  /// Optional deadline stored in UTC.
  final DateTime? deadline;
  final String? accountId;
  final int colorValue;
  final int iconCodePoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get remainingAmount =>
      currentAmount >= targetAmount ? 0 : targetAmount - currentAmount;

  double get progress =>
      targetAmount <= 0 ? 0.0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  int get percentage => targetAmount <= 0
      ? 0
      : ((currentAmount / targetAmount) * 100).round();

  bool get isCompleted => currentAmount >= targetAmount;

  int? daysRemaining([DateTime? reference]) {
    if (deadline == null) return null;
    final nowLocal = (reference ?? DateTime.now()).toLocal();
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final deadlineLocal = deadline!.toLocal();
    final deadlineDay =
        DateTime(deadlineLocal.year, deadlineLocal.month, deadlineLocal.day);
    return deadlineDay.difference(today).inDays;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? deadline,
    bool clearDeadline = false,
    String? accountId,
    bool clearAccountId = false,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal &&
        other.id == id &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.deadline == deadline &&
        other.accountId == accountId &&
        other.colorValue == colorValue &&
        other.iconCodePoint == iconCodePoint &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        targetAmount,
        currentAmount,
        deadline,
        accountId,
        colorValue,
        iconCodePoint,
        createdAt,
        updatedAt,
      );
}
