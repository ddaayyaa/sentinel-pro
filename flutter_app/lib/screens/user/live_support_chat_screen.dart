import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class LiveSupportChatScreen extends StatefulWidget {
  const LiveSupportChatScreen({super.key});

  @override
  State<LiveSupportChatScreen> createState() => _LiveSupportChatScreenState();
}

class _LiveSupportChatScreenState extends State<LiveSupportChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAgentTyping = false;

  @override
  void initState() {
    super.initState();
    _addMessage("System: Connecting to a security specialist...", isMe: false);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _addMessage("Agent Sarah: Hello! I'm your security assistant. How can I help you with Sentinel Pro today?", isMe: false);
    });
  }

  void _addMessage(String text, {required bool isMe}) {
    setState(() {
      _messages.insert(0, {'text': text, 'isMe': isMe});
    });
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text;
    _addMessage(text, isMe: true);
    _controller.clear();
    
    setState(() => _isAgentTyping = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isAgentTyping = false);
        _addMessage("Agent Sarah: I've noted your request regarding '$text'. Let me look into that for you.", isMe: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Support', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Agent Sarah is online', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
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
              itemBuilder: (context, index) => _buildBubble(_messages[index]),
            ),
          ),
          if (_isAgentTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text('Sarah is typing...', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  SizedBox(width: 8),
                  SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 14)),
      ),
    ).animate().fadeIn().slideX(begin: isMe ? 0.1 : -0.1);
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Type your message...', border: InputBorder.none),
              ),
            ),
            IconButton(onPressed: _handleSend, icon: const Icon(Icons.send_rounded, color: AppTheme.primaryPurple)),
          ],
        ),
      ),
    );
  }
}
