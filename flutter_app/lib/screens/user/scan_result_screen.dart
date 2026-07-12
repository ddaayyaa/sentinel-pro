import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final bool isGranted = args?['isGranted'] ?? false;
    final RecognitionResult? result = args?['result'];
    
    final statusColor = isGranted ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final statusIcon = isGranted ? Icons.check_circle_outline_rounded : Icons.cancel_outlined;
    final statusText = isGranted ? 'Access Granted' : 'Access Denied';
    final subtitleText = isGranted ? 'Identity verified successfully' : 'Unauthorized person detected';
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan Result', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: statusColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)]),
                  child: Icon(statusIcon, size: 100, color: statusColor),
                ),
              ),
              const SizedBox(height: 32),
              Text(statusText, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: statusColor)),
              const SizedBox(height: 8),
              Text(subtitleText, style: const TextStyle(fontSize: 16, color: AppTheme.textLight)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(
                  children: [
                    if (!isGranted) ...[
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 12),
                          Expanded(child: Text('Security alert has been triggered', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDataRow(
                      isGranted ? 'Name' : 'Detection',
                      isGranted ? (result?.personName ?? 'John Anderson') : 'Unknown Identity',
                      valueColor: isGranted ? AppTheme.textDark : statusColor,
                    ),
                    const Divider(height: 32, color: Color(0xFFF3F4F6)),
                    _buildDataRow('Confidence', '${((result?.confidence ?? 0.987) * 100).toStringAsFixed(1)}%', valueColor: isGranted ? statusColor : AppTheme.textDark),
                    const Divider(height: 32, color: Color(0xFFF3F4F6)),
                    _buildDataRow('Timestamp', timestamp),
                    const Divider(height: 32, color: Color(0xFFF3F4F6)),
                    _buildDataRow('Location', 'Main Sector'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (!isGranted) ...[
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security report filed.')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Report Security Breach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/user-dashboard'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFFE5E7EB))),
                child: const Text('Return to Dashboard', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 15, color: valueColor ?? AppTheme.textDark, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
