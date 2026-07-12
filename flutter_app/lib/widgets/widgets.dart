import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Face Painter ──────────────────────────────────────────────
class FaceBoxPainter extends CustomPainter {
  final List<FaceRecognitionResult> results;
  final Size previewSize;
  final Size widgetSize;

  FaceBoxPainter({
    required this.results,
    required this.previewSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final result in results) {
      if (result.bbox.isEmpty) continue;

      final color = result.authorized
          ? const Color(0xFF00FF88)
          : const Color(0xFFFF3366);

      final scaleX = widgetSize.width  / previewSize.width;
      final scaleY = widgetSize.height / previewSize.height;

      final top    = ((result.bbox['top']    ?? 0) as num).toDouble() * scaleY;
      final left   = ((result.bbox['left']   ?? 0) as num).toDouble() * scaleX;
      final bottom = ((result.bbox['bottom'] ?? 0) as num).toDouble() * scaleY;
      final right  = ((result.bbox['right']  ?? 0) as num).toDouble() * scaleX;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      // Box
      final boxPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, boxPaint);

      // Corner brackets
      _drawCorners(canvas, rect, color);

      // Label background
      final labelText =
          '${result.personName}  ${result.authorized ? "${result.confidence.toStringAsFixed(1)}%" : "UNKNOWN"}';
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Calibri',
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        left, top - 24, tp.width + 14, 22,
      );
      canvas.drawRect(
        labelRect,
        Paint()..color = color.withOpacity(0.88),
      );
      tp.paint(canvas, Offset(left + 7, top - 22));
    }
  }

  void _drawCorners(Canvas canvas, Rect rect, Color color) {
    const len = 14.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), p);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), p);
    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-len, 0), p);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, len), p);
    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(len, 0), p);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -len), p);
    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-len, 0), p);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -len), p);
  }

  @override
  bool shouldRepaint(FaceBoxPainter oldDelegate) => oldDelegate.results != results;
}

// ── Scan Line Painter ─────────────────────────────────────────
class ScanLinePainter extends CustomPainter {
  final double progress;
  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00D4FF).withOpacity(0.7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 3))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) => oldDelegate.progress != progress;
}

class ScanLineOverlay extends StatelessWidget {
  final Widget child;
  final bool active;
  const ScanLineOverlay({super.key, required this.child, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (active)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  const GlowCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class FaceAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? borderColor;
  const FaceAvatar({super.key, required this.name, this.size = 40, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 1.5),
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 24),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final bool isGranted = status.toLowerCase() == 'authorized' || status.toLowerCase() == 'granted' || status.toLowerCase() == 'active' || status.toLowerCase() == 'admin';
    final color = isGranted ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  const ShimmerCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class ConfidenceBar extends StatelessWidget {
  final double value;
  const ConfidenceBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('System Confidence', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
        ),
      ],
    );
  }
}

class IdentityResultCard extends StatelessWidget {
  final RecognitionResult result;
  final VoidCallback onReset;

  const IdentityResultCard({super.key, required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final bool isAuth = result.status.toLowerCase() == 'authorized';
    final color = isAuth ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final timeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Status Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isAuth ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  isAuth ? 'AUTHORIZED' : 'UNAUTHORIZED',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Details Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _detailRow(Icons.person_outline_rounded, 'Name', result.personName),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _detailRow(Icons.badge_outlined, 'ID', result.personId.isEmpty ? 'Unknown' : result.personId),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _detailRow(Icons.access_time_rounded, 'Time', timeStr),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _detailRow(Icons.calendar_today_rounded, 'Date', dateStr),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Reset/Capture Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)]),
            ),
            child: ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('SCAN NEW TARGET', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_done_rounded, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('IMAGE ARCHIVED TO EVIDENCE VAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981), letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 16),
        Text('$label :', style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
