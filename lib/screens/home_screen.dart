import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Pengguna';
  Map<String, dynamic>? _summaryData;
  bool _isLoadingSummary = true;

  late final List<_TransactionData> _transactions = [
    _TransactionData('Makan Siang', 20000, false),
    _TransactionData('Top Up', 50000, true),
    _TransactionData('Jajan Online', 15000, false),
    _TransactionData('Transport', 12000, false),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final user = await ApiService.getCurrentUser();
      final summary = await ApiService.getSummary();
      if (!mounted) return;
      setState(() {
        _userName = (user?['name'] as String?) ?? 'Pengguna';
        _summaryData = summary;
        _isLoadingSummary = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSummary = false);
    }
  }

  void _addTransaction(dynamic data) {
    setState(() {
      if (data is Map) {
        _transactions.insert(
          0,
          _TransactionData(
            data['title'] as String,
            data['amount'] as double,
            data['isIncome'] as bool,
            dateTime: DateTime.now(),
          ),
        );
      }
    });
  }

  double get _totalIncome {
    final value = _summaryData?['data']?['total_income'];
    return (value is num ? value : 0).toDouble();
  }

  double get _totalExpense {
    final value = _summaryData?['data']?['total_expense'];
    return (value is num ? value : 0).toDouble();
  }

  double get _balanceValue {
    final value = _summaryData?['data']?['balance'];
    return (value is num ? value : 2450000).toDouble();
  }

  double get _savedAmount => _totalIncome - _totalExpense;

  double get _monthlyLimit {
    final value = _summaryData?['data']?['spending_limit']?['monthly_limit'];
    return (value is num ? value : 1000000).toDouble();
  }

  double get _limitUsage => (_monthlyLimit > 0 ? (_totalExpense / _monthlyLimit).clamp(0, 1) : 0);

  String get _limitStatus {
    if (_limitUsage < 0.5) {
      return 'Masih aman bro, penggunaan rendah.';
    }
    if (_limitUsage < 0.8) {
      return 'Hampir setengah batas, jaga pengeluaran.';
    }
    return 'Waspada! Penggunaan mendekati limit.';
  }

  Color get _limitColor {
    if (_limitUsage < 0.5) return Colors.green;
    if (_limitUsage < 0.8) return Colors.orange;
    return Colors.red;
  }

  String _formatRupiah(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  String _formatTransactionTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (txDate == today) {
      return 'Hari ini • $time';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin • $time';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} • $time';
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, StatisticsScreen.routeName);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionScreen(
            onTransactionAdded: _addTransaction,
          ),
        ),
      );
    } else if (index == 3) {
      // Index 3 adalah Riwayat (History)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _HistoryScreen(transactions: _transactions),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            transactionCount: _transactions.length,
            spendingLimit: _monthlyLimit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildLimitCard(),
            const SizedBox(height: 20),
            _buildCategorySection(),
            const SizedBox(height: 20),
            _buildTransactionSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                onTransactionAdded: _addTransaction,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hai, $_userName',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _isLoadingSummary
                        ? 'Memuat ringkasan terbaru...'
                        : 'Lihat ringkasan pengeluaran dan limit hari ini.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.account_circle,
                  size: 36, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.green[600],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(_formatRupiah(_balanceValue),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.13),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Ringkasan Mingguan',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('Grafik placeholder',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(
                    'Pemasukan', _formatRupiah(_totalIncome), Colors.green),
                _summaryItem(
                    'Pengeluaran', _formatRupiah(_totalExpense), Colors.red),
                _summaryItem(
                    'Tabungan',
                    _formatRupiah(_savedAmount < 0 ? 0 : _savedAmount),
                    Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard() {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batas Pengeluaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Limit Anda',
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(_monthlyLimit),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Terpakai',
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('${(_limitUsage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: _limitColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: _limitUsage,
                minHeight: 10,
                valueColor: AlwaysStoppedAnimation<Color>(_limitColor),
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 12),
            Text(_limitStatus,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _limitColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _categoryTile(Icons.upload, 'Top Up', Colors.green, 'Top Up'),
            _categoryTile(Icons.fastfood, 'Makan', Colors.orange, 'Makan'),
            _categoryTile(
                Icons.local_grocery_store, 'Jajan', Colors.purple, 'Jajan'),
            _categoryTile(
                Icons.directions_bus, 'Transport', Colors.blue, 'Transport'),
          ],
        ),
      ],
    );
  }

  Widget _categoryTile(
      IconData icon, String title, Color color, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTransactionScreen(
              onTransactionAdded: _addTransaction,
              preSelectedCategory: category,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Lihat Semua', style: TextStyle(color: Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        ..._transactions.map(_transactionTile).toList(),
      ],
    );
  }

  Widget _summaryItem(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _transactionTile(_TransactionData transaction) {
    return Card(
      elevation: 0.6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
              transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: transaction.isIncome ? Colors.green : Colors.red),
        ),
        title: Text(transaction.title),
        subtitle: Text(_formatTransactionTime(transaction.dateTime)),
        trailing: Text(_formatRupiah(transaction.amount),
            style: TextStyle(
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _TransactionData {
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime dateTime;

  _TransactionData(
    this.title,
    this.amount,
    this.isIncome, {
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();
}

class _HistoryScreen extends StatelessWidget {
  final List<_TransactionData> transactions;

  const _HistoryScreen({required this.transactions});

  String _formatRupiah(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  String _formatTransactionTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (txDate == today) {
      return 'Hari ini • $time';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin • $time';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} • $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: transactions.isEmpty
          ? const Center(
              child: Text('Belum ada transaksi'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.isIncome
                          ? Colors.green[100]
                          : Colors.red[100],
                      child: Icon(
                          transaction.isIncome
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color:
                              transaction.isIncome ? Colors.green : Colors.red),
                    ),
                    title: Text(transaction.title),
                    subtitle:
                        Text(_formatTransactionTime(transaction.dateTime)),
                    trailing: Text(_formatRupiah(transaction.amount),
                        style: TextStyle(
                            color: transaction.isIncome
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}
