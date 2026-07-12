import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _handleProcess() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);
    
    try {
      final recognition = context.read<RecognitionProvider>();
      
      // Show scanning animation
      Navigator.pushNamed(context, '/scanning');
      
      final result = await recognition.recognizeImage(_selectedImage);
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/scan-result', 
          arguments: {
            'isGranted': result?.status.toLowerCase() == 'authorized',
            'result': result
          }
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Processing failed: $e')));
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
        title: const Text('Image Recognition', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/bulk-upload'),
            child: const Text('Bulk Mode', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _isProcessing ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    image: _selectedImage != null 
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.contain)
                        : null,
                  ),
                  child: _selectedImage == null ? _buildUploadPlaceholder() : null,
                ),
              ),
              if (_selectedImage != null && !_isProcessing)
                Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh, color: AppTheme.primaryPurple),
                    label: const Text('Change Image', style: TextStyle(color: AppTheme.primaryPurple)),
                  ),
                ),
              const SizedBox(height: 40),
              const Text('Security Protocols', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 16),
              _buildGuideline('Face must be clearly visible'),
              _buildGuideline('Avoid wearing masks or heavy accessories'),
              _buildGuideline('Ensure adequate lighting in the photo'),
              const Spacer(),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
                child: ElevatedButton(
                  onPressed: (_selectedImage == null || _isProcessing) ? null : _handleProcess,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
                  child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('Initiate AI Scan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
          child: const Icon(Icons.upload_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Upload Reference Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        const Text('Tap to browse gallery', style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textLight))),
        ],
      ),
    );
  }
}
