import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context);
    final stats = dashboard.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textDark),
          onPressed: () => _showAdminFeatures(context),
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryPurple, size: 20),
            ),
            onPressed: () => Navigator.pushNamed(context, '/admin-ai-chat'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboard.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // AI Threat Assessment Card
              _buildThreatAssessment(stats),
              const SizedBox(height: 24),

              // ANALYTICS SUMMARY (NEW)
              _buildAnalyticsSummary(stats),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard('Total Faces', stats?.totalFaces.toString() ?? '...', '+12%', Icons.people_outline_rounded),
                  _buildStatCard('Today Entries', stats?.todayEntries.toString() ?? '...', '+5%', Icons.stacked_line_chart_rounded),
                  _buildStatCard('Alerts', stats?.activeAlerts.toString() ?? '...', '', Icons.warning_amber_rounded),
                  _buildStatCard('More Tools', 'Suite', '', Icons.apps_rounded, onTap: () => _showAdminFeatures(context)),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Activity Chart Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Neural Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: stats != null && stats.hourlyData.isNotEmpty
                          ? stats.hourlyData.take(7).map((h) => _buildBar(
                              (h['count'] as num).toDouble() / 15.0, // Scale based on max 15 entries/hour
                              '${h['hour']}:00',
                              isHigh: (h['count'] as num) > 10
                            )).toList()
                          : [
                              _buildBar(0.4, '08:00'),
                              _buildBar(0.7, '10:00'),
                              _buildBar(0.9, '12:00', isHigh: true),
                              _buildBar(0.5, '14:00'),
                              _buildBar(0.3, '16:00'),
                              _buildBar(0.6, '18:00'),
                              _buildBar(0.2, '20:00'),
                            ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Recent Events Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/entry-logs'),
                          child: const Text('See All', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (stats != null && stats.recentEntries.isNotEmpty)
                      ...stats.recentEntries.take(3).map((e) => Column(
                        children: [
                          _buildEventTile(
                            e.personName, 
                            DateFormat('hh:mm a').format(e.timestamp), 
                            e.status.toUpperCase(),
                            onTap: () => Navigator.pushNamed(context, '/log-details', arguments: e),
                          ),
                          const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        ],
                      )).toList()
                    else
                      const Center(child: Text('No recent events', style: TextStyle(color: AppTheme.textLight, fontSize: 13))),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatAssessment(DashboardStats? stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple.withOpacity(0.1), AppTheme.primaryPurple.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI THREAT LEVEL: ${stats != null && stats.unauthorizedToday > 5 ? 'HIGH' : (stats != null && stats.unauthorizedToday > 0 ? 'ELEVATED' : 'LOW')}', 
                  style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)
                ),
                const SizedBox(height: 4),
                Text(
                  stats != null && stats.unauthorizedToday > 0 
                    ? 'Security posture adjusted based on ${stats.unauthorizedToday} unauthorized attempts.' 
                    : 'System analyzing patterns... Posture is STABLE', 
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight)
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user_rounded, 
            color: stats != null && stats.unauthorizedToday > 0 ? Colors.orange : const Color(0xFF10B981), 
            size: 24
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildAnalyticsSummary(DashboardStats? stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Traffic Intelligence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/analytics'),
                child: const Text('View Detailed', style: TextStyle(color: AppTheme.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _trafficItem('DAILY', '${stats?.todayEntries ?? 0}', Colors.blue),
              _verticalDivider(),
              _trafficItem('WEEKLY', '${(stats?.todayEntries ?? 0) * 7}', Colors.purple),
              _verticalDivider(),
              _trafficItem('MONTHLY', '${(stats?.todayEntries ?? 0) * 30}', Colors.orange),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _trafficItem(String label, String val, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(height: 30, width: 1, color: const Color(0xFFF3F4F6));
  }

  Widget _buildBar(double heightFactor, String label, {bool isHigh = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isHigh 
                ? [const Color(0xFF7B61FF), const Color(0xFF9E8AFF)]
                : [const Color(0xFFE5E7EB), const Color(0xFFF3F4F6)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String trend, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
                Icon(icon, color: AppTheme.primaryPurple, size: 20),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: label == 'More Tools' ? 16 : 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                if (trend.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminFeatures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF9FAFF),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('ADMINISTRATOR SUITE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark, letterSpacing: 1.2)),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _featureTile(context, 'Evidence Vault', Icons.photo_library_rounded, '/evidence-vault'),
                  _featureTile(context, 'Live Monitoring', Icons.monitor_heart_rounded, '/live-monitoring'),
                  _featureTile(context, 'Security Alerts', Icons.notification_important_rounded, '/security-alerts'),
                  _featureTile(context, 'User Approvals', Icons.how_to_reg_rounded, '/user-approvals'),
                  _featureTile(context, 'Face Database', Icons.storage_rounded, '/face-database'),
                  _featureTile(context, 'Add New Person', Icons.person_add_rounded, '/add-person'),
                  _featureTile(context, 'Dataset Training', Icons.model_training_rounded, '/dataset-upload'),
                  _featureTile(context, 'Full Entry Logs', Icons.list_alt_rounded, '/entry-logs'),
                  _featureTile(context, 'System Analytics', Icons.analytics_rounded, '/analytics'),
                  _featureTile(context, 'System Settings', Icons.settings_suggest_rounded, '/system-settings'),
                  _featureTile(context, 'Role Management', Icons.admin_panel_settings_rounded, '/role-management'),
                  _featureTile(context, 'Audit Logs', Icons.history_edu_rounded, '/audit-logs'),
                  _featureTile(context, 'Face Detection Overlay', Icons.face_rounded, '/face-detection'),
                  _featureTile(context, 'Multi-Face Overlay', Icons.group_rounded, '/multi-face-detection'),
                  _featureTile(context, 'Server Health', Icons.dns_rounded, '/server-status'),
                  _featureTile(context, 'Storage Monitor', Icons.inventory_2_rounded, '/storage-usage'),
                  _featureTile(context, 'API Status', Icons.api_rounded, '/api-status'),
                  _featureTile(context, 'Security Logs', Icons.security_rounded, '/security-logs'),
                  _featureTile(context, 'Generate Reports', Icons.description_rounded, '/reports'),
                  _featureTile(context, 'Admin Core AI', Icons.auto_awesome_rounded, '/admin-ai-chat'),
                  _featureTile(context, 'Sign Out', Icons.logout_rounded, '/sign-out'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildEventTile(String title, String time, String status, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
            ],
          ),
          Row(
            children: [
              Text(status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: status == 'AUTHORIZED' ? const Color(0xFF10B981) : Colors.red)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
