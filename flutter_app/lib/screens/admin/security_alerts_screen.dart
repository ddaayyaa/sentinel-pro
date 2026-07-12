import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security Alerts',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: provider.isLoading && alerts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const EmptyState(
                  icon: Icons.shield_moon_outlined,
                  title: 'All Systems Clear',
                  subtitle: 'No security alerts reported recently',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _buildAlertCard(context, alerts[index], provider);
                  },
                ),
    );
  }

  Widget _buildAlertCard(BuildContext context, dynamic alert, AlertProvider provider) {
    final bool isUnauthorized = alert.type.toLowerCase().contains('unauthorized');
    final isCritical = alert.severity.toLowerCase() == 'high' || alert.severity.toLowerCase() == 'critical';
    final color = isUnauthorized ? Colors.red : (isCritical ? Colors.orange : Colors.blue);
    final timeStr = DateFormat('hh:mm a').format(alert.timestamp);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: alert.resolved ? const Color(0xFFE5E7EB) : color.withOpacity(0.5),
          width: alert.resolved ? 1.0 : 2.0,
        ),
        boxShadow: [
          if (!alert.resolved && isUnauthorized)
            BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (!alert.resolved && isUnauthorized)
                    const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 24)
                  else
                    Icon(
                      isCritical ? Icons.report_problem_rounded : Icons.warning_amber_rounded,
                      color: color,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    alert.type.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Text(
                timeStr,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            alert.message,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: isUnauthorized && !alert.resolved ? Colors.red : AppTheme.textDark
            ),
          ),
          const SizedBox(height: 8),
          if (alert.personName != null)
            Row(
              children: [
                const Icon(Icons.face_retouching_natural, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 8),
                Text('Detected Identity: ${alert.personName}', style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
              ],
            ),
          const SizedBox(height: 20),
          
          if (!alert.resolved)
            Row(
              children: [
                if (isUnauthorized) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await provider.resolveAlert(alert.id!, 'Access Rejected by Admin');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Person blacklisted and alert resolved.')));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Blacklist', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await provider.resolveAlert(alert.id!, 'Approved by Admin');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access approved and alert cleared.')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else
                  Expanded(
                    child: TextButton(
                      onPressed: () => provider.resolveAlert(alert.id!, 'Verified via dashboard'),
                      child: const Text('Mark as Resolved', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Investigation Complete', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }
}
