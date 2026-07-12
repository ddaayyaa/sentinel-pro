import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class StorageUsageScreen extends StatefulWidget {
  const StorageUsageScreen({super.key});

  @override
  State<StorageUsageScreen> createState() => _StorageUsageScreenState();
}

class _StorageUsageScreenState extends State<StorageUsageScreen> {
  Map<String, dynamic>? _storageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStorage();
  }

  Future<void> _fetchStorage() async {
    final api = context.read<ApiService>();
    final data = await api.getStorageStats();
    if (mounted) {
      setState(() {
        _storageData = data;
        _isLoading = false;
      });
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
        title: const Text('Storage Intelligence', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryPurple), onPressed: _fetchStorage),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiskOverview(),
                  const SizedBox(height: 32),
                  const Text('Data Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDistributionCard(),
                  const SizedBox(height: 32),
                  const Text('Folder Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildFolderList(),
                ],
              ),
            ),
    );
  }

  Widget _buildDiskOverview() {
    final system = _storageData?['system'] ?? {};
    final double percent = (system['percent_used'] ?? 0.0) / 100.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL CAPACITY', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text(system['total_space'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple),
                ),
              ),
              Column(
                children: [
                  Text('${(percent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('USED', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _diskMetric('Free', system['free_space'] ?? '0GB', Colors.green),
              _diskMetric('Used', system['used_space'] ?? '0GB', AppTheme.primaryPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _diskMetric(String label, String val, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildDistributionCard() {
    final counts = _storageData?['file_counts'] ?? {};
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          _countRow('Face Biometric Profiles', counts['face_records']?.toString() ?? '0', Icons.face_rounded, Colors.purple),
          const Divider(height: 32),
          _countRow('Security Snapshots', counts['entry_snapshots']?.toString() ?? '0', Icons.camera_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _countRow(String label, String val, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildFolderList() {
    final folders = _storageData?['folders'] ?? {};
    return Column(
      children: folders.entries.map<Widget>((e) => _folderItem(e.key.toString().replaceAll('_', ' ').toUpperCase(), e.value.toString())).toList(),
    );
  }

  Widget _folderItem(String name, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
          Text(size, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple, fontSize: 13)),
        ],
      ),
    );
  }
}
