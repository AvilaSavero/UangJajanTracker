import 'package:flutter/material.dart';
import 'package:uang_jajan_tracker/utils/color_extensions.dart';
import 'package:provider/provider.dart';
import 'package:uang_jajan_tracker/transaction_service.dart';

class StatisticsScreen extends StatelessWidget {
  static const routeName = '/statistics';
  const StatisticsScreen({super.key});

  String _formatRupiah(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Consumer<TransactionService>(
        builder: (context, transactionService, _) {
          final now = DateTime.now();
          final totalIncome = transactionService.getTotalIncomeForMonth(now);
          final totalExpense = transactionService.getTotalExpenseForMonth(now);
          final averageDailyExpense =
              transactionService.getAverageDailyExpense(now);
          final categoryTotals =
              transactionService.getCategoryTotalsForMonth(now);
          final topCategories =
              transactionService.getTopCategoriesForMonth(now);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Analisis Keuangan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  'Lihat grafik, ringkasan bulanan, dan kategori teratas kamu.',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Bulanan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statCard('Pemasukan', _formatRupiah(totalIncome),
                              Colors.green),
                          _statCard('Pengeluaran', _formatRupiah(totalExpense),
                              Colors.red),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                            child: Text('Grafik batang mingguan',
                                style: TextStyle(color: Colors.black54))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori Teratas',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (topCategories.isNotEmpty)
                        ...topCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final amount = categoryTotals[category] ?? 0;
                          final icons = {
                            'Makan': Icons.fastfood,
                            'Transport': Icons.directions_bus,
                            'Jajan': Icons.local_grocery_store,
                            'Top Up': Icons.upload,
                          };
                          final colors = {
                            'Makan': Colors.orange,
                            'Transport': Colors.blue,
                            'Jajan': Colors.purple,
                            'Top Up': Colors.green,
                          };

                          return Column(
                            children: [
                              _categoryRow(
                                category,
                                _formatRupiah(amount),
                                icons[category] ?? Icons.shopping_bag,
                                colors[category] ?? Colors.grey,
                              ),
                              if (index < topCategories.length - 1)
                                const SizedBox(height: 12),
                            ],
                          );
                        }).toList()
                      else
                        const Text('Tidak ada transaksi pengeluaran',
                            style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statistik Lainnya',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _infoRow('Rata-rata pengeluaran harian',
                          _formatRupiah(averageDailyExpense)),
                      const Divider(height: 24),
                      _infoRow('Saldo bulan ini',
                          _formatRupiah(totalIncome - totalExpense)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacitySafe(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(String title, String amount, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacitySafe(0.15),
          child: Icon(icon, color: color)),
        const SizedBox(width: 16),
        Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(title, style: const TextStyle(color: Colors.black54))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
