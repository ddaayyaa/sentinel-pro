import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Support Center', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _supportCard(
              context,
              'Live Chat',
              'Talk to our security experts now',
              Icons.chat_bubble_outline_rounded,
              '/live-support',
            ),
            const SizedBox(height: 16),
            _supportCard(
              context,
              'AI Support',
              'Get instant automated help',
              Icons.auto_awesome_rounded,
              '/ai-chat',
            ),
            const SizedBox(height: 16),
            _supportCard(
              context,
              'Raise Ticket',
              'Submit a technical issue',
              Icons.confirmation_number_outlined,
              '/raise-ticket',
            ),
            const SizedBox(height: 32),
            const Text('Frequently Asked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _faqTile('How to reset face ID?'),
            _faqTile('Accuracy issues in low light'),
            _faqTile('Adding family members'),
          ],
        ),
      ),
    );
  }

  Widget _supportCard(BuildContext context, String title, String sub, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.primaryPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(sub, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.add, size: 18, color: AppTheme.textLight),
        ],
      ),
    );
  }
}
