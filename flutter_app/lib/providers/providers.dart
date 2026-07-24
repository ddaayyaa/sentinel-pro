import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

// ─── Auth Provider ────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  final NotificationService _notifications = NotificationService();
  Box? _cacheBox;
  
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isServerOnline = false;
  String? _error;
  Timer? _serverStatusTimer;

  AuthProvider(this._api) {
    _init();
    _startServerMonitoring();
  }

  void _startServerMonitoring() {
    _serverStatusTimer?.cancel();
    _serverStatusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isAuthenticated) {
        final online = await _api.testConnection();
        if (online != _isServerOnline) {
          _isServerOnline = online;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _serverStatusTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _cacheBox = await Hive.openBox('cache');
      _loadCachedProfile();
    } catch (e) {
      debugPrint('❌ AuthProvider Init Error: $e');
    }
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isServerOnline => _isServerOnline;
  String? get error => _error;
  bool get isAdmin => _currentUser?.role == 'admin';

  void _loadCachedProfile() {
    final cached = _cacheBox?.get('user_profile');
    if (cached != null) {
      try {
        _currentUser = User.fromJson(cached as Map);
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error loading cached profile: $e');
      }
    }
  }

  Future<void> checkAuth() async {
    final token = await _api.getToken();
    if (token == null) {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isServerOnline = await _api.testConnection();
    
    if (_isServerOnline) {
      final user = await _api.getProfile();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        if (_cacheBox != null) {
          await _cacheBox!.put('user_profile', user.toJson());
        }
      } else {
        _isAuthenticated = false;
        await _api.clearToken();
      }
    } else {
      if (_currentUser != null) {
        _isAuthenticated = true;
      }
    }
    notifyListeners();
  }

  Future<bool> testServer(String url) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.testConnection(url);
    _isServerOnline = result;
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    _isAuthenticated = false; // Reset auth state before new attempt
    _currentUser = null;       // Clear old user data
    notifyListeners();
    
    bool currentSuccess = false;
    try {
      final result = await _api.login(username, password);
      if (result.success && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _isServerOnline = true;
        currentSuccess = true;
        if (_cacheBox != null) {
          await _cacheBox!.put('user_profile', result.user!.toJson());
        }
        
        await _notifications.showNotification(
          id: 1,
          title: 'Login Successful',
          body: 'Welcome back, ${_currentUser?.fullName ?? username}!',
        );
      } else {
        _error = result.message ?? 'Login failed';
        await _notifications.showNotification(
          id: 2,
          title: 'Login Failed',
          body: _error!,
        );
      }
    } catch (e) {
      _error = 'Network error. Please check your server connection.';
    }
    _isLoading = false;
    notifyListeners();
    return currentSuccess;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _api.register(data);
    _isLoading = false;
    if (!result.success) {
      _error = result.message;
    } else {
      await _notifications.showNotification(
        id: 3,
        title: 'Registration Submitted',
        body: 'Awaiting admin approval.',
      );
    }
    notifyListeners();
    return result.success;
  }

  Future<void> logout() async {
    await _api.logout();
    if (_cacheBox != null) {
      await _cacheBox!.delete('user_profile');
    }
    _currentUser = null;
    _isAuthenticated = false;
    
    await _notifications.showNotification(
      id: 4,
      title: 'Logged Out',
      body: 'You have been safely logged out.',
    );
    notifyListeners();
  }

  Future<AuthResponse> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.forgotPassword(email);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthResponse> verifyResetCode(String token, String code) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.verifyResetCode(token, code);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.resetPassword(token, newPassword);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> changePassword(String oldPwd, String newPwd) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.changePassword(oldPwd, newPwd);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.updateProfile(data);
    if (result.success && result.user != null) {
      _currentUser = result.user;
      if (_cacheBox != null) {
        await _cacheBox!.put('user_profile', result.user!.toJson());
      }
    } else {
      _error = result.message;
    }
    _isLoading = false;
    notifyListeners();
    return result.success;
  }
}

