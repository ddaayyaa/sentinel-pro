import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Removed the simulated Timer. 
    // This screen now relies on the navigation logic in live_camera_screen.dart 
    // to call Navigator.pushReplacementNamed when the actual recognition result is ready.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scanning',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Scanning Frame
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Glow Effect
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            width: 160 + (20 * _controller.value),
                            height: 160 + (20 * _controller.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF7B61FF).withOpacity(0.4),
                                  const Color(0xFF7B61FF).withOpacity(0.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner Glow
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF9E8AFF).withOpacity(0.6),
                              const Color(0xFF9E8AFF).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Scanning Text
              const Text(
                'Scanning Face...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please hold still',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 32),
              // 3-Dot Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(const Color(0xFF7B61FF)),
                  const SizedBox(width: 8),
                  _dot(const Color(0xFF9E8AFF)),
                  const SizedBox(width: 8),
                  _dot(const Color(0xFF4A90E2)),
                ],
              ),
              const Spacer(),
              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
