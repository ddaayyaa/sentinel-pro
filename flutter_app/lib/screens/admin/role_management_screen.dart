import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final users = provider.users;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Access Control', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildRoleOverview(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: users.length,
                    itemBuilder: (context, index) => _buildUserRoleCard(users[index], provider),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoleOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Hierarchy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _roleChip('Administrator', Colors.purple, true),
              const SizedBox(width: 8),
              _roleChip('Security Lead', Colors.blue, false),
              const SizedBox(width: 8),
              _roleChip('Standard User', Colors.grey, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUserRoleCard(dynamic user, UserManagementProvider provider) {
    final bool isAdmin = user.role == 'admin';
    final bool isDisabled = user.status == 'disabled';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAdmin ? AppTheme.primaryPurple.withOpacity(0.3) : const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDisabled ? Colors.grey[300] : AppTheme.accentPurpleLight,
                child: Text(user.username[0].toUpperCase(), style: TextStyle(color: isDisabled ? Colors.grey : AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.username, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15,
                        decoration: isDisabled ? TextDecoration.lineThrough : null,
                      )
                    ),
                    Text(user.email, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _roleBadge(user.role),
                  const SizedBox(height: 4),
                  _statusBadge(user.status),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Privilege Escalation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textLight)),
              Switch(
                value: isAdmin,
                onChanged: (v) {
                  provider.setRole(user.id!, v ? 'admin' : 'user');
                },
                activeColor: AppTheme.primaryPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Disable/Enable Action
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.toggleStatus(user.id!, isDisabled ? 'active' : 'disabled');
                  },
                  icon: Icon(isDisabled ? Icons.check_circle_outline_rounded : Icons.block_flipped, size: 16),
                  label: Text(isDisabled ? 'Enable' : 'Disable', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDisabled ? Colors.green : Colors.orange,
                    side: BorderSide(color: isDisabled ? Colors.green : Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delete Action
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteConfirm(context, user, provider);
                  },
                  icon: const Icon(Icons.delete_forever_rounded, size: 16),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, dynamic user, UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete ${user.username}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteUser(user.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${user.username} deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'active' ? Colors.green : (status == 'disabled' ? Colors.grey : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _roleBadge(String role) {
    final color = role == 'admin' ? AppTheme.primaryPurple : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _permissionIcon(IconData icon, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, size: 18, color: enabled ? AppTheme.primaryPurple : Colors.grey.withOpacity(0.3)),
    );
  }
}
