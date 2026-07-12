import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '2.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: AppTheme.primaryPurple),
            const SizedBox(height: 24),
            const Text('SENTINEL PRO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text('Advanced AI Security System', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
            const SizedBox(height: 48),
            Text('Version $_version', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('© 2024 Sentinel Security Corp', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Sentinel Pro is a state-of-the-art facial recognition system designed for modern security infrastructure. Built with Flutter and powered by DeepFace.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
