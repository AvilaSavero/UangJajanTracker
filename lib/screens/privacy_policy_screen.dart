import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const routeName = '/settings/privacy-policy';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Transparansi Data Anda Adalah Prioritas Kami.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildSection(
              icon: Icons.info_outline,
              title: 'Informasi yang Kami Kumpulkan',
              body:
                  'Kami mengumpulkan data transaksi keuangan, nama pengguna, dan alamat email yang Anda daftarkan. Data ini digunakan semata-mata untuk memberikan layanan pencatatan keuangan yang akurat dan personal.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.lock_outline,
              title: 'Keamanan & Penyimpanan',
              body:
                  'Semua data Anda dienkripsi menggunakan standar industri dan disimpan di server yang aman. Kami tidak pernah menjual data Anda kepada pihak ketiga. Password disimpan dalam bentuk hash yang tidak dapat dibaca.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.person_pin_outlined,
              title: 'Hak Pengguna',
              body:
                  'Anda memiliki hak penuh atas data Anda. Anda dapat memperbarui, mengunduh, atau menghapus data Anda kapan saja melalui menu Pengaturan Akun. Penghapusan akun bersifat permanen dan tidak dapat diurungkan.',
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.mail_outline),
                label: const Text(
                  'Hubungi Kami',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green.shade700, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
