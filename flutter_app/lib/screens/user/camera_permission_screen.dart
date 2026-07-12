import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, size: 80, color: AppTheme.primaryPurple),
            const SizedBox(height: 32),
            const Text('Camera Access Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Sentinel Pro needs camera permissions to perform facial recognition and live scanning.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textLight)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                final status = await Permission.camera.request();
                if (status.isGranted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Grant Permission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
