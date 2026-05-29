import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pengaturan Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Atur profil, notifikasi, dan preferensi aplikasi kamu dengan mudah.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Preferensi'),
          const SizedBox(height: 8),
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined, color: Colors.green),
                  title: const Text('Notifikasi'),
                  subtitle: const Text('Pengingat transaksi dan batas pengeluaran'),
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined, color: Colors.orange),
                  title: const Text('Suara'),
                  subtitle: const Text('Aktifkan suara saat interaksi penting'),
                  value: _soundEnabled,
                  onChanged: (value) => setState(() => _soundEnabled = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: Colors.blue),
                  title: const Text('Login Biometrik'),
                  subtitle: const Text('Gunakan sidik jari atau wajah untuk login'),
                  value: _biometricEnabled,
                  onChanged: (value) => setState(() => _biometricEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Akun & Bantuan'),
          const SizedBox(height: 8),
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.person_outline, color: Colors.green),
                  title: Text('Profil Saya'),
                  subtitle: Text('Lihat dan edit data akun kamu'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.orange),
                  title: Text('Keamanan'),
                  subtitle: Text('Ganti password dan pengaturan privasi'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.blue),
                  title: Text('Pusat Bantuan'),
                  subtitle: Text('FAQ, kontak support, dan panduan aplikasi'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Uang Jajan Tracker membantu kamu memantau pengeluaran, pemasukan, dan limit harian dengan lebih rapi dan teratur.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
