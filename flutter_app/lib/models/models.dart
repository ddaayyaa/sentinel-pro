import 'dart:convert';

// --- User Model ---
class User {
  final int? id;
  final String username;
  final String email;
  final String role;
  final String status;
  final String? fullName;
  final String? phone;
  final String? department;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isOnline;

  User({
    this.id,
    required this.username,
    required this.email,
    this.role = 'user',
    this.status = 'pending',
    this.fullName,
    this.phone,
    this.department,
    this.avatarUrl,
    this.createdAt,
    this.lastLogin,
    this.isOnline = false,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) => User(
        id: json['id'],
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        status: json['status'] ?? 'pending',
        fullName: json['full_name'],
        phone: json['phone'],
        department: json['department'],
        avatarUrl: json['avatar_url'],
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        lastLogin: DateTime.tryParse(json['last_login']?.toString() ?? ''),
        isOnline: json['is_online'] == 1 || json['is_online'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
        'status': status,
        'full_name': fullName,
        'phone': phone,
        'department': department,
        'avatar_url': avatarUrl,
        'created_at': createdAt?.toIso8601String(),
        'last_login': lastLogin?.toIso8601String(),
        'is_online': isOnline ? 1 : 0,
      };
}

// --- Face Record Model ---
class FaceRecord {
  final int? id;
  final String personName;
  final String personId;
  final String? department;
  final String accessLevel;
  final String status;
  final int encodingCount;
  final int matchCount;
  final DateTime registeredAt;
  final DateTime? lastSeen;
  final List<String> imagePaths;

  FaceRecord({
    this.id,
    required this.personName,
    required this.personId,
    this.department,
    this.accessLevel = 'standard',
    this.status = 'active',
    this.encodingCount = 0,
    this.matchCount = 0,
    required this.registeredAt,
    this.lastSeen,
    this.imagePaths = const [],
  });

  factory FaceRecord.fromJson(Map<dynamic, dynamic> json) => FaceRecord(
        id: json['id'],
        personName: json['person_name'] ?? 'Unknown',
        personId: json['person_id'] ?? '',
        department: json['department'],
        accessLevel: json['access_level'] ?? 'standard',
        status: json['status'] ?? 'active',
        encodingCount: json['encoding_count'] ?? 0,
        matchCount: json['match_count'] ?? 0,
        registeredAt: DateTime.tryParse(json['registered_at']?.toString() ?? '') ?? DateTime.now(),
        lastSeen: DateTime.tryParse(json['last_seen']?.toString() ?? ''),
        imagePaths: json['image_paths'] is List ? (json['image_paths'] as List).cast<String>() : [],
      );
}

// --- Face Recognition Result (Advanced UI) ---
class FaceRecognitionResult {
  final String personId;
  final String personName;
  final bool authorized;
  final double confidence;
  final String gate;
  final DateTime detectedAt;
  final Map<String, dynamic> bbox;

  FaceRecognitionResult({
    required this.personId,
    required this.personName,
    required this.authorized,
    required this.confidence,
    required this.gate,
    required this.detectedAt,
    required this.bbox,
  });

  factory FaceRecognitionResult.fromJson(Map<dynamic, dynamic> j) {
    return FaceRecognitionResult(
      personId:   j['person_id']?.toString() ?? 'unknown',
      personName: j['person_name'] ?? 'Unknown',
      authorized: j['authorized'] == true || j['status'] == 'authorized',
      confidence: (j['confidence'] ?? 0.0).toDouble(),
      gate:       j['gate'] ?? 'Main Entrance',
      detectedAt: DateTime.now(),
      bbox: Map<String, dynamic>.from(j['bbox'] ?? j['box'] ?? {}),
    );
  }
}

// --- Entry Log Model ---
class EntryLog {
  final int? id;
  final String personName;
  final String personId;
  final String status; 
  final double confidence;
  final String? imagePath;
  final String cameraId;
  final String entryPoint;
  final DateTime timestamp;
  final String? adminNote;
  final bool alertTriggered;
  final String? overriddenBy;

  EntryLog({
    this.id,
    required this.personName,
    required this.personId,
    required this.status,
    required this.confidence,
    this.imagePath,
    required this.cameraId,
    required this.entryPoint,
    required this.timestamp,
    this.adminNote,
    this.alertTriggered = false,
    this.overriddenBy,
  });

  factory EntryLog.fromJson(Map<dynamic, dynamic> json) => EntryLog(
        id: json['id'],
        personName: json['person_name'] ?? 'Unknown',
        personId: json['person_id'] ?? '',
        status: json['status'] ?? 'unknown',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        imagePath: json['image_path'],
        cameraId: json['camera_id'] ?? 'CAM-01',
        entryPoint: json['entry_point'] ?? 'Main Entrance',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        adminNote: json['admin_note'],
        alertTriggered: json['alert_triggered'] == 1 || json['alert_triggered'] == true,
        overriddenBy: json['overridden_by']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person_name': personName,
        'person_id': personId,
        'status': status,
        'confidence': confidence,
        'image_path': imagePath,
        'camera_id': cameraId,
        'entry_point': entryPoint,
        'timestamp': timestamp.toIso8601String(),
        'admin_note': adminNote,
        'alert_triggered': alertTriggered ? 1 : 0,
        'overridden_by': overriddenBy,
      };
}

// --- Security Alert Model ---
class SecurityAlert {
  final int id;
  final String type;
  final String severity;
  final String message;
  final String? personName;
  final String? imagePath;
  final String? cameraId;
  final DateTime timestamp;
  final bool resolved;
  final String? resolvedBy;
  final String? note;

  SecurityAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.personName,
    this.imagePath,
    this.cameraId,
    required this.timestamp,
    required this.resolved,
    this.resolvedBy,
    this.note,
  });

