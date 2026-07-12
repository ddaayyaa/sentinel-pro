import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../services/api_service.dart';

class LogDetailsScreen extends StatelessWidget {
  const LogDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EntryLog log = ModalRoute.of(context)!.settings.arguments as EntryLog;
    final dateStr = DateFormat('MMMM dd, yyyy').format(log.timestamp);
    final timeStr = DateFormat('hh:mm:ss a').format(log.timestamp);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Event Analysis', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Captured Frame
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                image: log.imagePath != null
                    ? DecorationImage(image: NetworkImage('${context.read<ApiService>().baseUrl}/${log.imagePath}'), fit: BoxFit.contain)
                    : null,
              ),
              child: log.imagePath == null ? const Icon(Icons.videocam_off_rounded, size: 64, color: Colors.grey) : null,
            ),
            const SizedBox(height: 32),
            const Text('Security Context', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person_outline, 'Detected Identity', log.personName),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.access_time_rounded, 'Timestamp', '$dateStr • $timeStr'),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.location_on_outlined, 'Camera Node', log.cameraId),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recognition Status', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                      StatusBadge(status: log.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (log.status.toLowerCase() == 'unauthorized') ...[
              const Text('Administrative Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/manual-override', arguments: log),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Perform Manual Override', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}
