import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpCenterScreen extends StatelessWidget {
  static const routeName = '/settings/help-center';
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan & Laporan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.green.shade700, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pusat Bantuan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temukan jawaban cepat dari berbagai pertanyaan umum tentang kami.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.green.shade700),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hubungi Kami',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              icon: Icons.chat,
              title: 'WhatsApp Support',
              value: '+62 821-2345-6789',
              onCopy: () {
                Clipboard.setData(const ClipboardData(text: '+6282123456789'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nomor WhatsApp disalin ke clipboard')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              icon: Icons.email,
              title: 'Email Support',
              value: 'support@uangjajantracker.com',
              onCopy: () {
                Clipboard.setData(const ClipboardData(text: 'support@uangjajantracker.com'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alamat Email disalin ke clipboard')),
                );
              },
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'Temukan Kami di Media Sosial',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook, Colors.blue),
                const SizedBox(width: 20),
                _buildSocialIcon(Icons.camera_alt, Colors.pink),
                const SizedBox(width: 20),
                _buildSocialIcon(Icons.alternate_email, Colors.blueAccent),
                const SizedBox(width: 20),
                _buildSocialIcon(Icons.business, Colors.indigo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.grey),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey[200],
      child: Icon(icon, color: color, size: 24),
    );
  }
}
