import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  static const routeName = '/help-center';
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
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
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pusat Bantuan',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Temukan jawaban atas pertanyaan Anda atau hubungi tim dukungan kami.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pertanyaan Umum (FAQ)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _faqCard(
            title: 'Bagaimana cara menambah transaksi?',
            answer:
                'Klik tombol + di halaman utama, pilih kategori, masukkan jumlah, dan klik Simpan.',
          ),
          _faqCard(
            title: 'Bisakah saya mengubah limit harian?',
            answer:
                'Ya, Anda bisa mengatur limit harian di bagian Pengaturan > Limit Pengeluaran.',
          ),
          _faqCard(
            title: 'Bagaimana cara melihat laporan bulanan?',
            answer:
                'Buka tab Statistik untuk melihat grafik pengeluaran dan pemasukan Anda.',
          ),
          _faqCard(
            title: 'Dapatkah saya mengekspor data transaksi?',
            answer:
                'Fitur ekspor sedang dalam pengembangan dan akan segera tersedia.',
          ),
          const SizedBox(height: 20),
          const Text('Hubungi Kami',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.email_outlined, color: Colors.green),
                  title: const Text('Email Dukungan'),
                  subtitle: const Text('support@uangjajan.com'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Email disalin: support@uangjajan.com')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat_outlined, color: Colors.blue),
                  title: const Text('Live Chat'),
                  subtitle:
                      const Text('Chat dengan tim kami (09:00-17:00 WIB)'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fitur live chat - Coming Soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.phone_outlined, color: Colors.orange),
                  title: const Text('Telepon'),
                  subtitle: const Text('+62 812-3456-7890'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nomor disalin: +62 812-3456-7890')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Informasi Lainnya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: Colors.green),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black26),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Kebijakan Privasi',
                      'Kami menghormati privasi Anda. Data transaksi Anda disimpan dengan aman dan tidak akan dibagikan kepada pihak ketiga tanpa izin.',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined, color: Colors.blue),
                  title: const Text('Syarat dan Ketentuan'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black26),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Syarat dan Ketentuan',
                      'Dengan menggunakan aplikasi ini, Anda setuju dengan syarat dan ketentuan yang berlaku.',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.info_outlined, color: Colors.orange),
                  title: const Text('Tentang Aplikasi'),
                  subtitle: const Text('Versi 1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black26),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Tentang Uang Jajan Tracker',
                      'Uang Jajan Tracker v1.0.0\n\nAplikasi manajemen keuangan pribadi yang membantu Anda memantau pengeluaran, pemasukan, dan limit harian dengan mudah.\n\n© 2024 Uang Jajan Tracker. All rights reserved.',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _faqCard({required String title, required String answer}) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          leading: const Icon(Icons.help_outline, color: Colors.green),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(answer, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
