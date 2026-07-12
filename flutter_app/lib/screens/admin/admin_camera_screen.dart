import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class AdminCameraScreen extends StatefulWidget {
  const AdminCameraScreen({super.key});

  @override
  State<AdminCameraScreen> createState() => _AdminCameraScreenState();
}

class _AdminCameraScreenState extends State<AdminCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isInitializing = true;
  bool _isAnalyzing = false;
  
  RecognitionResult? _currentResult;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _onNewCameraSelected(_cameras![_selectedCameraIndex]);
      } else {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('Camera Error: $e');
      setState(() => _isInitializing = false);
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('Camera Initialize Error: $e');
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    setState(() => _isInitializing = true);
    _onNewCameraSelected(_cameras![_selectedCameraIndex]);
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint('Flash Error: $e');
    }
  }

  Future<void> _analyzeCurrentFrame() async {
    if (_controller == null || !_controller!.value.isInitialized || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _currentResult = null;
    });

    try {
      final recognition = context.read<RecognitionProvider>();
      final XFile image = await _controller!.takePicture();
      
      final result = await recognition.recognizeImage(File(image.path));
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _currentResult = result;
        });
      }
    } catch (e) {
      debugPrint('Analysis Error: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detection failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Moves up when result is shown)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: _currentResult != null ? -100 : 0,
            left: 0,
            right: 0,
            bottom: _currentResult != null ? 350 : 0,
            child: Center(
              child: _isInitializing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : (_controller != null && _controller!.value.isInitialized)
                      ? AspectRatio(
                          aspectRatio: 1 / _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        )
                      : const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white24),
            ),
          ),
          
          // 2. High-Tech Overlays (Hidden when result is shown)
          if (_currentResult == null) _buildScannerUI(),

          // 3. SKETCH-STYLE RESULT CARD
          if (_currentResult != null) 
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: IdentityResultCard(
                result: _currentResult!, 
                onReset: () => setState(() => _currentResult = null),
              ),
            ),

          // 4. Side Controls (Flash, Switch) - Hidden when result is shown
          if (_currentResult == null)
            Positioned(
              right: 24,
              top: 60,
              child: Column(
                children: [
                  _buildCircleIcon(
                    _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onTap: _toggleFlash,
                    isActive: _isFlashOn,
                  ),
                  const SizedBox(height: 20),
                  _buildCircleIcon(
                    Icons.switch_camera_rounded,
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),
          
          // 5. Back Button
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
          ),
          
          // 6. Action Button (Analyze) - Only shown when no result
          if (_currentResult == null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _analyzeCurrentFrame,
                  child: Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9E8AFF)]),
                      ),
                      child: _isAnalyzing 
                        ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Icon(Icons.radar_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
            ),

          // 7. Title Header (Matches Sketch)
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _currentResult == null ? 'LIVE RECOGNITION' : 'RECOGNITION COMPLETE', 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerUI() {
    return Stack(
      children: [
        // Corner Brackets
        Center(
          child: Container(
            width: 260,
            height: 260,
            child: Stack(
              children: [
                _bracket(Alignment.topLeft),
                _bracket(Alignment.topRight),
                _bracket(Alignment.bottomLeft),
                _bracket(Alignment.bottomRight),
                
                // Animated Scan Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 260 * _scanAnimation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                          ],
                          gradient: const LinearGradient(colors: [Colors.transparent, AppTheme.primaryPurple, Colors.transparent]),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bracket(Alignment alignment) {
    bool isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    bool isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryPurple : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppTheme.textDark,
          size: 24,
        ),
      ),
    );
  }
}
