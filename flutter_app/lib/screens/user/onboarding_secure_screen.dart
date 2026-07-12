import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingSecureScreen extends StatelessWidget {
  const OnboardingSecureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Skip', style: TextStyle(color: AppTheme.textLight))),
              ),
              const Spacer(flex: 2),
              const Center(
                child: Icon(Icons.shield_outlined, size: 100, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 48),
              const Text(
                'Secure Access',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'AI-powered facial recognition for secure entry control',
                style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 32, height: 6, decoration: BoxDecoration(color: AppTheme.primaryPurple, borderRadius: BorderRadius.circular(3))),
                ],
              ),
              const Spacer(flex: 3),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)]),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
