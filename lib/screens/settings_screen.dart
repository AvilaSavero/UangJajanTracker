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
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Akun'),
            subtitle: Text('Atur profil dan keamanan'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Bahasa'),
            subtitle: Text('Pilih bahasa aplikasi'),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Bantuan & Laporan'),
            subtitle: Text('Laporkan masalah atau minta bantuan'),
          ),
          ListTile(
            leading: Icon(Icons.accessibility_new),
            title: Text('Aksesibilitas'),
            subtitle: Text('Pengaturan akses dan kenyamanan'),
          ),
        ],
      ),
    );
  }
}
