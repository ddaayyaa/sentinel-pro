import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _frontCam = true;
  bool _isInitializing = true;
  bool _isProcessing = false;
  RecognitionResult? _liveResult;
  Timer? _analysisTimer;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startController(_cameras[_frontCam ? 1 : 0]);
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  Future<void> _startController(CameraDescription desc) async {
    await _controller?.dispose();
    _controller = CameraController(desc, ResolutionPreset.medium, enableAudio: false);
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
        _startLiveAnalysis();
      }
    } catch (e) {
      debugPrint('Controller Error: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _frontCam = !_frontCam;
    await _startController(_cameras[_frontCam ? 1 : 0]);
  }

  void _startLiveAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_isProcessing || !mounted || _controller == null || !_controller!.value.isInitialized || _liveResult != null) return;

      setState(() => _isProcessing = true);
      try {
        final image = await _controller!.takePicture();
        final recognition = context.read<RecognitionProvider>();
        
        final result = await recognition.recognizeImage(image);
        
        if (mounted) {
          if (result != null) {
             setState(() {
                _liveResult = result;
                _isProcessing = false;
             });
             
             // Auto-dismiss after 5 seconds to continue monitoring
             Future.delayed(const Duration(seconds: 5), () {
                if (mounted && _liveResult == result) {
                   setState(() => _liveResult = null);
                }
             });
          } else {
             setState(() => _isProcessing = false);
          }
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
          // 1. Camera Preview
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: _liveResult != null ? -100 : 0,
            left: 0,
            right: 0,
            bottom: _liveResult != null ? 350 : 0,
            child: !_isInitializing && _controller != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

          // 2. High-Tech Overlays (Hidden when result shown)
          if (_liveResult == null) _buildOverlayUI(),

          // 3. SKETCH-STYLE RESULT CARD
          if (_liveResult != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: IdentityResultCard(
                result: _liveResult!, 
                onReset: () => setState(() => _liveResult = null),
              ),
            ),

          // Back Button
          Positioned(
            top: 60,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Flip Camera Button
          Positioned(
            top: 60,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white, size: 24),
              onPressed: _flipCamera,
            ),
          ),
          
          // Header
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _liveResult == null ? 'AUTO RECOGNITION' : 'IDENTITY VERIFIED', 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: 280,
                height: 320,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.5 + (_animController.value * 0.5)),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
