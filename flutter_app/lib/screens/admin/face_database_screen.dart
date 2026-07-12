import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinel_pro/theme/app_theme.dart';
import 'package:sentinel_pro/providers/providers.dart';
import 'package:sentinel_pro/models/models.dart';
import 'package:sentinel_pro/widgets/widgets.dart';
import 'package:sentinel_pro/services/api_service.dart';
import 'package:sentinel_pro/widgets/face_detail_dialog.dart';

class FaceDatabaseScreen extends StatefulWidget {
  const FaceDatabaseScreen({super.key});

  @override
  State<FaceDatabaseScreen> createState() => _FaceDatabaseScreenState();
}

class _FaceDatabaseScreenState extends State<FaceDatabaseScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _sortBy = 'name'; // 'name', 'id', 'matches'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _refreshData();
  }

  Future<void> _refreshData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceProvider>().loadFaces(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<FaceRecord> _getFilteredFaces(List<FaceRecord> faces) {
    String statusFilter = 'all';
    if (_tabController.index == 1) statusFilter = 'active';
    if (_tabController.index == 2) statusFilter = 'inactive';

    var filtered = faces.where((f) {
      bool matchesStatus = statusFilter == 'all' || f.status == statusFilter;
      bool matchesSearch = _searchController.text.isEmpty ||
          f.personName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          f.personId.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    // Sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.personName.compareTo(b.personName));
        break;
      case 'id':
        filtered.sort((a, b) => a.personId.compareTo(b.personId));
        break;
      case 'matches':
        filtered.sort((a, b) => b.matchCount.compareTo(a.matchCount));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final faceProvider = context.watch<FaceProvider>();
    final api = context.read<ApiService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildStatsSliver(faceProvider),
          _buildFilterHeader(faceProvider),
          _buildMainList(faceProvider, api),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-person'),
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Identity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Biometric Repository',
        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort_rounded, color: AppTheme.textDark),
          onSelected: (value) => setState(() => _sortBy = value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
            const PopupMenuItem(value: 'id', child: Text('Sort by ID')),
            const PopupMenuItem(value: 'matches', child: Text('Sort by Matches')),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDark),
          onPressed: _refreshData,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSliver(FaceProvider provider) {
    final activeCount = provider.faces.where((f) => f.status == 'active').length;
    final inactiveCount = provider.faces.where((f) => f.status == 'inactive').length;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            _statChip('Total', provider.faces.length.toString(), Colors.blue),
            const SizedBox(width: 12),
            _statChip('Active', activeCount.toString(), Colors.green),
            const SizedBox(width: 12),
            _statChip('Inactive', inactiveCount.toString(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(FaceProvider provider) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverHeaderDelegate(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textLight,
                indicatorColor: AppTheme.primaryPurple,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'All Records'),
                  Tab(text: 'Active'),
                  Tab(text: 'Inactive'),
                ],
              ),
            ],
          ),
        ),
        maxHeight: 125,
        minHeight: 125,
      ),
    );
  }

  Widget _buildMainList(FaceProvider faceProvider, ApiService api) {
    if (faceProvider.isLoading && faceProvider.faces.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
      );
    }

    final filtered = _getFilteredFaces(faceProvider.faces);

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.face_retouching_off_rounded,
          title: 'No Identities Found',
          subtitle: _searchController.text.isNotEmpty 
              ? 'Try adjusting your search query' 
              : 'Start by adding a new person to the database',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            try {
              return _buildEnhancedFaceCard(filtered[index], api, faceProvider);
            } catch (e) {
              return _buildErrorCard();
            }
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildEnhancedFaceCard(FaceRecord face, ApiService api, FaceProvider provider) {
    final bool isActive = face.status == 'active';
    
    return GestureDetector(
      onTap: () => _showFaceDetail(face),
      onLongPress: () => _showFaceActions(face, provider),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFF3F4F6),
                      image: face.imagePaths.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(api.getImageUrl(face.imagePaths[0])),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: face.imagePaths.isEmpty 
                        ? const Center(child: Icon(Icons.person, color: Colors.grey, size: 40)) 
                        : null,
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange, 
                        shape: BoxShape.circle, 
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                children: [
                  Text(
                    face.personName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${face.personId}', 
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 10, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.analytics_rounded, size: 12, color: AppTheme.primaryPurple),
                        const SizedBox(width: 4),
                        Text(
                          '${face.matchCount} Matches', 
                          style: const TextStyle(color: AppTheme.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  void _showFaceDetail(FaceRecord face) {
    showDialog(
      context: context,
      builder: (context) => FaceDetailDialog(face: face),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
    );
  }

  void _showFaceActions(FaceRecord face, FaceProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Text(face.personName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _actionTile(
              icon: face.status == 'active' ? Icons.block_rounded : Icons.check_circle_outline,
              color: face.status == 'active' ? Colors.orange : Colors.green,
              title: face.status == 'active' ? 'Deactivate Record' : 'Activate Record',
              onTap: () async {
                Navigator.pop(context);
                await provider.toggleStatus(face.id!, face.status == 'active' ? 'inactive' : 'active');
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
              },
            ),
            _actionTile(
              icon: Icons.edit_rounded,
              color: Colors.blue,
              title: 'Edit Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-person', arguments: face);
              },
            ),
            _actionTile(
              icon: Icons.delete_forever_rounded,
              color: Colors.red,
              title: 'Delete Permanently',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text('This will permanently remove all biometric data for this person.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
                        child: const Text('Delete', style: TextStyle(color: Colors.white))
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteFace(face.id!);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record removed')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({required IconData icon, required Color color, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : AppTheme.textDark, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _SliverHeaderDelegate({required this.child, required this.maxHeight, required this.minHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => true;
}
