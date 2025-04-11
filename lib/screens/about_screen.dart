import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Zappis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your trusted partner for electric vehicle charging in Ethiopia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Our Mission',
              'To accelerate the world\'s transition to sustainable energy by making EV charging accessible, reliable, and convenient for everyone in Ethiopia.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Features',
              '• Find charging stations near you\n'
                  '• Book charging slots in advance\n'
                  '• Multiple payment options\n'
                  '• Real-time availability updates\n'
                  '• Charging cost calculator',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact',
              'Have questions or feedback? We\'d love to hear from you!',
            ),
            const SizedBox(height: 16),
            _buildContactButton(
              context,
              'Email Us',
              Icons.email,
              () => _launchEmail('contact@zappis.com'),
            ),
            const SizedBox(height: 8),
            _buildContactButton(
              context,
              'Visit Website',
              Icons.language,
              () => _launchWebsite('https://zappis.com'),
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2023 Zappis. All rights reserved.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    }
  }

  Future<void> _launchWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunch(websiteUri.toString())) {
      await launch(websiteUri.toString());
    }
  }
}
