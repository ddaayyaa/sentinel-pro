import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isProcessing = false;
  RecognitionResult? _scanResult;
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);

    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      debugPrint('Camera Init Error: $e');
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _captureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    
    try {
      final XFile image = await _controller!.takePicture();
      final recognitionProvider = context.read<RecognitionProvider>();
      
      // Mandatory Capture & Store is handled inside recognizeImage
      final result = await recognitionProvider.recognizeImage(image);
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scanResult = result;
        });
        
        if (result != null) {
          final String status = result.status.toUpperCase();
          final bool isAuth = status == 'AUTHORIZED';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAuth 
                ? 'IDENTIFIED: ${result.personName} (Archived to Vault)' 
                : 'ALERT: Unauthorized Detection (Archived to Vault)'),
              backgroundColor: isAuth ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Capture Error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan failed: $e')));
      }
    }
  }

  @override
  void dispose() {
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
            top: _scanResult != null ? -80 : 0,
            left: 0,
            right: 0,
            bottom: _scanResult != null ? 350 : 0,
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : (_controller == null || !_controller!.value.isInitialized)
                    ? const Center(child: Text('Camera not available', style: TextStyle(color: Colors.white)))
                    : Center(
                        child: AspectRatio(
                          aspectRatio: 1 / _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                      ),
          ),

          // 2. High-Tech Overlays (Hidden when result is shown)
          if (_scanResult == null) _buildScannerOverlay(),

          // 3. SKETCH-STYLE RESULT CARD
          if (_scanResult != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: IdentityResultCard(
                result: _scanResult!, 
                onReset: () => setState(() => _scanResult = null),
              ),
            ),

          // 4. Header UI
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                if (_scanResult == null) _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const Text('LIVE RECOGNITION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          IconButton(icon: const Icon(Icons.flash_off_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Container(
            width: 260,
            height: 260,
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
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: GestureDetector(
        onTap: _captureAndScan,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: _isProcessing 
              ? const CircularProgressIndicator(color: AppTheme.primaryPurple)
              : const Icon(Icons.radar_rounded, color: AppTheme.primaryPurple, size: 32),
          ),
        ),
      ),
    );
  }
}
