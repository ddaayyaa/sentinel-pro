import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentinel_pro/models/models.dart';
import 'package:sentinel_pro/services/api_service.dart';
import 'package:sentinel_pro/theme/app_theme.dart';
import 'package:sentinel_pro/widgets/widgets.dart';

class FaceDetailDialog extends StatelessWidget {
  final FaceRecord face;

  const FaceDetailDialog({super.key, required this.face});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: face.imagePaths.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(api.getImageUrl(face.imagePaths[0])),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: face.imagePaths.isEmpty
                      ? const Center(child: Icon(Icons.person, size: 80, color: Colors.grey))
                      : null,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: StatusBadge(status: face.status),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    face.personName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Security ID: ${face.personId}',
                    style: const TextStyle(color: AppTheme.textLight, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 24),
                  
                  _infoRow(Icons.business_rounded, 'Department', face.department ?? 'Unassigned'),
                  const SizedBox(height: 12),
                  _infoRow(Icons.security_rounded, 'Access Level', face.accessLevel.toUpperCase()),
                  const SizedBox(height: 12),
                  _infoRow(Icons.how_to_reg_rounded, 'Registered', 
                      dateFormat.format(face.registeredAt)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.visibility_rounded, 'Last Seen', 
                      face.lastSeen != null ? dateFormat.format(face.lastSeen!) : 'Never'),
                  
                  const Divider(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('Encodings', face.encodingCount.toString()),
                      _statItem('Matches', face.matchCount.toString()),
                      _statItem('Images', face.imagePaths.length.toString()),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/edit-person', arguments: face);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Edit Identity'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryPurple),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
      ],
    );
  }
}
