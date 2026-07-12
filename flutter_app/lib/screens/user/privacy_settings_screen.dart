import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool faceDataStorage = true;
  bool activitySharing = false;
  bool dataEncryption = true;

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
        title: const Text('Privacy & Security', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  _toggleRow('Store Face Data', 'Keep biometric patterns on server', faceDataStorage, (v) => setState(() => faceDataStorage = v)),
                  const Divider(height: 32),
                  _toggleRow('Share Activity', 'Allow admin to see movement logs', activitySharing, (v) => setState(() => activitySharing = v)),
                  const Divider(height: 32),
                  _toggleRow('End-to-End Encryption', 'Secure all data transmissions', dataEncryption, (v) => setState(() => dataEncryption = v)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Request Data Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(String title, String sub, bool val, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: val, onChanged: onChanged, activeColor: AppTheme.primaryPurple),
      ],
    );
  }
}
