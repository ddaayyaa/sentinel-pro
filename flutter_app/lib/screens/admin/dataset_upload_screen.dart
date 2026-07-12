import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class DatasetUploadScreen extends StatefulWidget {
  const DatasetUploadScreen({super.key});

  @override
  State<DatasetUploadScreen> createState() => _DatasetUploadScreenState();
}

class _DatasetUploadScreenState extends State<DatasetUploadScreen> {
  final List<File> _datasetFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _selectedEngine = 'DeepFace (Ultra)';

  Future<void> _pickDataset() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _datasetFiles.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _startTraining() async {
    if (_datasetFiles.isEmpty) return;

    setState(() => _isUploading = true);
    final trainingProvider = context.read<TrainingProvider>();
    
    final success = await trainingProvider.startTraining(
      _datasetFiles,
      modelType: _selectedEngine.toLowerCase().contains('deepface') ? 'deep_face' : 'standard',
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, '/training-progress');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate training engine')),
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Dataset Training', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            const Text('Engine Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildEngineSelector(),
            const SizedBox(height: 32),
            const Text('Dataset Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildUploadZone(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI CORE STATUS', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('READY', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Face Neural Engine v2', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('System is optimized for bulk biometric processing.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEngineSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          _engineTile('DeepFace (Ultra)', 'Highest accuracy, hybrid neural processing', true),
          const Divider(height: 32),
          _engineTile('OpenFace (Lite)', 'Faster training, optimized for mobile', false),
        ],
      ),
    );
  }

  Widget _engineTile(String title, String sub, bool recommended) {
    bool isSelected = _selectedEngine == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedEngine = title),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppTheme.primaryPurple : Colors.grey, width: 2),
              color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
            ),
            child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('ADVANCED', style: TextStyle(color: AppTheme.primaryPurple, fontSize: 8, fontWeight: FontWeight.bold))),
                    ]
                  ],
                ),
                Text(sub, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: _pickDataset,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2), style: BorderStyle.solid, width: 1.5),
        ),
        child: _datasetFiles.isEmpty ? _emptyUploadUI() : _filesGridUI(),
      ),
    );
  }

  Widget _emptyUploadUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryPurple, size: 32)),
        const SizedBox(height: 16),
        const Text('Drop Dataset Images Here', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const Text('Support JPEG, PNG, ZIP (Max 2GB)', style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
      ],
    );
  }

  Widget _filesGridUI() {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: _datasetFiles.length > 8 ? 8 : _datasetFiles.length,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: FileImage(_datasetFiles[index]), fit: BoxFit.cover)),
          ),
        ),
        if (_datasetFiles.length > 8)
          Positioned(bottom: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)), child: Text('+${_datasetFiles.length - 8} more', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
        Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => setState(() => _datasetFiles.clear()), child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)))),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
          child: ElevatedButton(
            onPressed: (_datasetFiles.isEmpty || _isUploading) ? null : _startTraining,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 60)),
            child: _isUploading 
              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 12), Text('Synchronizing Dataset...')])
              : const Text('Start Neural Re-Training', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Manage Active Jobs', style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
