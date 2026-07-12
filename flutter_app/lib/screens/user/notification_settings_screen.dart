import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool smsEnabled = false;
  bool alertSounds = true;

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
        title: const Text('Notifications', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('CHANNELS'),
            _settingsCard([
              _toggleTile('Push Notifications', pushEnabled, (v) => setState(() => pushEnabled = v)),
              _toggleTile('Email Alerts', emailEnabled, (v) => setState(() => emailEnabled = v)),
              _toggleTile('SMS Notifications', smsEnabled, (v) => setState(() => smsEnabled = v)),
            ]),
            const SizedBox(height: 32),
            _sectionHeader('SOUNDS & VIBRATION'),
            _settingsCard([
              _toggleTile('System Alert Sounds', alertSounds, (v) => setState(() => alertSounds = v)),
              _toggleTile('Vibrate on Alert', true, (v) {}),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1.2)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(children: children),
    );
  }

  Widget _toggleTile(String title, bool val, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Switch(value: val, onChanged: onChanged, activeColor: AppTheme.primaryPurple),
    );
  }
}
