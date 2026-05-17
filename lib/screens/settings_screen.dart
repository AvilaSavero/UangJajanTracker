import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pengaturan Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Kelola profil, batas, dan preferensi aplikasi Anda.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Kategori Pengaturan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Akun'),
                  subtitle: Text('Atur profil dan keamanan'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Bahasa'),
                  subtitle: Text('Pilih bahasa aplikasi'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifikasi'),
                  subtitle: Text('Atur pengingat dan notifikasi'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.accessibility_new),
                  title: Text('Aksesibilitas'),
                  subtitle: Text('Pengaturan akses dan kenyamanan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Informasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Transparansi Data', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Data Anda disimpan dengan aman dan hanya digunakan untuk menampilkan ringkasan pengeluaran dan limit.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pusat Bantuan', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Jika ada masalah, hubungi tim support atau cek FAQ di aplikasi.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
