import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class TrainingProgressScreen extends StatefulWidget {
  const TrainingProgressScreen({super.key});

  @override
  State<TrainingProgressScreen> createState() => _TrainingProgressScreenState();
}

class _TrainingProgressScreenState extends State<TrainingProgressScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<TrainingProvider>().pollStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainingProvider>();
    final job = provider.currentJob;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Neural Engine Link', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(job?.status.toUpperCase() ?? 'INITIALIZING...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple, letterSpacing: 1.2)),
                      Text('${((job?.progress ?? 0) * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: job?.progress ?? 0.05,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildStatItem('Images', '${job?.processedImages ?? 0}/${job?.totalImages ?? 0}'),
                      _buildStatItem('Optimizer', job?.metrics['optimizer'] ?? 'Adam'),
                    ],
                  ),
                  const Divider(height: 48),
                  Row(
                    children: [
                      _buildStatItem('Accuracy', '${(job?.metrics['accuracy'] ?? 0.0) * 100}%'),
                      _buildStatItem('Time Left', job?.metrics['eta'] ?? 'Calculating...'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TRAINING TELEMETRY', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(height: 16),
                  Text('[INFO] Engine ID: ${job?.jobId ?? 'pending...'}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
                  Text('[INFO] Current File: ${job?.currentFile ?? 'accessing disk...'}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
                  const Text('[SUCCESS] Neural weights initialized', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontFamily: 'monospace')),
                  if (job?.status == 'running') const Text('[WARN] GPU load increasing', style: TextStyle(color: Colors.orange, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
