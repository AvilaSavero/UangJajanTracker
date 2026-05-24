class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String? note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome ? 1 : 0,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIncome: (map['isIncome'] as int) == 1,
      category: map['category'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
