class Budget {
  final int? id;
  final String month; // format: YYYY-MM
  final int? categoryId; // null means total budget
  final double amount;

  Budget({this.id, required this.month, this.categoryId, required this.amount});

  Budget copyWith({int? id, String? month, int? categoryId, double? amount}) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month': month,
      'category_id': categoryId,
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      month: map['month'] as String,
      categoryId: map['category_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
