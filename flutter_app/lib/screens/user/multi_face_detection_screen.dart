import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class MultiFaceDetectionScreen extends StatefulWidget {
  const MultiFaceDetectionScreen({super.key});

  @override
  State<MultiFaceDetectionScreen> createState() => _MultiFaceDetectionScreenState();
}

class _MultiFaceDetectionScreenState extends State<MultiFaceDetectionScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _detectedFaces = [];
  Timer? _analysisTimer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera (index 1) or back (index 0)
    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
        _startMultiAnalysis();
      }
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  void _startMultiAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isProcessing || !mounted || _controller == null || !_controller!.value.isInitialized) return;

      setState(() => _isProcessing = true);
      try {
        final image = await _controller!.takePicture();
        final recognition = context.read<RecognitionProvider>();
        final results = await recognition.recognizeMulti(image);

        if (mounted) {
          setState(() {
            _detectedFaces = results;
            _isProcessing = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isProcessing = false);
      }
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Feed
          if (!_isInitializing && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. High-Tech Multi-Face Overlay
          _buildMultiFaceOverlay(),

          // 3. Digital Header
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
                Column(
                  children: [
                    const Text('MULTI-TARGET TRACKING', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Text('TARGETS DETECTED: ${_detectedFaces.length}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace')),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _isProcessing ? Colors.orange : Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text(_isProcessing ? 'ANALYZING' : 'LIVE', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 4. Scanning Progress HUD
          if (_isProcessing)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent)),
                      SizedBox(width: 12),
                      Text('UPDATING TARGET DATABASE...', style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMultiFaceOverlay() {
    return Stack(
      children: _detectedFaces.map((face) {
        final bool authorized = face['status'] == 'authorized';
        final color = authorized ? const Color(0xFF10B981) : const Color(0xFFEF4444);
        
        // Note: In a real implementation with bounding boxes, we would map the 
        // face['location'] [top, right, bottom, left] to screen coordinates.
        // For this "Advanced UI" demonstration, we'll scatter them or show them in a dynamic grid
        // to represent the multi-tracking logic.
        
        return Center(
          child: Container(
            margin: EdgeInsets.only(
              top: (face['location'][0] % 200).toDouble(), 
              left: (face['location'][3] % 100).toDouble()
            ),
            child: _buildDetectionFrame(face['person_name'], color),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetectionFrame(String name, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          child: Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.6 + (_animController.value * 0.4)), width: 2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
