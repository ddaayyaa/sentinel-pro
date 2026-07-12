import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Technical Issue';

  void _submitTicket() {
    if (_subjectController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    
    // Logic for ticket submission
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submitted successfully!')));
    Navigator.pop(context);
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
        title: const Text('Raise Ticket', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: const SizedBox(),
                items: ['Technical Issue', 'Access Denied', 'Camera Fault', 'Account Problem'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Subject', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildField(_subjectController, 'Brief summary of the issue'),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildField(_descController, 'Detailed description...', maxLines: 5),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Security Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      ),
    );
  }
}
