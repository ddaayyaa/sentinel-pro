import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    // Simulate fetching user specific tickets from backend
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _tickets = [
          {'title': 'Login Issue', 'id': '#1234', 'time': '2 hours ago', 'status': 'Open', 'color': Colors.orange},
          {'title': 'Scan Error', 'id': '#1231', 'time': '1 day ago', 'status': 'In Progress', 'color': AppTheme.primaryPurple},
          {'title': 'Feature Request', 'id': '#1230', 'time': '3 days ago', 'status': 'Closed', 'color': const Color(0xFF10B981)},
        ];
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Security Tickets', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? const EmptyState(icon: Icons.confirmation_number_outlined, title: 'No Tickets Found', subtitle: 'You haven\'t raised any tickets yet')
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final t = _tickets[index];
                      return _buildTicketCard(t);
                    },
                  ),
                ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Text('${t['id']} • ${t['time']}', style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: (t['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(t['status'] as String, style: TextStyle(color: t['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
