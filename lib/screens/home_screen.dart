import 'package:flutter/material.dart';
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
  final double _spendingLimit = 1000000;
  final double _balance = 2450000;

  final List<_TransactionData> _transactions = const [
    _TransactionData('Makan Siang', 20000, false),
    _TransactionData('Top Up', 50000, true),
    _TransactionData('Jajan Online', 15000, false),
    _TransactionData('Transport', 12000, false),
  ];

  int _selectedIndex = 0;

  double get _totalIncome => _transactions
      .where((item) => item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((item) => !item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get _savedAmount => _totalIncome - _totalExpense;

  double get _limitUsage => (_totalExpense / _spendingLimit).clamp(0, 1);

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
    final formatted = value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }
    if (index == 1) {
      Navigator.pushNamed(context, StatisticsScreen.routeName);
    } else if (index == 2) {
      Navigator.pushNamed(context, AddTransactionScreen.routeName);
    } else if (index == 3) {
      Navigator.pushNamed(context, SettingsScreen.routeName);
    } else if (index == 4) {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddTransactionScreen.routeName),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Hai, User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Lihat ringkasan pengeluaran dan limit hari ini.', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.account_circle, size: 36, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green[700],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Anda', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_formatRupiah(_balance), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Ringkasan mingguan', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 18),
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Grafik kecil placeholder', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem('Pemasukan', _formatRupiah(_totalIncome), Colors.green),
                _summaryItem('Pengeluaran', _formatRupiah(_totalExpense), Colors.red),
                _summaryItem('Tabungan', _formatRupiah(_savedAmount < 0 ? 0 : _savedAmount), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batas Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Limit Anda', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(_spendingLimit), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Terpakai', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('${(_limitUsage * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: _limitColor)),
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
            Text(_limitStatus, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _limitColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _categoryTile(Icons.upload, 'Top Up', Colors.green),
            _categoryTile(Icons.fastfood, 'Makan', Colors.orange),
            _categoryTile(Icons.local_grocery_store, 'Jajan', Colors.purple),
            _categoryTile(Icons.directions_bus, 'Transport', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _categoryTile(IconData icon, String title, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _transactionTile(_TransactionData transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: transaction.isIncome ? Colors.green : Colors.red),
        ),
        title: Text(transaction.title),
        subtitle: const Text('Hari ini • 10:30'),
        trailing: Text(_formatRupiah(transaction.amount), style: TextStyle(color: transaction.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _TransactionData {
  final String title;
  final double amount;
  final bool isIncome;

  const _TransactionData(this.title, this.amount, this.isIncome);
}