// ─── Dashboard Provider ───────────────────────────────────
class DashboardProvider extends ChangeNotifier {
  final ApiService _api;
  Box? _cacheBox;
  DashboardStats? _stats;
  bool _isLoading = false;

  DashboardProvider(this._api) {
    _init();
  }

  Future<void> _init() async {
    try {
      _cacheBox = await Hive.openBox('cache');
      _loadCachedStats();
    } catch (e) {
      debugPrint('❌ DashboardProvider Init Error: $e');
    }
  }

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;

  void _loadCachedStats() {
    final cached = _cacheBox?.get('dashboard_stats');
    if (cached != null) {
      try {
        _stats = DashboardStats.fromJson(cached as Map);
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error loading cached stats: $e');
      }
    }
  }

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    final newStats = await _api.getDashboardStats();
    if (newStats != null) {
      _stats = newStats;
      if (_cacheBox != null) {
        await _cacheBox!.put('dashboard_stats', newStats.toJson());
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadStats();
}

// ─── Face Provider ────────────────────────────────────────
class FaceProvider extends ChangeNotifier {
  final ApiService _api;
  List<FaceRecord> _faces = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _searchQuery;

  FaceProvider(this._api);

  List<FaceRecord> get faces => _faces;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadFaces({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _faces = [];
      _hasMore = true;
    }
    if (!_hasMore) return;
    _isLoading = true;
    notifyListeners();
    final newFaces = await _api.getAllFaces(page: _page, search: _searchQuery);
    if (newFaces.length < 20) _hasMore = false;
    _faces.addAll(newFaces);
    _page++;
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query.isEmpty ? null : query;
    loadFaces(refresh: true);
  }

  Future<bool> deleteFace(dynamic id) async {
    final result = await _api.deleteFace(id);
    if (result) {
      _faces.removeWhere((f) => f.id == id);
      notifyListeners();
    }
    return result;
  }

  Future<bool> toggleStatus(dynamic id, String status) async {
    final result = await _api.toggleFaceStatus(id, status);
    if (result) {
      final idx = _faces.indexWhere((f) => f.id == id);
      if (idx != -1) {
        final oldFace = _faces[idx];
        _faces[idx] = FaceRecord(
          id: oldFace.id,
          personName: oldFace.personName,
          personId: oldFace.personId,
          imagePaths: oldFace.imagePaths,
          encodingCount: oldFace.encodingCount,
          status: status,
          department: oldFace.department,
          accessLevel: oldFace.accessLevel,
          registeredAt: oldFace.registeredAt,
          lastSeen: oldFace.lastSeen,
          matchCount: oldFace.matchCount,
        );
        notifyListeners();
      }
    }
    return result;
  }
}

// ─── Entry Log Provider ───────────────────────────────────
class EntryLogProvider extends ChangeNotifier {
  final ApiService _api;
  Box? _cacheBox;
  List<EntryLog> _logs = [];
  bool _isLoading = false;
  int _total = 0;
  String? _statusFilter;
  String? _dateFrom;
  String? _dateTo;

  EntryLogProvider(this._api) {
    _init();
  }

  Future<void> _init() async {
    try {
      _cacheBox = await Hive.openBox('cache');
      _loadCachedLogs();
    } catch (e) {
      debugPrint('❌ EntryLogProvider Init Error: $e');
    }
  }

  List<EntryLog> get logs => _logs;
  bool get isLoading => _isLoading;
  int get total => _total;

  void _loadCachedLogs() {
    final cached = _cacheBox?.get('entry_logs');
    if (cached != null) {
      try {
        _logs = (cached as List).map((e) => EntryLog.fromJson(e as Map)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error loading cached logs: $e');
      }
    }
  }

  Future<void> loadLogs({bool refresh = false}) async {
    _isLoading = true;
    if (refresh) _logs = [];
    notifyListeners();
    final data = await _api.getEntryLogs(
      status: _statusFilter,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
    _logs = (data['logs'] as List? ?? []).map((e) => EntryLog.fromJson(e)).toList();
    _total = data['total'] ?? 0;
    
    if (_statusFilter == null && _dateFrom == null && _cacheBox != null) {
      await _cacheBox!.put('entry_logs', _logs.take(20).map((e) => e.toJson()).toList());
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilters({String? status, String? dateFrom, String? dateTo}) {
    _statusFilter = status;
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    loadLogs(refresh: true);
  }

  Future<bool> overrideLog(dynamic id, String decision) async {
    final result = await _api.overrideEntry(id, decision, 'Admin Override via Mobile');
    if (result) {
      await loadLogs(refresh: true);
    }
    return result;
  }
}

// ─── Alert Provider ───────────────────────────────────────
class AlertProvider extends ChangeNotifier {
  final ApiService _api;
  List<SecurityAlert> _alerts = [];
  bool _isLoading = false;
  int get unresolvedCount => _alerts.where((a) => !a.resolved).length;

  AlertProvider(this._api);

  List<SecurityAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  Future<void> loadAlerts() async {
    _isLoading = true;
    notifyListeners();
    _alerts = await _api.getAlerts();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveAlert(dynamic id, String? note) async {
    final result = await _api.resolveAlert(id, note);
    if (result) await loadAlerts();
    return result;
  }
}

// ─── User Management Provider ─────────────────────────────
class UserManagementProvider extends ChangeNotifier {
  final ApiService _api;
  List<User> _users = [];
  bool _isLoading = false;
  int get pendingCount => _users.where((u) => u.status == 'pending').length;

  UserManagementProvider(this._api);

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers({String? status}) async {
    _isLoading = true;
    notifyListeners();
    _users = await _api.getAllUsers(status: status);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> setRole(dynamic id, String role) async {
    try {
      final response = await _api.updateUserStatus(id, role: role);
      if (response) await loadUsers();
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveUser(dynamic id) async {
    final result = await _api.approveUser(id);
    if (result) {
      _users.removeWhere((u) => u.id == id); // Remove from local list immediately
      notifyListeners();
    }
    return result;
  }

  Future<bool> rejectUser(dynamic id, String? reason) async {
    final result = await _api.rejectUser(id, reason);
    if (result) {
      _users.removeWhere((u) => u.id == id); // Remove from local list immediately
      notifyListeners();
    }
    return result;
  }

  Future<bool> toggleStatus(dynamic id, String status) async {
    final result = await _api.updateUserStatus(id, status: status);
    if (result) await loadUsers();
    return result;
  }

  Future<bool> deleteUser(dynamic id) async {
    final result = await _api.deleteUser(id);
    if (result) {
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    }
    return result;
  }
}

// ─── Training Provider ────────────────────────────────────
class TrainingProvider extends ChangeNotifier {
  final ApiService _api;
  TrainingJob? _currentJob;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  TrainingProvider(this._api);

  TrainingJob? get currentJob => _currentJob;
  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;
  bool get isTraining => _currentJob?.status == 'running';

  Future<bool> startTraining(List files, {String? modelType}) async {
    _isLoading = true;
    notifyListeners();
    _currentJob = await _api.startTraining(
      datasetFiles: files.cast(),
      modelType: modelType,
    );
    _isLoading = false;
    notifyListeners();
    return _currentJob != null;
  }

  Future<void> pollStatus() async {
    if (_currentJob == null) return;
    _currentJob = await _api.getTrainingStatus(_currentJob!.jobId);
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _history = await _api.getTrainingHistory();
    notifyListeners();
  }
}

// ─── Recognition Provider ────────────────────────────────
class RecognitionProvider extends ChangeNotifier {
  final ApiService _api;
  final EntryLogProvider _logProvider; // Injected to update Vault in real-time
  List<RecognitionResult> _results = [];
  RecognitionResult? _liveResult;
  bool _isProcessing = false;
  bool _isLiveActive = false;

  RecognitionProvider(this._api, this._logProvider);

  List<RecognitionResult> get results => _results;
  RecognitionResult? get liveResult => _liveResult;
  bool get isProcessing => _isProcessing;
  bool get isLiveActive => _isLiveActive;

  Future<RecognitionResult?> recognizeImage(dynamic imageFile) async {
    _isProcessing = true;
    notifyListeners();
    
    File file;
    if (imageFile is File) {
      file = imageFile;
    } else if (imageFile is String) {
      file = File(imageFile);
    } else {
      _isProcessing = false;
      notifyListeners();
      return null;
    }

    final result = await _api.recognizeImage(file);
    if (result != null) {
      _results.insert(0, result);
      // Immediately refresh logs to show in Evidence Vault
      await _logProvider.loadLogs(refresh: true);
    }
    
    _isProcessing = false;
    notifyListeners();
    return result;
  }

  Future<void> recognizeBatch(List files) async {
    _isProcessing = true;
    notifyListeners();
    final results = await _api.recognizeBatch(files.cast());
    _results = [...results, ..._results];
    await _logProvider.loadLogs(refresh: true);
    _isProcessing = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> recognizeMulti(dynamic imageFile) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      List<int> bytes;
      if (imageFile is File) {
        bytes = await imageFile.readAsBytes();
      } else if (imageFile is XFile) {
        bytes = await imageFile.readAsBytes();
      } else {
        bytes = imageFile as List<int>;
      }
      
      final String b64 = base64Encode(bytes);
      // Using the advanced endpoint we recently implemented
      final results = await _api.recognizeFrameAdv(b64, 'Main Gate');
      
      await _logProvider.loadLogs(refresh: true);
      _isProcessing = false;
      notifyListeners();
      
      // Map FaceRecognitionResult back to the legacy dynamic map for UI compatibility
      return results.map((r) => {
        'person_id': r.personId,
        'person_name': r.personName,
        'status': r.authorized ? 'authorized' : 'unauthorized',
        'confidence': r.confidence,
        'location': [r.bbox['top'], r.bbox['right'], r.bbox['bottom'], r.bbox['left']],
      }).toList();
    } catch (e) {
      debugPrint('❌ Multi-Recognition Error: $e');
      _isProcessing = false;
      notifyListeners();
      return [];
    }
  }

  void setLiveResult(RecognitionResult? result) {
    _liveResult = result;
    notifyListeners();
  }

  void setLiveActive(bool active) {
    _isLiveActive = active;
    notifyListeners();
  }

  void clearResults() {
    _results = [];
    notifyListeners();
  }
}

// ─── Camera Provider ──────────────────────────────────────
class CameraProvider extends ChangeNotifier {
  final ApiService _api;
  List<CameraDevice> _cameras = [];
  bool _isLoading = false;

  CameraProvider(this._api);

  List<CameraDevice> get cameras => _cameras;
  bool get isLoading => _isLoading;
  int get onlineCount => _cameras.where((c) => c.status == 'online').length;

  Future<void> loadCameras() async {
    _isLoading = true;
    notifyListeners();
    _cameras = await _api.getCameras();
    _isLoading = false;
    notifyListeners();
  }
}

// ─── Notification Provider ────────────────────────────────
class NotificationProvider extends ChangeNotifier {
  final ApiService _api;
  final NotificationService _localNotifications = NotificationService();
  List<AppNotification> _notifications = [];
  Timer? _pollingTimer;

  NotificationProvider(this._api) {
    _startPolling();
  }

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      loadNotifications();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications({bool isSilent = false}) async {
    final oldIds = _notifications.map((n) => n.id).toSet();
    _notifications = await _api.getNotifications();
    
    for (var n in _notifications) {
      if (!oldIds.contains(n.id) && n.type == 'alert' && !isSilent) {
        _localNotifications.showNotification(
          id: n.id ?? 100,
          title: n.title,
          body: n.body,
        );
      }
    }

    notifyListeners();
  }

  Future<void> markRead(dynamic id) async {
    await _api.markNotificationRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) notifyListeners();
  }
}

// ─── Navigation Provider ──────────────────────────────────
class UserNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
