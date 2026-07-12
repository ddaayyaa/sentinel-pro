import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class UserApprovalsScreen extends StatefulWidget {
  const UserApprovalsScreen({super.key});

  @override
  State<UserApprovalsScreen> createState() => _UserApprovalsScreenState();
}

class _UserApprovalsScreenState extends State<UserApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers(status: 'pending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final pendingUsers = provider.users.where((u) => u.status == 'pending').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Identity Approvals', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading && pendingUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pendingUsers.isEmpty
              ? const EmptyState(icon: Icons.how_to_reg_rounded, title: 'Queue Cleared', subtitle: 'No pending registration requests')
              : Column(
                  children: [
                    _buildApprovalStats(pendingUsers.length),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: pendingUsers.length,
                        itemBuilder: (context, index) => _buildProfessionalApprovalCard(pendingUsers[index], provider),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildApprovalStats(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          const Text('AWAITING REVIEW:', style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('$count USERS', style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalApprovalCard(dynamic user, UserManagementProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: AppTheme.accentPurpleLight.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryPurple, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName ?? user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                      Text('Dept: ${user.department ?? "General"}', style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFF), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => provider.rejectUser(user.id!, 'Access Denied'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Deny Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.approveUser(user.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Verify & Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
