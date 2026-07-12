import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  double threshold = 0.75;
  bool enableBuzzer = true;
  bool saveUnauthorized = true;
  bool emailAlerts = false;
  String recognitionMode = 'Strict';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final api = context.read<ApiService>();
      _urlController.text = api.baseUrl;
      final settings = await api.getSettings();
      if (mounted) {
        setState(() {
          threshold = double.tryParse(settings['confidence_threshold']?.toString() ?? '0.75') ?? 0.75;
          enableBuzzer = settings['enable_buzzer']?.toString() == 'true';
          saveUnauthorized = settings['save_unauthorized']?.toString() == 'true';
          emailAlerts = settings['email_alerts']?.toString() == 'true';
          recognitionMode = settings['recognition_mode']?.toString() ?? 'Strict';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    }
  }

  Future<void> _saveSettings() async {
    final api = context.read<ApiService>();
    
    if (_urlController.text.isNotEmpty && _urlController.text != api.baseUrl) {
      await api.updateBaseUrl(_urlController.text.trim());
    }

    final success = await api.updateSettings({
      'confidence_threshold': threshold.toString(),
      'enable_buzzer': enableBuzzer.toString(),
      'save_unauthorized': saveUnauthorized.toString(),
      'email_alerts': emailAlerts.toString(),
      'recognition_mode': recognitionMode,
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'System configuration synchronized' : 'Failed to update core'),
          backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Tech Dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('COMMAND CENTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader('NETWORK INFRASTRUCTURE', Icons.hub_rounded),
                  _buildGlassCard(_buildNetworkSection()),
                  const SizedBox(height: 32),
                  
                  _buildHeader('NEURAL LOGIC ENGINE', Icons.psychology_rounded),
                  _buildGlassCard(_buildLogicSection()),
                  const SizedBox(height: 32),
                  
                  _buildHeader('SECURITY PROTOCOLS', Icons.security_rounded),
                  _buildGlassCard(_buildSecuritySection()),
                  const SizedBox(height: 48),
                  
                  _buildSyncButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildGlassCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildNetworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('API CORE ENDPOINT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  prefixIcon: const Icon(Icons.dns_rounded, color: Colors.white24, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _testConnection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.cyanAccent, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Global biometric data synchronization point.', style: TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Future<void> _testConnection() async {
    final api = context.read<ApiService>();
    final testUrl = _urlController.text.trim();
    
    setState(() => _isLoading = true);
    final ok = await api.testConnection(testUrl);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'CORE HANDSHAKE SUCCESSFUL' : 'NODE CONNECTION REFUSED'),
          backgroundColor: ok ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildLogicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('NEURAL THRESHOLD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('${(threshold * 100).toInt()}%', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ],
        ),
        Slider(
          value: threshold,
          min: 0.5,
          max: 0.99,
          activeColor: Colors.cyanAccent,
          inactiveColor: Colors.white10,
          onChanged: (v) => setState(() => threshold = v),
        ),
        const Divider(color: Colors.white10, height: 40),
        const Text('RECOGNITION AGGRESSION', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTechChoice('Strict', 'High precision, maximum security verification.'),
        _buildTechChoice('Balanced', 'Standard operational profile.'),
        _buildTechChoice('Fast', 'Low latency, reduced verification checks.'),
      ],
    );
  }

  Widget _buildTechChoice(String label, String sub) {
    bool isSelected = recognitionMode.contains(label);
    return GestureDetector(
      onTap: () => setState(() => recognitionMode = label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.cyanAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                if (isSelected) const Icon(Icons.radar_rounded, color: Colors.cyanAccent, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: isSelected ? Colors.cyanAccent.withOpacity(0.7) : Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        _buildTechSwitch('HARDWARE ALARM', 'Acoustic buzzer on breach', enableBuzzer, (v) => setState(() => enableBuzzer = v)),
        const Divider(color: Colors.white10, height: 32),
        _buildTechSwitch('EVIDENCE UPLOAD', 'Auto-archive threat frames', saveUnauthorized, (v) => setState(() => saveUnauthorized = v)),
        const Divider(color: Colors.white10, height: 32),
        _buildTechSwitch('PUSH DISPATCH', 'Global admin breach alerts', emailAlerts, (v) => setState(() => emailAlerts = v)),
      ],
    );
  }

  Widget _buildTechSwitch(String title, String sub, bool val, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 10)),
          ]),
        ),
        Switch(value: val, onChanged: onChanged, activeColor: Colors.cyanAccent, activeTrackColor: Colors.cyanAccent.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildSyncButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20)],
        gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
      ),
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.sync_rounded, color: Colors.white),
        label: const Text('INITIALIZE SYSTEM SYNC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}
