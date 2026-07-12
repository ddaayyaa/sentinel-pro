import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryLogProvider>().loadLogs(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryLogProvider>();
    final logs = provider.logs;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detailed Activity', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: logs.isEmpty && provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildDetailedLog(log);
              },
            ),
    );
  }

  Widget _buildDetailedLog(dynamic log) {
    final dateStr = DateFormat('MMMM dd, yyyy • hh:mm a').format(log.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: 80,
                color: const Color(0xFFE5E7EB),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Detection event: ${log.personName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Camera: ${log.cameraId} • Location: ${log.entryPoint}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatusBadge(status: log.status),
                      const SizedBox(width: 8),
                      Text('Confidence: ${(log.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
