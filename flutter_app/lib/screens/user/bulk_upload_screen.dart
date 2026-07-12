import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({super.key});

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _progress = 0.0;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;
    
    setState(() {
      _isUploading = true;
      _progress = 0.1;
    });

    try {
      final recognition = context.read<RecognitionProvider>();
      await recognition.recognizeBatch(_selectedFiles);
      
      setState(() => _progress = 1.0);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk processing complete! Check History.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bulk upload failed: $e')),
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
        title: const Text('Bulk Processing', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _isUploading ? null : _pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.file_upload_outlined, size: 48, color: AppTheme.primaryPurple),
                            SizedBox(height: 16),
                            Text('Select multiple images to process', style: TextStyle(fontSize: 16, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Selected Images (${_selectedFiles.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        if (_selectedFiles.isNotEmpty && !_isUploading)
                          TextButton(
                            onPressed: () => setState(() => _selectedFiles.clear()),
                            child: const Text('Clear All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._selectedFiles.asMap().entries.map((e) => _buildImageTile(e.value, e.key)),
                    
                    if (_isUploading) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Processing Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(value: _progress, backgroundColor: const Color(0xFFF3F4F6), valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
                child: ElevatedButton(
                  onPressed: (_selectedFiles.isEmpty || _isUploading) ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
                  child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Process All Images'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(File file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(file.path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ),
          if (!_isUploading)
            IconButton(onPressed: () => setState(() => _selectedFiles.removeAt(index)), icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20)),
        ],
      ),
    );
  }
}
