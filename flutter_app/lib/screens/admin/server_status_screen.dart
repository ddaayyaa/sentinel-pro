import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  Map<String, dynamic>? _status;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final status = await api.getSystemStatus();
      if (mounted) {
        setState(() {
          if (status.isEmpty) {
            _error = "Server unreachable. Ensure your phone and PC are on the same network.";
          } else {
            _status = status;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Connection Error: $e";
          _isLoading = false;
        });
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
        title: const Text('Real-Time Server Health', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryPurple),
            onPressed: _fetchStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Pinging System Core...', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                ],
              ),
            )
          : _error != null
              ? _buildErrorUI()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHealthCard(),
                      const SizedBox(height: 32),
                      const Text('Live Hardware Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildMetricRow('CPU Load', _status?['cpu_load'] ?? '0%', Icons.speed_rounded, Colors.blue),
                      _buildMetricRow('RAM Usage', _status?['ram_usage'] ?? '0%', Icons.memory_rounded, Colors.purple),
                      _buildMetricRow('Disk Health', _status?['disk_usage'] ?? '0%', Icons.storage_rounded, Colors.orange),
                      _buildMetricRow('System Uptime', _status?['uptime'] ?? '0:00:00', Icons.timer_rounded, Colors.green),
                      const SizedBox(height: 32),
                      const Text('Infrastructure Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorUI() {
    final api = context.read<ApiService>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text('Network Link Severed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  const Text('Current Target URL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(api.baseUrl, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.primaryPurple)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchStatus,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, minimumSize: const Size(200, 50)),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard() {
    final bool isHealthy = _status?['database'] == 'connected';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy 
            ? [const Color(0xFF10B981), const Color(0xFF059669)] 
            : [const Color(0xFFEF4444), const Color(0xFFDC2626)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: (isHealthy ? Colors.green : Colors.red).withOpacity(0.3), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OPERATIONAL STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
              Icon(isHealthy ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isHealthy ? 'STABLE' : 'CRITICAL',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 4),
          Text(
            isHealthy ? 'All systems functional' : 'System backend is unreachable',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          _infoItem('OS Architecture', _status?['platform'] ?? 'Unknown'),
          const Divider(height: 32),
          _infoItem('Database Engine', 'SQLite 3.x'),
          const Divider(height: 32),
          _infoItem('API Version', _status?['version'] ?? 'N/A'),
          const Divider(height: 32),
          _infoItem('Server Time', _status?['server_time'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 13)),
      ],
    );
  }
}
