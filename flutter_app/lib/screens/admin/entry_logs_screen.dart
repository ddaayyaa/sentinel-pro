import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../services/api_service.dart';

class EntryLogsScreen extends StatefulWidget {
  const EntryLogsScreen({super.key});

  @override
  State<EntryLogsScreen> createState() => _EntryLogsScreenState();
}

class _EntryLogsScreenState extends State<EntryLogsScreen> {
  String _activeFilter = 'ALL'; // 'ALL', 'AUTHORIZED', 'UNAUTHORIZED'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryLogProvider>().loadLogs(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryLogProvider>();
    final allLogs = provider.logs;
    final logs = _activeFilter == 'ALL' 
        ? allLogs 
        : allLogs.where((l) => l.status.toUpperCase() == _activeFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security Entry Logs',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['ALL', 'AUTHORIZED', 'UNAUTHORIZED'].map((f) {
                  bool isSelected = _activeFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryPurple : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(color: isSelected ? Colors.white : AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryPurple),
            onPressed: () {
              // Future implementation: Filter dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter feature coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading && logs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const EmptyState(
                  icon: Icons.assignment_late_outlined,
                  title: 'No Logs Recorded',
                  subtitle: 'Activity will appear here after detections',
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadLogs(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return _buildProfessionalLogTile(logs[index], provider);
                    },
                  ),
                ),
    );
  }

  Widget _buildProfessionalLogTile(dynamic log, EntryLogProvider provider) {
    // Full Audit Timestamp: Year, Month, Day, Hour, Minute, Second
    final fullDate = DateFormat('EEEE, dd MMMM yyyy').format(log.timestamp);
    final fullTime = DateFormat('HH:mm:ss').format(log.timestamp);
    
    final bool isAuthorized = log.status.toLowerCase() == 'authorized';
    final bool isUnauthorized = log.status.toLowerCase() == 'unauthorized';
    final api = context.read<ApiService>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnauthorized ? Colors.red.withOpacity(0.3) : const Color(0xFFE5E7EB),
          width: isUnauthorized ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnauthorized ? Colors.red.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Date and ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUnauthorized ? Colors.red.withOpacity(0.05) : const Color(0xFFF3F4F6).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: isUnauthorized ? Colors.red : AppTheme.textLight),
                    const SizedBox(width: 8),
                    Text(
                      fullDate,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUnauthorized ? Colors.red : AppTheme.textLight),
                    ),
                  ],
                ),
                Text(
                  'ID: #${log.id ?? '---'}',
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Body: Person Info and Time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Identity Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isAuthorized ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: log.imagePath != null
                        ? DecorationImage(
                            image: NetworkImage(api.getImageUrl(log.imagePath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(
                      color: isAuthorized ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    ),
                  ),
                  child: log.imagePath == null
                      ? Icon(
                          isAuthorized ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                          color: isAuthorized ? Colors.green : Colors.red,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.personName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnauthorized ? Colors.red : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.primaryPurple),
                          const SizedBox(width: 4),
                          Text(
                            fullTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryPurple,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                StatusBadge(status: log.status, fontSize: 10),
              ],
            ),
          ),
          
          // Action Buttons for Unauthorized
          if (isUnauthorized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => provider.overrideLog(log.id!, 'disabled'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Blacklist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => provider.overrideLog(log.id!, 'authorized'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

          // Footer: Confidence and Location
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Confidence: ', style: TextStyle(fontSize: 10, color: AppTheme.textLight)),
                      Text(
                        '${(log.confidence * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: log.confidence > 0.8 ? Colors.green : (isUnauthorized ? Colors.red : Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      log.entryPoint,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
