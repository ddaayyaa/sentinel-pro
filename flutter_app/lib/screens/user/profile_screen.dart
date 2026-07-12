import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      // Logic for real upload would go here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    }
  }

  void _editInfo() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final nameCtrl = TextEditingController(text: user?.fullName);
    final phoneCtrl = TextEditingController(text: user?.phone);
    final deptCtrl = TextEditingController(text: user?.department);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await auth.updateProfile({
                'full_name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'department': deptCtrl.text.trim(),
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Profile updated' : 'Update failed')),
                );
              }
            }, 
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

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
          'Profile',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryPurple, width: 2),
                      image: user?.avatarUrl != null 
                        ? DecorationImage(
                            image: NetworkImage(context.read<ApiService>().getImageUrl(user!.avatarUrl)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: user?.avatarUrl == null 
                      ? const Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _updateAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Name and Role
            Text(
              user?.fullName ?? user?.username ?? 'Anonymous User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user?.role.toUpperCase() ?? 'USER',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Information Card
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
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    'Username',
                    user?.username ?? 'Not set',
                  ),
                  const Divider(height: 40, color: Color(0xFFF3F4F6)),
                  _buildInfoRow(
                    Icons.mail_outline_rounded,
                    'Email',
                    user?.email ?? 'Not set',
                  ),
                  const Divider(height: 40, color: Color(0xFFF3F4F6)),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Phone',
                    user?.phone ?? 'Not linked',
                  ),
                  const Divider(height: 40, color: Color(0xFFF3F4F6)),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Department',
                    user?.department ?? 'Not assigned',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Edit Profile Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)],
                ),
              ),
              child: ElevatedButton(
                onPressed: _editInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Update Profile Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
