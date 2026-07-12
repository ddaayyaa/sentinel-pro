import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
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
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: logs.isEmpty && provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No History Yet',
                  subtitle: 'Your scans will appear here',
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadLogs(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildHistoryCard(context, log);
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic log) {
    final timeStr = DateFormat('hh:mm a').format(log.timestamp);
    final dateStr = DateFormat('MMM dd, yyyy').format(log.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.personName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '$timeStr • $dateStr',
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusBadge(status: log.status),
        ],
      ),
    );
  }
}
