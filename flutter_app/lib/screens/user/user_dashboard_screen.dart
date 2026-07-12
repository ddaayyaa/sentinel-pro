import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh user specific data if needed
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SENTINEL PRO',
          style: TextStyle(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notifProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.accentPurpleLight,
              backgroundImage: user?.avatarUrl != null 
                ? NetworkImage(context.read<ApiService>().getImageUrl(user!.avatarUrl))
                : null,
              child: user?.avatarUrl == null 
                ? const Icon(Icons.person, color: AppTheme.primaryPurple, size: 20)
                : null,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Welcome
            Text(
              'Welcome, ${user?.fullName ?? user?.username ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Security System is Active',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            
            // AI Security Tip
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentPurpleLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryPurple),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user?.status == 'active' 
                        ? 'AI Security Tip: System accuracy is currently at 98.4%. Ensure front-facing shots for best verification.' 
                        : 'AI Security Tip: Your profile is currently pending admin approval. Once active, you can use all live features.',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
            const SizedBox(height: 24),

            // Live Feed Preview
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/live-camera'),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1557597774-9d273605dfa9?q=80&w=1000&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 64),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LIVE - Main Entrance',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Grid Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  Icons.videocam_rounded,
                  'Live Scan',
                  'Monitor Camera',
                  onTap: () => Navigator.pushNamed(context, '/live-camera'),
                ),
                _buildActionCard(
                  context,
                  Icons.image_search_rounded,
                  'Upload Image',
                  'Process Offline',
                  onTap: () => Navigator.pushNamed(context, '/upload-image'),
                ),
                _buildActionCard(
                  context,
                  Icons.history_rounded,
                  'History',
                  'View My Logs',
                  onTap: () => Navigator.pushNamed(context, '/scan-history'),
                ),
                _buildActionCard(
                  context,
                  Icons.apps_rounded,
                  'More Tools',
                  'Advanced Features',
                  onTap: () => _showAllFeatures(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Status
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Verification Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            user?.status == 'active' ? 'Your face ID is active and verified' : 'Your account is pending verification',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String sub, {VoidCallback? onTap}) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  void _showAllFeatures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('ADVANCED USER TOOLS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark, letterSpacing: 1.2)),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _featureTile(context, 'Face Scan Activity', Icons.history_rounded, '/scan-history'),
                  _featureTile(context, 'Detailed Activity Logs', Icons.list_alt_rounded, '/activity-logs'),
                  _featureTile(context, 'Bulk Image Processor', Icons.folder_copy_rounded, '/bulk-upload'),
                  _featureTile(context, 'Support Center', Icons.support_agent_rounded, '/support-center'),
                  _featureTile(context, 'Raise a Security Ticket', Icons.confirmation_number_outlined, '/raise-ticket'),
                  _featureTile(context, 'Track My Tickets', Icons.history_edu_outlined, '/my-tickets'),
                  _featureTile(context, 'Privacy Settings', Icons.privacy_tip_rounded, '/privacy-settings'),
                  _featureTile(context, 'Notification Settings', Icons.notifications_active_rounded, '/notification-settings'),
                  _featureTile(context, 'Data Sync Status', Icons.sync_rounded, '/data-sync'),
                  _featureTile(context, 'Rate Your Experience', Icons.star_rate_rounded, '/rate-experience'),
                  _featureTile(context, 'Terms & Conditions', Icons.gavel_rounded, '/terms-conditions'),
                  _featureTile(context, 'About Sentinel Pro', Icons.info_rounded, '/about'),
                  _featureTile(context, 'Report Connection Issue', Icons.wifi_off_rounded, '/no-internet'),
                  _featureTile(context, 'Session Timeout Simulator', Icons.timer_off_outlined, '/session-expired'),
                  _featureTile(context, 'Secure Onboarding', Icons.security_rounded, '/onboarding-secure'),
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
}
