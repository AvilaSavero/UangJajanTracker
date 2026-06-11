import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

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
  int _selectedIndex = 0;

  late final List<_TransactionData> _transactions = [
    _TransactionData('Starbucks Coffee', 55000, false,
        dateTime: DateTime.now().subtract(const Duration(hours: 1))),
    _TransactionData('Gaji Masuk', 500000, true,
        dateTime: DateTime.now().subtract(const Duration(hours: 2))),
    _TransactionData('Tagihan Listrik', 320000, false,
        dateTime: DateTime.now().subtract(const Duration(days: 1))),
  ];

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
            (data['amount'] as num).toDouble(),
            data['isIncome'] as bool,
            dateTime: DateTime.now(),
          ),
        );
      }
    });
  }

  double get _balance {
    final v = _summaryData?['data']?['balance'];
    return (v is num ? v : 2450000).toDouble();
  }

  double get _todayIncome {
    final v = _summaryData?['data']?['total_income'];
    return (v is num ? v : 475000).toDouble();
  }

  double get _todayExpense {
    final v = _summaryData?['data']?['total_expense'];
    return (v is num ? v : 25000).toDouble();
  }

  double get _monthlyLimit {
    final v = _summaryData?['data']?['spending_limit']?['monthly_limit'];
    return (v is num ? v : 3000000).toDouble();
  }

  double get _limitUsage =>
      _monthlyLimit > 0 ? (_todayExpense / _monthlyLimit).clamp(0.0, 1.0) : 0;

  String _formatRupiah(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp $formatted';
  }

  String _formatShort(double value) {
    if (value >= 1000000) return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    return _formatRupiah(value);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(dt.year, dt.month, dt.day);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (txDay == today) return 'Hari Ini, $h:$m AM';
    if (txDay == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(
              onTransactionAdded: _addTransaction,
            ),
          ),
        ),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildHomeBody() : _buildHistoryBody(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.grid_view_rounded, 'BERANDA'),
              _navItem(1, Icons.history_rounded, 'RIWAYAT'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    selected ? Colors.green.shade700 : Colors.grey[400],
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.green.shade700 : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _loadSummary,
      color: Colors.green.shade700,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          _buildAppBar(),
          const SizedBox(height: 16),
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildBudgetCard(),
          const SizedBox(height: 16),
          _buildWeeklyStats(),
          const SizedBox(height: 16),
          _buildTipCard(),
          const SizedBox(height: 20),
          _buildQuickAdd(),
          const SizedBox(height: 20),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: Colors.green.shade700, size: 22),
              const SizedBox(width: 8),
              Text(
                'Uang Jajan Tracker',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person_outline,
                  color: Colors.grey[600], size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SALDO TERSEDIA',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          _isLoadingSummary
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _formatRupiah(_balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _balanceSubCard(
                  'PEMASUKAN\nHARI INI',
                  _formatRupiah(_todayIncome),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _balanceSubCard(
                  'PENGELUARAN\nHARI INI',
                  _formatRupiah(_todayExpense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceSubCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10, height: 1.4)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    final pct = (_limitUsage * 100).toInt();
    final remaining = _monthlyLimit - _todayExpense;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Anggaran Bulanan',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$pct%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Limit ${_formatRupiah(_monthlyLimit)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _limitUsage,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tersisa ${_formatRupiah(remaining > 0 ? remaining : 0)} dari target Anda',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    final weekData = [120000.0, 80000.0, 200000.0, 95000.0, 150000.0, 310000.0, 60000.0];
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jun', 'Sab', 'Min'];
    final maxY = weekData.reduce((a, b) => a > b ? a : b) * 1.3;
    final weekTotal = weekData.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Statistik Mingguan',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, StatisticsScreen.routeName),
                child: Text('Lihat Detail >',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GRAFIK PENGELUARAN',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('Minggu Ini',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TOTAL',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(weekTotal),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+ ${_formatShort(310000)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(days[idx],
                              style: TextStyle(
                                  fontSize: 10,
                                  color: idx == 5
                                      ? Colors.green.shade700
                                      : Colors.grey[400],
                                  fontWeight: idx == 5
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(weekData.length, (i) {
                  final isHighlighted = i == 5;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weekData[i],
                        color: isHighlighted
                            ? Colors.green.shade600
                            : Colors.green.shade100,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aman bro!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  'Pengeluaranmu masih 15% di bawah rata-rata harian. Pertahankan!',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tambah Cepat',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    onTransactionAdded: _addTransaction,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Transaksi Baru',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _quickTile(Icons.restaurant, 'Makanan', Colors.orange, 'Makan'),
            const SizedBox(width: 12),
            _quickTile(
                Icons.directions_car, 'Transportasi', Colors.blue, 'Transport'),
            const SizedBox(width: 12),
            _quickTile(
                Icons.sports_esports, 'Hiburan', Colors.purple, 'Hiburan'),
          ],
        ),
      ],
    );
  }

  Widget _quickTile(
      IconData icon, String label, Color color, String category) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(
              onTransactionAdded: _addTransaction,
              preSelectedCategory: category,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Riwayat Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._transactions.take(5).map(_transactionItem),
      ],
    );
  }

  Widget _transactionItem(_TransactionData tx) {
    final isIncome = tx.isIncome;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green.shade700 : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(_formatTime(tx.dateTime),
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${_formatRupiah(tx.amount)}',
            style: TextStyle(
              color: isIncome ? Colors.green.shade700 : Colors.red[400],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Riwayat Transaksi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        Expanded(
          child: _transactions.isEmpty
              ? const Center(child: Text('Belum ada transaksi'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _transactions.length,
                  itemBuilder: (_, i) => _transactionItem(_transactions[i]),
                ),
        ),
      ],
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
