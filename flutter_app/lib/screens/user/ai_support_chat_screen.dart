import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../providers/providers.dart';

class AISupportChatScreen extends StatefulWidget {
  final String mode;
  const AISupportChatScreen({super.key, this.mode = 'chat'});

  @override
  State<AISupportChatScreen> createState() => _AISupportChatScreenState();
}

class _AISupportChatScreenState extends State<AISupportChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Greetings. I am the Sentinel Pro AI Neural Core. I have synchronized with your system metrics and am ready for real-time diagnostic analysis. How can I assist you?");
  }

  void _addBotMessage(String text) {
    if (mounted) {
      setState(() {
        _messages.insert(0, {'text': text, 'isMe': false, 'time': DateTime.now()});
      });
    }
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text;
    
    setState(() {
      _messages.insert(0, {'text': userText, 'isMe': true, 'time': DateTime.now()});
      _isTyping = true;
    });
    _controller.clear();

    final aiService = context.read<AIService>();
    final stats = context.read<DashboardProvider>().stats;

    try {
      // Direct integration with real AI backend
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
          _addBotMessage("Critical error in neural link. Please verify your API configuration.");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Tech Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            _buildAIPulse(),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEURAL CORE v2.4', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                Text('ENCRYPTED CONNECTION', style: TextStyle(color: Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded, color: Colors.white70, size: 20), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                ),
              ),
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildAdvancedMessage(_messages[index]),
              ),
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildTerminalInput(),
        ],
      ),
    );
  }

  Widget _buildAIPulse() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), shape: BoxShape.circle),
      child: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 18),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white24);
  }

  Widget _buildAdvancedMessage(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryPurple : const Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              border: isMe ? null : Border.all(color: Colors.white10),
            ),
            child: Text(
              msg['text'],
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontFamily: isMe ? null : 'monospace'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              isMe ? 'SENT' : 'AI_RESPONSE',
              style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ANALYZING DATASTREAM', style: TextStyle(color: Colors.cyanAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTerminalInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF1E293B), border: Border(top: BorderSide(color: Colors.white10))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                  decoration: const InputDecoration(hintText: 'Enter command or query...', hintStyle: TextStyle(color: Colors.white24, fontSize: 12), border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
