import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';

class EditPersonScreen extends StatefulWidget {
  const EditPersonScreen({super.key});

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late FaceRecord _face;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _face = ModalRoute.of(context)!.settings.arguments as FaceRecord;
      _nameController = TextEditingController(text: _face.personName);
      _idController = TextEditingController(text: _face.personId);
      _isInitialized = true;
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove ${_face.personName} from the biometric database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<FaceProvider>().deleteFace(_face.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Identity', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryPurple, width: 2),
                  image: _face.imagePaths.isNotEmpty
                      ? DecorationImage(image: NetworkImage(context.read<ApiService>().getImageUrl(_face.imagePaths[0])), fit: BoxFit.cover)
                      : null,
                ),
                child: _face.imagePaths.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(height: 40),
            const Text('Full Name', style: TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildTextField(_nameController),
            const SizedBox(height: 24),
            const Text('Security ID', style: TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildTextField(_idController, enabled: false),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleDelete,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Remove Person'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: enabled ? AppTheme.textDark : Colors.grey),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
      ),
    );
  }
}
