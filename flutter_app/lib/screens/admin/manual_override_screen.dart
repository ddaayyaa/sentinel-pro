import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class ManualOverrideScreen extends StatefulWidget {
  const ManualOverrideScreen({super.key});

  @override
  State<ManualOverrideScreen> createState() => _ManualOverrideScreenState();
}

class _ManualOverrideScreenState extends State<ManualOverrideScreen> {
  final _noteController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _handleDecision(EntryLog log, String decision) async {
    setState(() => _isProcessing = true);
    final api = context.read<ApiService>();
    
    try {
      final success = await api.overrideEntry(log.id!, decision, _noteController.text.trim());
      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Access manually $decision')));
          Navigator.popUntil(context, ModalRoute.withName('/entry-logs'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save manual override')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntryLog log = ModalRoute.of(context)!.settings.arguments as EntryLog;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Manual Override', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF3F4F6),
                    backgroundImage: log.imagePath != null ? NetworkImage('${context.read<ApiService>().baseUrl}/${log.imagePath}') : null,
                    child: log.imagePath == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  const SizedBox(height: 24),
                  Text(log.personName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  const Text('Identity unrecognized by AI engine', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Administrative Note', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textLight)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for manual override...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            const SizedBox(height: 48),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDecision(log, 'authorized'),
                      icon: const Icon(Icons.verified_user_outlined, color: Colors.white),
                      label: const Text('Grant Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDecision(log, 'denied'),
                      icon: const Icon(Icons.gpp_bad_outlined, color: Colors.white),
                      label: const Text('Deny Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
