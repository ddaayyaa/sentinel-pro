import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/providers.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _deptController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Face Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppTheme.accentPurpleLight, child: Icon(Icons.camera_alt_rounded, color: AppTheme.primaryPurple)),
              title: const Text('Capture from Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) setState(() => _selectedImages.add(File(image.path)));
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppTheme.accentPurpleLight, child: Icon(Icons.photo_library_rounded, color: AppTheme.primaryPurple)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final List<XFile> images = await _picker.pickMultiImage();
                if (images.isNotEmpty) setState(() => _selectedImages.addAll(images.map((x) => File(x.path))));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final id = _idController.text.trim();

    if (name.isEmpty || id.isEmpty || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide name, ID, and at least one photo')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = context.read<ApiService>();
      final result = await apiService.registerFace(
        personName: name,
        personId: id,
        department: _deptController.text.trim(),
        images: _selectedImages,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Person added and training started!')),
          );
          context.read<FaceProvider>().loadFaces(refresh: true);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add person: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Person',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Full Name'),
            _buildTextField(_nameController, 'Enter full name'),
            
            const SizedBox(height: 20),
            _buildLabel('ID Number'),
            _buildTextField(_idController, 'Enter unique ID'),

            const SizedBox(height: 20),
            _buildLabel('Department (Optional)'),
            _buildTextField(_deptController, 'Enter department'),
            
            const SizedBox(height: 24),
            _buildLabel('Upload Photos (${_selectedImages.length})'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryPurple, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      _selectedImages.isEmpty ? 'Select multiple face images' : '${_selectedImages.length} images selected',
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 40),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)],
                ),
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add to Database'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
