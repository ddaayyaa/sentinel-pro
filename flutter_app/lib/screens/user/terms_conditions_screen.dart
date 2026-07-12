import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Terms & Conditions', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Text(
                        'By using Sentinel Pro, you agree to these terms and conditions.\n\n1. Acceptance of Terms: By accessing and using this service, you accept and agree to be bound by the terms.\n\n2. Privacy Policy: Your privacy is important to us. Please review our Privacy Policy.\n\n3. User Responsibilities: You agree to use this service only for lawful purposes.\n\n4. Data Usage: We collect and process facial recognition data as described in our Privacy Policy...',
                        style: TextStyle(color: AppTheme.textLight, fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)]),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
                child: const Text('I Accept'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
