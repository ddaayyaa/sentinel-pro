import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class SecurityLogsScreen extends StatefulWidget {
  const SecurityLogsScreen({super.key});

  @override
  State<SecurityLogsScreen> createState() => _SecurityLogsScreenState();
}

class _SecurityLogsScreenState extends State<SecurityLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();
    final alerts = provider.alerts;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Security Incidents', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading && alerts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const EmptyState(icon: Icons.shield_outlined, title: 'No Incidents', subtitle: 'System is running smoothly')
              : RefreshIndicator(
                  onRefresh: () => provider.loadAlerts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      return _buildAlertTile(alerts[index], provider);
                    },
                  ),
                ),
    );
  }

  Widget _buildAlertTile(dynamic alert, AlertProvider provider) {
    final bool isUnauthorized = alert.type.toLowerCase().contains('unauthorized');
    final isCritical = alert.severity.toLowerCase() == 'high' || alert.severity.toLowerCase() == 'critical';
    final color = isUnauthorized ? const Color(0xFFEF4444) : (isCritical ? Colors.orange : Colors.blue);
    final timeStr = DateFormat('hh:mm a').format(alert.timestamp);
    final dateStr = DateFormat('dd MMM yyyy').format(alert.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(isUnauthorized ? Icons.gpp_bad_rounded : Icons.security_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.type.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                      Text(alert.message, maxLines: 2, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('•', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUnauthorized && !alert.resolved)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => provider.resolveAlert(alert.id!, 'Access Denied'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Blacklist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => provider.resolveAlert(alert.id!, 'Access Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          else if (alert.resolved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, color: Colors.green, size: 14),
                  SizedBox(width: 8),
                  Text('INCIDENT RESOLVED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
