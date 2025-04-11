import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Frequently Asked Questions',
            [
              _buildFAQItem(
                'How do I book a charging station?',
                'To book a charging station, find a station on the map, tap on it, and select "Book Now". Choose your preferred charger type and time slot.',
              ),
              _buildFAQItem(
                'How do I pay for charging?',
                'You can pay using SantimPay, TeleBirr, or CBE Birr. After booking, you\'ll receive a QR code to scan with your preferred payment app.',
              ),
              _buildFAQItem(
                'What happens if I arrive late?',
                'You have a 15-minute grace period. After that, your booking may be cancelled and the spot given to another user.',
              ),
              _buildFAQItem(
                'How do I cancel a booking?',
                'Go to "My Bookings" in your profile, select the booking, and tap "Cancel Booking". Note that cancellation policies may apply.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Contact Us',
            [
              _buildContactItem(
                context,
                'Email Support',
                'support@zappis.com',
                Icons.email,
                () => _launchEmail('support@zappis.com'),
              ),
              _buildContactItem(
                context,
                'Phone Support',
                '+251 911 123 456',
                Icons.phone,
                () => _launchPhone('+251911123456'),
              ),
              _buildContactItem(
                context,
                'WhatsApp',
                '+251 911 123 456',
                Icons.message,
                () => _launchWhatsApp('+251911123456'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Troubleshooting',
            [
              _buildTroubleshootingItem(
                'App is not loading',
                'Check your internet connection and try again. If the problem persists, try restarting the app.',
              ),
              _buildTroubleshootingItem(
                'Payment failed',
                'Ensure you have sufficient funds and try again. If the problem persists, contact our support team.',
              ),
              _buildTroubleshootingItem(
                'Can\'t find nearby stations',
                'Make sure location services are enabled on your device and you have granted location permissions to the app.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
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
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTroubleshootingItem(String title, String solution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(solution),
          ],
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

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phone,
    );
    if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    }
  }
}
