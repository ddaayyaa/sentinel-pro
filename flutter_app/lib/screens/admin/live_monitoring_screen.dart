import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen>
    with TickerProviderStateMixin {
  // Camera
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  bool _camReady  = false;
  bool _frontCam  = false;
  bool _flashOn   = false;

  // Recognition
  bool _monitoring  = false;
  bool _processing  = false;
  Timer? _captureTimer;
  List<FaceRecognitionResult> _results = [];
  FaceRecognitionResult? _lastResult;

  // Session stats
  int _sessTotal = 0, _sessAuth = 0, _sessUnauth = 0;

  // Gate
  String _gate = 'Main Gate';
  final _gates = ['Main Gate', 'Gate A', 'Gate B', 'VIP Gate', 'Backstage'];

  // Capture interval (ms)
  int _intervalMs = 2500;

  // Scan animation
  late AnimationController _scanCtrl;
  late Animation<double>   _scanAnim;

  // Pulse animation for unauthorized
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  // Clock
  Timer? _clockTimer;
  String _clockStr = '';

  @override
  void initState() {
    super.initState();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanCtrl);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = Tween<double>(begin: 1, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _startClock();
    _initCamera();
  }

  void _startClock() {
    _clockStr = _fmtTime(DateTime.now());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _clockStr = _fmtTime(DateTime.now()));
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2,'0')}:'
      '${dt.minute.toString().padLeft(2,'0')}:'
      '${dt.second.toString().padLeft(2,'0')}';

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startController(_cameras[_frontCam ? 1 : 0]);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startController(CameraDescription desc) async {
    await _camCtrl?.dispose();
    _camCtrl = CameraController(
      desc,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await _camCtrl!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (e) {
      debugPrint('Controller init error: $e');
    }
  }

  // ── Monitoring Control ──────────────────────────────────────
  void _startMonitoring() {
    setState(() {
      _monitoring  = true;
      _sessTotal   = 0;
      _sessAuth    = 0;
      _sessUnauth  = 0;
      _results     = [];
      _lastResult  = null;
    });
    _captureTimer = Timer.periodic(
      Duration(milliseconds: _intervalMs),
      (_) => _captureAndRecognize(),
    );
  }

  void _stopMonitoring() {
    _captureTimer?.cancel();
    setState(() {
      _monitoring = false;
      _results    = [];
    });
  }

  Future<void> _captureAndRecognize() async {
    if (!_camReady || _camCtrl == null || _processing) return;
    _processing = true;

    try {
      final img   = await _camCtrl!.takePicture();
      final bytes = await img.readAsBytes();
      final b64   = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final api = context.read<ApiService>();
      final results = await api.recognizeFrameAdv(b64, _gate);

      // Trigger Evidence Vault refresh
      if (mounted) {
          context.read<EntryLogProvider>().loadLogs(refresh: true);
      }

      if (!mounted) return;
      setState(() {
        _results = results;
        for (final r in results) {
          _sessTotal++;
          if (r.authorized) {
            _sessAuth++;
          } else {
            _sessUnauth++;
            _pulseCtrl.forward(from: 0); // pulse alert
          }
        }
        if (results.isNotEmpty) _lastResult = results.first;
      });

      // Delete temp file
      try { await File(img.path).delete(); } catch (_) {}
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      _processing = false;
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _frontCam = !_frontCam;
    await _startController(_cameras[_frontCam ? 1 : 0]);
  }

  Future<void> _toggleFlash() async {
    _flashOn = !_flashOn;
    await _camCtrl?.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _clockTimer?.cancel();
    _camCtrl?.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030810),
      appBar: _buildAppBar(),
      body: Column(children: [
        Expanded(child: _buildCameraSection()),
        _buildControls(),
        _buildStats(),
        _buildResultPanel(),
        const SizedBox(height: 8),
      ]),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: const Color(0xFF0A1628),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF00D4FF)),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text('LIVE MONITOR',
      style: GoogleFonts.orbitron(
        color: Colors.white, fontSize: 14,
        fontWeight: FontWeight.w700, letterSpacing: 2,
      )),
    actions: [
      _StatusBadge(active: _monitoring),
      const SizedBox(width: 12),
    ],
  );

  // ── Camera Preview ──────────────────────────────────────────
  Widget _buildCameraSection() {
    return Stack(children: [
      // Camera or placeholder
      Container(
        color: Colors.black,
        child: _camReady
          ? ClipRect(child: OverflowBox(
              alignment: Alignment.center,
              child: CameraPreview(_camCtrl!),
            ))
          : const Center(child: Icon(
              Icons.videocam_off_outlined,
              color: Color(0xFF4A6A85), size: 56,
            )),
      ),

      // Scan line
      if (_monitoring)
        AnimatedBuilder(
          animation: _scanAnim,
          builder: (_, __) => CustomPaint(
            painter: ScanLinePainter(_scanAnim.value),
            size: Size.infinite,
          ),
        ),

      // Face bounding boxes
      if (_results.isNotEmpty && _camReady)
        LayoutBuilder(builder: (ctx, constraints) {
          final previewSize = Size(
            _camCtrl!.value.previewSize?.height ?? constraints.maxWidth,
            _camCtrl!.value.previewSize?.width  ?? constraints.maxHeight,
          );
          return CustomPaint(
            painter: FaceBoxPainter(
              results:     _results,
              previewSize: previewSize,
              widgetSize:  Size(constraints.maxWidth, constraints.maxHeight),
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          );
        }),

      // HUD top-left
      if (_monitoring)
        Positioned(top: 12, left: 12, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HudTag('● REC', color: const Color(0xFFFF3366)),
            _HudTag(_gate),
            _HudTag('720P • AI'),
          ],
        )),

      // HUD top-right: clock
      Positioned(
        top: 12, right: 12,
        child: _HudTag(_clockStr, color: const Color(0xFF00D4FF)),
      ),

      // Processing indicator
      if (_processing)
        Positioned(
          bottom: 14, left: 14,
          child: Row(children: [
            const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(Color(0xFF00D4FF)),
              ),
            ),
            const SizedBox(width: 6),
            Text('ANALYZING...', style: GoogleFonts.orbitron(
              color: const Color(0xFF00D4FF), fontSize: 9, letterSpacing: 1)),
          ]),
        ),

      // No camera message
      if (!_camReady)
        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined,
              color: Color(0xFF4A6A85), size: 48),
            const SizedBox(height: 10),
            Text('Camera unavailable', style: GoogleFonts.exo2(
              color: const Color(0xFF4A6A85), fontSize: 13)),
          ],
        )),
    ]);
  }

  // ── Controls Row ────────────────────────────────────────────
  Widget _buildControls() => Container(
    color: const Color(0xFF0A1628),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      // Start / Stop
      Expanded(child: GestureDetector(
        onTap: _monitoring ? _stopMonitoring : _startMonitoring,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _monitoring
                ? [const Color(0xFFFF3366), const Color(0xFFCC0033)]
                : [const Color(0xFF00FF88), const Color(0xFF22C55E)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_monitoring ? Icons.stop : Icons.play_arrow,
              color: _monitoring ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(_monitoring ? 'STOP' : 'START',
              style: GoogleFonts.orbitron(
                color: _monitoring ? Colors.white : Colors.black,
                fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      )),

      const SizedBox(width: 10),

      // Flip camera
      _CtrlBtn(
        icon: Icons.flip_camera_android_outlined,
        onTap: _flipCamera,
      ),
      const SizedBox(width: 8),

      // Flash
      _CtrlBtn(
        icon: _flashOn ? Icons.flash_on : Icons.flash_off_outlined,
        color: _flashOn ? const Color(0xFFFFB800) : null,
        onTap: _toggleFlash,
      ),
      const SizedBox(width: 10),

      // Gate selector
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x1F00D4FF)),
        ),
        child: DropdownButton<String>(
          value: _gate,
          underline: const SizedBox(),
          dropdownColor: const Color(0xFF0F1E35),
          style: GoogleFonts.exo2(color: Colors.white, fontSize: 12),
          iconEnabledColor: const Color(0xFF00D4FF),
          items: _gates.map((g) => DropdownMenuItem(
            value: g,
            child: Text(g),
          )).toList(),
          onChanged: (v) => setState(() => _gate = v!),
        ),
      ),
    ]),
  );

  // ── Session Stats ───────────────────────────────────────────
  Widget _buildStats() => Container(
    color: const Color(0xFF0A1628),
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
    child: Row(children: [
      _StatBox('TOTAL',   '$_sessTotal', const Color(0xFF00D4FF)),
      const SizedBox(width: 10),
      _StatBox('AUTHORIZED', '$_sessAuth', const Color(0xFF00FF88)),
      const SizedBox(width: 10),
      _StatBox('UNAUTHORIZED', '$_sessUnauth', const Color(0xFFFF3366)),
      const SizedBox(width: 10),
      // Interval picker
      Expanded(child: GestureDetector(
        onTap: _pickInterval,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x1F00D4FF)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('INTERVAL', style: GoogleFonts.orbitron(
                color: const Color(0xFF4A6A85), fontSize: 7, letterSpacing: 1)),
              Text('${(_intervalMs / 1000).toStringAsFixed(1)}s',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF00D4FF), fontSize: 13,
                  fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      )),
    ]),
  );

  void _pickInterval() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('CAPTURE INTERVAL', style: GoogleFonts.orbitron(
            color: Colors.white, fontSize: 13, letterSpacing: 2)),
          const SizedBox(height: 16),
          Wrap(spacing: 10, children: [1000, 1500, 2500, 3500, 5000].map((ms) =>
            GestureDetector(
              onTap: () {
                setState(() => _intervalMs = ms);
                if (_monitoring) {
                  _captureTimer?.cancel();
                  _captureTimer = Timer.periodic(
                    Duration(milliseconds: ms),
                    (_) => _captureAndRecognize(),
                  );
                }
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _intervalMs == ms
                    ? const Color(0xFF00D4FF).withOpacity(0.2)
                    : const Color(0xFF0F1E35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _intervalMs == ms
                      ? const Color(0xFF00D4FF)
                      : const Color(0x1F00D4FF)),
                ),
                child: Text('${(ms / 1000).toStringAsFixed(1)}s',
                  style: GoogleFonts.exo2(
                    color: _intervalMs == ms
                      ? const Color(0xFF00D4FF)
                      : Colors.white,
                    fontWeight: FontWeight.w600)),
              ),
            ),
          ).toList()),
        ]),
      ),
    );
  }

  // ── Result Panel ────────────────────────────────────────────
  Widget _buildResultPanel() {
    if (_lastResult == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1F00D4FF)),
        ),
        child: Center(child: Text(
          _monitoring ? 'Scanning for faces...' : 'Press START to begin',
          style: GoogleFonts.exo2(
            color: const Color(0xFF4A6A85), fontSize: 13),
        )),
      );
    }

    final r     = _lastResult!;
    final isAuth = r.authorized;
    final color  = isAuth
      ? const Color(0xFF00FF88)
      : const Color(0xFFFF3366);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: isAuth ? 1.0 : _pulseAnim.value,
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(children: [
          // Top row
          Row(children: [
            // Avatar
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(
                isAuth ? Icons.verified_user : Icons.person_off,
                color: color, size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Name + gate
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.personName, style: GoogleFonts.exo2(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700)),
                Text('${r.gate}  •  '
                  '${isAuth ? "Confidence: ${r.confidence.toStringAsFixed(1)}%" : "No match found"}',
                  style: GoogleFonts.exo2(
                    color: const Color(0xFF4A6A85), fontSize: 12)),
              ],
            )),
            // Decision badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(isAuth ? 'ALLOW' : 'DENY',
                style: GoogleFonts.orbitron(
                  color: isAuth ? Colors.black : Colors.white,
                  fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),

          // Override actions for unauthorized
          if (!isAuth) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _ActionBtn(
                label: 'OVERRIDE ALLOW',
                color: const Color(0xFF00FF88),
                onTap: () => _showOverrideDialog(true),
              )),
              const SizedBox(width: 8),
              Expanded(child: _ActionBtn(
                label: 'ALERT SECURITY',
                color: const Color(0xFFFF3366),
                onTap: () => _showAlertDialog(),
              )),
            ]),
          ],
        ]),
      ),
    );
  }

  void _showOverrideDialog(bool allow) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        title: Text('OVERRIDE DECISION', style: GoogleFonts.orbitron(
          color: Colors.white, fontSize: 13)),
        content: Text(
          'Mark ${_lastResult?.personName} as AUTHORIZED and grant access?',
          style: GoogleFonts.exo2(color: const Color(0xFF4A6A85))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.exo2(
              color: const Color(0xFF4A6A85)))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Access granted by admin override'),
                  backgroundColor: Color(0xFF00FF88)));
            },
            child: Text('ALLOW', style: GoogleFonts.exo2(
              color: const Color(0xFF00FF88), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  void _showAlertDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Security alert dispatched!'),
        backgroundColor: Color(0xFFFF3366)));
  }
}

// ── Small Widgets ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final c = active ? const Color(0xFF00FF88) : const Color(0xFF4A6A85);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7,
          decoration: BoxDecoration(
            color: c, shape: BoxShape.circle,
            boxShadow: active ? [BoxShadow(color: c, blurRadius: 5)] : null,
          )),
        const SizedBox(width: 6),
        Text(active ? 'ACTIVE' : 'STANDBY',
          style: GoogleFonts.orbitron(
            color: c, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ]),
    );
  }
}

class _HudTag extends StatelessWidget {
  final String text;
  final Color color;
  const _HudTag(this.text, {this.color = const Color(0xFF00D4FF)});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 3),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.65),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(text, style: GoogleFonts.orbitron(
      color: color, fontSize: 9, letterSpacing: 1)),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: GoogleFonts.orbitron(
            color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label, style: GoogleFonts.exo2(
            color: const Color(0xFF4A6A85), fontSize: 8, letterSpacing: 0.5)),
        ],
      ),
    ),
  );
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  const _CtrlBtn({required this.icon, this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1F00D4FF)),
      ),
      child: Icon(icon, color: color ?? const Color(0xFF4A6A85), size: 22),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(child: Text(label, style: GoogleFonts.orbitron(
        color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
    ),
  );
}
