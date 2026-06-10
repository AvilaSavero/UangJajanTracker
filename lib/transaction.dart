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
    final amount = map['amount'];
    final amountDouble = (amount is num) 
        ? amount.toDouble() 
        : (amount is String ? double.tryParse(amount) ?? 0.0 : 0.0);
    
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: amountDouble,
      isIncome: (map['isIncome'] as int) == 1,
      category: map['category'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
