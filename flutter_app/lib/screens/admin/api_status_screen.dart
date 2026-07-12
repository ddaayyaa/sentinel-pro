import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ApiStatusScreen extends StatefulWidget {
  const ApiStatusScreen({super.key});

  @override
  State<ApiStatusScreen> createState() => _ApiStatusScreenState();
}

class _ApiStatusScreenState extends State<ApiStatusScreen> {
  Map<String, dynamic>? _apiData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApiStatus();
  }

  Future<void> _fetchApiStatus() async {
    final api = context.read<ApiService>();
    final data = await api.getApiHealth();
    if (mounted) {
      setState(() {
        _apiData = data;
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
        title: const Text('API Infrastructure', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryPurple), onPressed: _fetchApiStatus),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPulseHeader(),
                  const SizedBox(height: 32),
                  const Text('Endpoint Monitor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildEndpointList(),
                  const SizedBox(height: 32),
                  const Text('Security Stack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSecurityStack(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPulseHeader() {
    final bool isHealthy = _apiData?['status'] == 'healthy';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isHealthy ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          _pulseIndicator(isHealthy ? Colors.green : Colors.red),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isHealthy ? 'SYSTEM OPERATIONAL' : 'SYSTEM DEGRADED', style: TextStyle(fontWeight: FontWeight.bold, color: isHealthy ? Colors.green : Colors.red, fontSize: 16, letterSpacing: 1.1)),
                const Text('Real-time API response verification active.', style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulseIndicator(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]),
        ),
      ),
    );
  }

  Widget _buildEndpointList() {
    final List endpoints = _apiData?['endpoints'] ?? [];
    return Column(
      children: endpoints.map<Widget>((e) => _endpointTile(e)).toList(),
    );
  }

  Widget _endpointTile(Map e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(e['method'], style: const TextStyle(color: AppTheme.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(e['path'], style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w500))),
          Text(e['latency'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSecurityStack() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _stackItem('AUTH_ENGINE', _apiData?['auth_engine'] ?? 'JWT'),
          const Divider(color: Colors.white10, height: 32),
          _stackItem('CORS_POLICY', _apiData?['cors_policy'] ?? 'STRICT'),
          const Divider(color: Colors.white10, height: 32),
          _stackItem('MAX_PAYLOAD', _apiData?['max_payload'] ?? '2GB'),
        ],
      ),
    );
  }

  Widget _stackItem(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        Text(val, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      ],
    );
  }
}