  factory SecurityAlert.fromJson(Map<dynamic, dynamic> json) => SecurityAlert(
        id: json['id'] ?? 0,
        type: json['type'] ?? 'info',
        severity: json['severity'] ?? 'medium',
        message: json['message'] ?? '',
        personName: json['person_name'],
        imagePath: json['image_path'],
        cameraId: json['camera_id'],
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        resolved: json['resolved'] == 1 || json['resolved'] == true,
        resolvedBy: json['resolved_by']?.toString(),
        note: json['note'],
      );
}

// --- Training Job Model ---
class TrainingJob {
  final String jobId;
  final String status;
  final double progress;
  final int totalImages;
  final int processedImages;
  final String? currentFile;
  final Map<String, dynamic> metrics;

  TrainingJob({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.totalImages,
    required this.processedImages,
    this.currentFile,
    this.metrics = const {},
  });

  factory TrainingJob.fromJson(Map<dynamic, dynamic> json) => TrainingJob(
        jobId: json['job_id'] ?? '',
        status: json['status'] ?? 'pending',
        progress: (json['progress'] ?? 0.0).toDouble(),
        totalImages: json['total_images'] ?? 0,
        processedImages: json['processed_images'] ?? 0,
        currentFile: json['current_file'],
        metrics: json['metrics'] is String ? jsonDecode(json['metrics']) : (json['metrics'] ?? {}),
      );
}

// --- Camera Device Model ---
class CameraDevice {
  final String id;
  final String name;
  final String location;
  final String status;
  final String streamUrl;
  final int detectionCount;
  final DateTime? lastActivity;

  CameraDevice({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.streamUrl,
    this.detectionCount = 0,
    this.lastActivity,
  });

  factory CameraDevice.fromJson(Map<dynamic, dynamic> json) => CameraDevice(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        status: json['status'] ?? 'offline',
        streamUrl: json['stream_url'] ?? '',
        detectionCount: json['detection_count'] ?? 0,
        lastActivity: DateTime.tryParse(json['last_activity']?.toString() ?? ''),
      );
}

// --- App Notification Model ---
class AppNotification {
  final int? id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  AppNotification({
    this.id,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isRead = false,
    required this.timestamp,
    this.data = const {},
  });

  factory AppNotification.fromJson(Map<dynamic, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'] ?? 'info',
        isRead: json['is_read'] == 1 || json['is_read'] == true,
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        data: json['data'] is String ? jsonDecode(json['data']) : (json['data'] ?? {}),
      );
}

// --- Dashboard Stats Model ---
class DashboardStats {
  final int totalFaces;
  final int todayEntries;
  final int unauthorizedToday;
  final int activeAlerts;
  final int pendingApprovals;
  final int onlineCameras;
  final double recognitionAccuracy;
  final List<Map<String, dynamic>> hourlyData;
  final List<Map<String, dynamic>> weeklyData;
  final List<EntryLog> recentEntries;

  DashboardStats({
    required this.totalFaces,
    required this.todayEntries,
    required this.unauthorizedToday,
    required this.activeAlerts,
    required this.pendingApprovals,
    required this.onlineCameras,
    required this.recognitionAccuracy,
    required this.hourlyData,
    required this.weeklyData,
    required this.recentEntries,
  });

  factory DashboardStats.fromJson(Map<dynamic, dynamic> json) => DashboardStats(
        totalFaces: json['total_faces'] ?? 0,
        todayEntries: json['today_entries'] ?? 0,
        unauthorizedToday: json['unauthorized_today'] ?? 0,
        activeAlerts: json['active_alerts'] ?? 0,
        pendingApprovals: json['pending_approvals'] ?? 0,
        onlineCameras: json['online_cameras'] ?? 0,
        recognitionAccuracy: (json['recognition_accuracy'] ?? 0.0).toDouble(),
        hourlyData: (json['hourly_data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        weeklyData: (json['weekly_data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        recentEntries: (json['recent_entries'] as List? ?? []).map((e) => EntryLog.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'total_faces': totalFaces,
        'today_entries': todayEntries,
        'unauthorized_today': unauthorizedToday,
        'active_alerts': activeAlerts,
        'pending_approvals': pendingApprovals,
        'online_cameras': onlineCameras,
        'recognition_accuracy': recognitionAccuracy,
        'hourly_data': hourlyData,
        'weekly_data': weeklyData,
        'recent_entries': recentEntries.map((e) => e.toJson()).toList(),
      };
}

// --- Recognition Result (Simple legacy) ---
class RecognitionResult {
  final String personName;
  final String personId;
  final String status;
  final double confidence;
  final List<dynamic> location;

  RecognitionResult({
    required this.personName,
    required this.personId,
    required this.status,
    required this.confidence,
    required this.location,
  });

  factory RecognitionResult.fromJson(Map<dynamic, dynamic> json) => RecognitionResult(
        personName: json['person_name'] ?? 'Unknown',
        personId: json['person_id']?.toString() ?? '',
        status: json['status'] ?? 'unknown',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        location: json['location'] ?? [],
      );
}

// --- Auth Response Model ---
class AuthResponse {
  final bool success;
  final String? token;
  final String? message;
  final User? user;

  AuthResponse({required this.success, this.token, this.message, this.user});

  factory AuthResponse.fromJson(Map<dynamic, dynamic> json) => AuthResponse(
        success: json['success'] == true,
        token: json['token']?.toString(),
        message: json['message']?.toString(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );
}
