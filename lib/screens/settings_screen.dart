import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'language_screen.dart';
import 'accessibility_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'account_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            iconBg: Colors.green.shade50,
            iconColor: Colors.green.shade700,
            title: 'Edit Profil',
            subtitle: 'Ubah nama, foto, dan limit pengeluaran',
            routeName: EditProfileScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            iconBg: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
            title: 'Keamanan Akun',
            subtitle: 'Password, biometrik, dan aktivitas login',
            routeName: SecurityScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.language,
            iconBg: Colors.orange.shade50,
            iconColor: Colors.orange.shade700,
            title: 'Pilihan Bahasa',
            subtitle: 'Bahasa Indonesia / English',
            routeName: LanguageScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            iconBg: Colors.purple.shade50,
            iconColor: Colors.purple.shade700,
            title: 'Aksesibilitas',
            subtitle: 'Mode gelap dan penyesuaian visual',
            routeName: AccessibilityScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            iconBg: Colors.teal.shade50,
            iconColor: Colors.teal.shade700,
            title: 'Bantuan & Laporan',
            subtitle: 'FAQ, kontak, dan pusat bantuan',
            routeName: HelpCenterScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            iconBg: Colors.indigo.shade50,
            iconColor: Colors.indigo.shade700,
            title: 'Kebijakan Privasi',
            subtitle: 'Transparansi data dan hak pengguna',
            routeName: PrivacyPolicyScreen.routeName,
          ),
          _buildMenuItem(
            context,
            icon: Icons.manage_accounts_outlined,
            iconBg: Colors.red.shade50,
            iconColor: Colors.red.shade700,
            title: 'Atur Akun',
            subtitle: 'Reset data atau hapus akun',
            routeName: AccountSettingsScreen.routeName,
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.logout, color: Colors.red.shade700, size: 22),
        ),
        title: Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade700),
        ),
        subtitle: Text('Keluar dari akun Anda', style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Keluar?'),
              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Keluar'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ApiService.clearSession();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
            }
          }
        },
      ),
    );
  }
}
