import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/ai_service.dart';

class AdminAIChatScreen extends StatefulWidget {
  const AdminAIChatScreen({super.key});

  @override
  State<AdminAIChatScreen> createState() => _AdminAIChatScreenState();
}

class _AdminAIChatScreenState extends State<AdminAIChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Greetings, Administrator. I am the Sentinel Pro Core AI. I have full access to system documentation and security protocols. How can I assist you in managing the network today?");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, {'text': text, 'isMe': false});
    });
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text;
    setState(() {
      _messages.insert(0, {'text': userText, 'isMe': true});
      _isTyping = true;
    });
    _controller.clear();

    // GPT AI Integration
    final aiService = Provider.of<AIService>(context, listen: false);
    final stats = Provider.of<DashboardProvider>(context, listen: false).stats;

    try {
      final response = await aiService.getChatResponse(userText, stats);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage(response);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage("System error: Unable to communicate with AI Core.");
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Core AI', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('System Level Access', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Text('Core AI is analyzing', style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.primaryPurple))),
                ],
              ).animate().fadeIn(),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            color: isMe ? Colors.white : AppTheme.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: isMe ? 0.05 : -0.05);
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter system command or query...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
