import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  final int transactionCount;
  final double spendingLimit;
  
  const ProfileScreen({
    super.key,
    this.transactionCount = 0,
    this.spendingLimit = 1000000,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.person,
                          size: 42, color: Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Raja Vibe',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('raja.vibe@email.com',
                            style: TextStyle(color: Colors.black54)),
                        SizedBox(height: 6),
                        Text('Pengelola Keuangan Pribadi',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ringkasan Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _detailBox('Transaksi', transactionCount.toString(), Colors.blue),
              const SizedBox(width: 12),
              _detailBox('Limit', _formatRupiah(spendingLimit), Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tindakan Cepat',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _profileAction(Icons.edit, 'Edit Profil'),
                  const Divider(),
                  _profileAction(Icons.lock_outline, 'Keamanan Akun'),
                  const Divider(),
                  _profileAction(Icons.help_outline, 'Pusat Bantuan'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tentang Aplikasi',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(
                      'Uang Jajan Tracker membantu kamu memantau pengeluaran, pemasukan, dan limit harian dengan mudah.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  Widget _profileAction(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 16),
        Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
      ],
    );
  }
}
