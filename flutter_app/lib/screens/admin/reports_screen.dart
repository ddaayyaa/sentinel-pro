import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFormat = 'PDF';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _handleDownload() async {
    // 1. Request Permissions for Public Storage
    if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
        }
        
        // Fallback for older Android versions
        if (!status.isGranted) {
            await Permission.storage.request();
        }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.1;
    });

    final api = context.read<ApiService>();
    final notifications = NotificationService();

    try {
      // 2. Fetch data from backend
      final data = await api.exportLogs(_selectedFormat.toLowerCase());
      
      setState(() => _downloadProgress = 0.5);

      if (data != null) {
        // 3. Resolve Public Downloads Directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
             directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        final fileName = 'sentinel_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.${_selectedFormat.toLowerCase()}';
        final filePath = '${directory!.path}/$fileName';
        final file = File(filePath);
        
        await file.writeAsBytes(data);

        setState(() => _downloadProgress = 1.0);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved to Downloads: $fileName'), 
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () => OpenFilex.open(filePath),
              ),
            ),
          );

          // 4. Automatically Open File
          await OpenFilex.open(filePath);

          // 5. Trigger completion notification
          await notifications.showNotification(
            id: 99,
            title: 'Download Complete',
            body: 'Report $fileName is ready in your Downloads folder.',
          );
        }
      } else {
        throw Exception("No data received from server");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Intelligence Reports', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHero(),
            const SizedBox(height: 32),
            const Text('Export Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFormatSelector(),
            const SizedBox(height: 32),
            const Text('Report Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildParamsCard(),
            const SizedBox(height: 48),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
          const SizedBox(height: 20),
          const Text('Custom Security Audit', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Generate high-fidelity reports for legal and operational reviews.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: ['PDF', 'CSV', 'WORD'].map((format) {
        bool isSelected = _selectedFormat == format;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFormat = format),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryPurple : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Icon(
                    format == 'PDF' ? Icons.picture_as_pdf_rounded : (format == 'CSV' ? Icons.table_chart_rounded : Icons.description_rounded),
                    color: isSelected ? Colors.white : AppTheme.textLight,
                  ),
                  const SizedBox(height: 8),
                  Text(format, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParamsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          _paramRow('Include Snapshots', true),
          const Divider(height: 32),
          _paramRow('Time-stamped Logs', true),
          const Divider(height: 32),
          _paramRow('Confidence Scores', true),
        ],
      ),
    );
  }

  Widget _paramRow(String label, bool val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        Switch(value: val, onChanged: (v) {}, activeColor: AppTheme.primaryPurple),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return Column(
      children: [
        if (_isDownloading) ...[
          LinearProgressIndicator(value: _downloadProgress, backgroundColor: AppTheme.primaryPurple.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple)),
          const SizedBox(height: 12),
          Text('Assembling data encryption... ${(_downloadProgress * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          const SizedBox(height: 24),
        ],
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)])),
          child: ElevatedButton(
            onPressed: _isDownloading ? null : _handleDownload,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 60)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_download_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Generate & Download', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
