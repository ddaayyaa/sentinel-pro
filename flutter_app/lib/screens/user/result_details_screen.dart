import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class ResultDetailsScreen extends StatelessWidget {
  const ResultDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EntryLog log = ModalRoute.of(context)!.settings.arguments as EntryLog;
    final dateStr = DateFormat('MMMM dd, yyyy').format(log.timestamp);
    final timeStr = DateFormat('hh:mm:ss a').format(log.timestamp);
    final isAuthorized = log.status.toLowerCase() == 'authorized' || log.status.toLowerCase() == 'granted';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Capture Details', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
                image: log.imagePath != null
                    ? DecorationImage(image: NetworkImage('${context.read<ApiService>().baseUrl}/${log.imagePath}'), fit: BoxFit.contain)
                    : null,
              ),
              child: log.imagePath == null ? const Icon(Icons.person, size: 80, color: Colors.grey) : null,
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: (isAuthorized ? Colors.green : Colors.red).withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(isAuthorized ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, color: isAuthorized ? Colors.green : Colors.red, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.personName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          Text(isAuthorized ? 'Access Granted' : 'Access Denied', style: TextStyle(fontSize: 14, color: isAuthorized ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  _buildDetailRow(Icons.track_changes_rounded, 'Confidence Score', '${(log.confidence * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.access_time_rounded, 'Timestamp', '$dateStr • $timeStr'),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.location_on_outlined, 'Location', log.entryPoint),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 20),
                  _buildInfoRow('Camera Node', log.cameraId),
                  const SizedBox(height: 16),
                  _buildInfoRow('Engine Threshold', '0.75'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Alert Triggered', log.alertTriggered ? 'YES' : 'NO', valueColor: log.alertTriggered ? Colors.red : Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor ?? AppTheme.textDark)),
      ],
    );
  }
}
