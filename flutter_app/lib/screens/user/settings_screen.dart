import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool darkMode = false;
  bool biometricAuth = false;

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
          'Settings',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Preferences Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSettingTile(
                    Icons.notifications_none_rounded,
                    'Push Notifications',
                    'Receive alerts and updates',
                    pushNotifications,
                    (v) => setState(() => pushNotifications = v),
                  ),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildSettingTile(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    'Light theme active',
                    darkMode,
                    (v) => setState(() => darkMode = v),
                  ),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildSettingTile(
                    Icons.security_outlined,
                    'Biometric Auth',
                    'Use fingerprint/face ID',
                    biometricAuth,
                    (v) => setState(() => biometricAuth = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Sign Out Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.primaryPurple,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}
