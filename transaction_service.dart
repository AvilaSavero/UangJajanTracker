import 'package:flutter/foundation.dart';
import 'transaction.dart';

class TransactionService extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  List<Transaction> getTransactionsForDate(DateTime date) {
    return _transactions
        .where((t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day)
        .toList();
  }

  List<Transaction> getTransactionsForMonth(DateTime date) {
    return _transactions
        .where((t) => t.date.year == date.year && t.date.month == date.month)
        .toList();
  }

  double getTotalIncomeForMonth(DateTime date) {
    return getTransactionsForMonth(date)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenseForMonth(DateTime date) {
    return getTransactionsForMonth(date)
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getAverageDailyExpense(DateTime date) {
    final monthTransactions = getTransactionsForMonth(date);
    final expenses = monthTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final daysWithTransactions =
        monthTransactions.map((t) => t.date.day).toSet().length;
    return daysWithTransactions > 0 ? expenses / daysWithTransactions : 0;
  }

  Map<String, double> getCategoryTotalsForMonth(DateTime date) {
    final monthTransactions = getTransactionsForMonth(date);
    final categoryMap = <String, double>{};
    for (final transaction in monthTransactions) {
      if (!transaction.isIncome) {
        categoryMap[transaction.category] =
            (categoryMap[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryMap;
  }

  List<String> getTopCategoriesForMonth(DateTime date, {int limit = 3}) {
    final categories = getCategoryTotalsForMonth(date);
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void updateTransaction(String id, Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void loadSampleData() {
    final now = DateTime.now();
    _transactions.addAll([
      Transaction(
        id: '1',
        title: 'Makan Siang',
        amount: 20000,
        isIncome: false,
        category: 'Makan',
        date: now,
      ),
      Transaction(
        id: '2',
        title: 'Top Up',
        amount: 50000,
        isIncome: true,
        category: 'Top Up',
        date: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '3',
        title: 'Jajan Online',
        amount: 15000,
        isIncome: false,
        category: 'Jajan',
        date: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: '4',
        title: 'Transport',
        amount: 12000,
        isIncome: false,
        category: 'Transport',
        date: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '5',
        title: 'Makan Malam',
        amount: 25000,
        isIncome: false,
        category: 'Makan',
        date: now.subtract(const Duration(days: 4)),
      ),
      Transaction(
        id: '6',
        title: 'Jajan Minuman',
        amount: 8500,
        isIncome: false,
        category: 'Jajan',
        date: now.subtract(const Duration(days: 5)),
      ),
    ]);
    notifyListeners();
  }
}
