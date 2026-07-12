import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class ModelTrainingScreen extends StatefulWidget {
  const ModelTrainingScreen({super.key});

  @override
  State<ModelTrainingScreen> createState() => _ModelTrainingScreenState();
}

class _ModelTrainingScreenState extends State<ModelTrainingScreen> {
  String selectedModel = 'DeepFace (Hybrid)';
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingProvider>().loadHistory();
      _startPolling();
    });
  }

  void _startPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final provider = context.read<TrainingProvider>();
      if (provider.isTraining) {
        provider.pollStatus();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _handleStartTraining() async {
    final provider = context.read<TrainingProvider>();
    final success = await provider.startTraining([], modelType: selectedModel);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Training started successfully' : 'Failed to start training')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainingProvider>();

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
          'AI Model Training',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildStatusCard(provider),
            
            const SizedBox(height: 32),
            const Text('Training Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildDropdown('Algorithm', ['DeepFace (Hybrid)', 'OpenFace', 'FaceNet'], (v) => setState(() => selectedModel = v!)),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Augmentation', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(value: true, onChanged: (v) {}, activeColor: AppTheme.primaryPurple),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: provider.isTraining ? null : _handleStartTraining,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: provider.isTraining 
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('System is Training...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        )
                      : const Text('Start Full Re-Training', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Training History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...provider.history.map((h) => _buildHistoryItem(h)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TrainingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SYSTEM ENGINE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  provider.isTraining ? 'TRAINING...' : 'OPTIMIZED',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Face Recognition Core v2.1', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Current Accuracy: 98.4%', style: TextStyle(color: Colors.white, fontSize: 14)),
          if (provider.isTraining) ...[
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: provider.currentJob?.progress ?? 0.0, 
              backgroundColor: Colors.white24, 
              valueColor: const AlwaysStoppedAnimation(Colors.white)
            ),
            const SizedBox(height: 8),
            Text(
              'Processing: ${((provider.currentJob?.progress ?? 0.0) * 100).toInt()}% (${provider.currentJob?.currentFile})', 
              style: const TextStyle(color: Colors.white70, fontSize: 12)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
        DropdownButton<String>(
          value: selectedModel,
          isExpanded: true,
          underline: const SizedBox(),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['model_type'] ?? 'DeepFace', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(data['date'] ?? '2024-05-01', style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
            ],
          ),
          Text(data['status'] ?? 'Success', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
