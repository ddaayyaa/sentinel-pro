import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SignOutScreen extends StatelessWidget {
  const SignOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45, // Simulating a dialog background
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppTheme.primaryPurple, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign Out?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textDark)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
