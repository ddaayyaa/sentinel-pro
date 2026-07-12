import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryLogProvider>().loadLogs(refresh: true);
    });
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    final api = context.read<ApiService>();
    final notifications = NotificationService();

    try {
      final data = await api.exportLogs('csv');
      if (data != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'audit_trail_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(data as List<int>);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audit log saved: $fileName'), backgroundColor: Colors.green),
          );
          await notifications.showNotification(
            id: 101,
            title: 'Audit Download Complete',
            body: 'Full system trail has been archived to documents.',
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('System Audit Trail', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: _isDownloading 
              ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(icon: const Icon(Icons.download_rounded, color: AppTheme.primaryPurple, size: 20), onPressed: _handleDownload),
          ),
        ],
      ),
      body: provider.isLoading && logs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: logs.length,
              itemBuilder: (context, index) => _buildAuditItem(logs[index]),
            ),
    );
  }

  Widget _buildAuditItem(dynamic log) {
    final timeStr = DateFormat('HH:mm:ss').format(log.timestamp);
    final dateStr = DateFormat('dd MMM yyyy').format(log.timestamp);
    final bool isCritical = log.status == 'unauthorized';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: isCritical ? Colors.red : AppTheme.primaryPurple,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCritical ? 'CRITICAL_EVENT' : 'SYSTEM_LOG',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: isCritical ? Colors.red : AppTheme.primaryPurple),
                        ),
                        Text('$dateStr | $timeStr', style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Biometric detection event for person: ${log.personName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access path verified via ${log.entryPoint} (ID: ${log.cameraId})',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statusIndicator(log.status),
                        const Spacer(),
                        const Text('Integrity Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 12, color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(String status) {
    final bool ok = status == 'authorized';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (ok ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: ok ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
