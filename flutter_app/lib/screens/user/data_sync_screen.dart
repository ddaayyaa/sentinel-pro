import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DataSyncScreen extends StatefulWidget {
  const DataSyncScreen({super.key});

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  Future<void> _startSync() async {
    setState(() => _isSyncing = true);
    _animController.repeat();
    
    // Simulate real data sync logic
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      _animController.stop();
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security data synchronized successfully!')));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
        title: const Text('Data Synchronization', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animController,
              child: const Icon(Icons.sync_rounded, size: 80, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 32),
            const Text('Sync Status: Up to Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Last synced: Today at 10:45 AM', style: TextStyle(color: AppTheme.textLight)),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  _syncDetail('Face Database', '2 records'),
                  const Divider(height: 32),
                  _syncDetail('Local Logs', '14 events'),
                  const Divider(height: 32),
                  _syncDetail('Security Tokens', 'Valid'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSyncing ? null : _startSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_isSyncing ? 'Syncing...' : 'Force Manual Sync', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncDetail(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(status, style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
