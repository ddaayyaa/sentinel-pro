import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action Cards
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    'Live Chat',
                    onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    Icons.mail_outline_rounded,
                    'Email Support',
                    onTap: () => Navigator.pushNamed(context, '/ai-chat', arguments: {'mode': 'email'}),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            // FAQ List
            AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final faqs = [
                    {'q': 'How do I scan a face?', 'a': 'Navigate to Camera and capture'},
                    {'q': 'What if scan fails?', 'a': 'Try better lighting and angle'},
                    {'q': 'How to upload images?', 'a': 'Use the Upload feature'},
                    {'q': 'Where are my results?', 'a': 'Check Results List section'},
                  ];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildFAQTile(faqs[index]['q']!, faqs[index]['a']!),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Bottom Help Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Need more help?',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Contact Support Team'),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryPurple, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline_rounded, color: AppTheme.primaryPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
