import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

class EvidenceVaultScreen extends StatefulWidget {
  const EvidenceVaultScreen({super.key});

  @override
  State<EvidenceVaultScreen> createState() => _EvidenceVaultScreenState();
}

class _EvidenceVaultScreenState extends State<EvidenceVaultScreen> {
  String _filter = 'ALL'; // 'ALL', 'AUTHORIZED', 'UNAUTHORIZED'

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
    final filteredLogs = _filter == 'ALL' 
        ? allLogs 
        : allLogs.where((l) => l.status.toUpperCase() == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Evidence Vault', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: provider.isLoading && filteredLogs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredLogs.isEmpty
                    ? const EmptyState(icon: Icons.photo_library_outlined, title: 'Vault Empty', subtitle: 'No evidence frames captured yet')
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) => _buildEvidenceCard(filteredLogs[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: ['ALL', 'AUTHORIZED', 'UNAUTHORIZED'].map((f) {
            bool isSelected = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
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
    );
  }

  Widget _buildEvidenceCard(EntryLog log) {
    final bool isAuth = log.status.toLowerCase() == 'authorized';
    final color = isAuth ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    // 24-HOUR RAILWAY TIME
    final timeStr = DateFormat('HH:mm:ss').format(log.timestamp);
    final dateStr = DateFormat('dd/MM/yyyy').format(log.timestamp);
    final api = context.read<ApiService>();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/log-details', arguments: log),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: log.alertTriggered ? color.withOpacity(0.3) : const Color(0xFFE5E7EB), width: log.alertTriggered ? 2 : 1),
          boxShadow: [
            if (log.alertTriggered) BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF3F4F6),
              ),
              clipBehavior: Clip.antiAlias,
              child: log.imagePath != null
                  ? CachedNetworkImage(
                      imageUrl: api.getImageUrl(log.imagePath),
                      httpHeaders: api.authHeader,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.grey)),
                    )
                  : const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.grey)),
            ),
          ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                      Text(timeStr, style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.personName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      log.status.toUpperCase(),
                      style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
