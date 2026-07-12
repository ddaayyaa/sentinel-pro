import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = '7D'; // '1D', '7D', '30D'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final stats = dashboard.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('System Analytics', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: dashboard.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 32),
                  _buildMainMetrics(stats),
                  const SizedBox(height: 32),
                  const Text('Traffic Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildTrafficChart(stats),
                  const SizedBox(height: 32),
                  const Text('Entry Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDistributionChart(stats),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ['1D', '7D', '30D'].map((range) {
          bool isSelected = _timeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _timeRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  range == '1D' ? 'Today' : (range == '7D' ? 'Weekly' : 'Monthly'),
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.textLight,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainMetrics(dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _metricCard('Total Entries', '${stats?.todayEntries ?? 0}', Icons.login_rounded, Colors.blue),
        _metricCard('Authorized', '${stats?.totalFaces ?? 0}', Icons.verified_user_rounded, Colors.green),
        _metricCard('Alerts', '${stats?.activeAlerts ?? 0}', Icons.warning_amber_rounded, Colors.red),
        _metricCard('Accuracy', '${stats?.recognitionAccuracy ?? 0}%', Icons.auto_graph_rounded, Colors.purple),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficChart(dynamic stats) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: const Center(child: Text('Intergrated Traffic Graph\n(Coming in v2.2)', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textLight, fontSize: 12))),
    );
  }

  Widget _buildDistributionChart(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          _distributionRow('Main Entrance', 0.65, Colors.blue),
          const SizedBox(height: 16),
          _distributionRow('Side Gate', 0.25, Colors.orange),
          const SizedBox(height: 16),
          _distributionRow('Staff Room', 0.10, Colors.green),
        ],
      ),
    );
  }

  Widget _distributionRow(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percent, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 6),
      ],
    );
  }
}
