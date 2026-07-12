import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

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
          'Notifications',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                // Mock marking all as read
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppTheme.primaryPurple),
              label: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications',
              subtitle: 'You are all caught up!',
            )
          : RefreshIndicator(
              onRefresh: () => provider.loadNotifications(),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _buildNotificationCard(context, item, provider);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, dynamic item, NotificationProvider provider) {
    final bool isUnread = !item.isRead;
    final timeStr = DateFormat('hh:mm a').format(item.timestamp);
    
    return GestureDetector(
      onTap: () => provider.markRead(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? AppTheme.primaryPurple.withOpacity(0.5) : const Color(0xFFE5E7EB),
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(item.type),
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'alert': return Icons.warning_amber_rounded;
      case 'success': return Icons.check_circle_outline_rounded;
      case 'info': return Icons.info_outline_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }
}
