import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class AdminUserDetailsScreen extends StatelessWidget {
  const AdminUserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    final joinDate = user.createdAt != null ? DateFormat('MMM dd, yyyy').format(user.createdAt!) : 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Management', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: user.avatarUrl != null ? NetworkImage('${context.read<ApiService>().baseUrl}/${user.avatarUrl}') : null,
                child: user.avatarUrl == null ? const Icon(Icons.person, color: Colors.grey, size: 50) : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.fullName ?? user.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  _buildDetailRow(Icons.mail_outline_rounded, 'Email', user.email),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', user.phone ?? 'Not provided'),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(Icons.business_center_outlined, 'Department', user.department ?? 'General'),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(Icons.calendar_today_rounded, 'Joined', joinDate),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(Icons.verified_user_outlined, 'Status', user.status.toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Deactivate'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Modify Role'),
                  ),
                ),
              ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}
