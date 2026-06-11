import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  static const routeName = '/settings/accessibility';
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  bool _darkMode = false;
  bool _colorblindMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aksesibilitas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'VISUAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green.shade700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildAccessibilityTile(
              title: 'Mode Gelap',
              subtitle: 'Gunakan tema gelap untuk mengurangi kelelahan mata',
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
              },
            ),
            const SizedBox(height: 16),
            _buildAccessibilityTile(
              title: 'Mode Buta Warna',
              subtitle: 'Gunakan warna alternatif untuk kejelasan grafik',
              value: _colorblindMode,
              onChanged: (val) {
                setState(() => _colorblindMode = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.green.shade700,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
