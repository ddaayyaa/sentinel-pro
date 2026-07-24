import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../config/app_config.dart';

class ApiService {
  static const String _tokenKey = AppConfig.authTokenKey;
  static const String _baseUrlKey = AppConfig.apiBaseUrlKey;

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  String _currentBaseUrl = AppConfig.defaultApiBaseUrl;
  late Future<void> _initializationFuture;
  String? _cachedToken;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.defaultApiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: {'Content-Type': 'application/json'},
        )) {
    _initializationFuture = _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _cachedToken = await _storage.read(key: _tokenKey);
      final savedUrl = _prefs.getString(_baseUrlKey);
      
      // FORCE SYNC: If saved URL is from an old network session, clear it
      if (savedUrl != null && !savedUrl.contains('10.232.189.156')) {
        debugPrint('🧹 Clearing stale saved URL: $savedUrl');
        await _prefs.remove(_baseUrlKey);
      }

      final freshSavedUrl = _prefs.getString(_baseUrlKey);
      if (freshSavedUrl != null && freshSavedUrl.isNotEmpty) {
        // Double check if saved URL is still valid, else fallback to default
        final isSavedValid = await _testConnectionInternal(freshSavedUrl);
        if (isSavedValid) {
          _currentBaseUrl = freshSavedUrl;
          _dio.options.baseUrl = _currentBaseUrl;
          debugPrint('🚀 ApiService initialized with VALID SAVED baseUrl: $_currentBaseUrl');
        } else {
          debugPrint('⚠️ Stored baseUrl ($freshSavedUrl) is UNREACHABLE. Falling back to default: $_currentBaseUrl');
          _dio.options.baseUrl = _currentBaseUrl;
          await _prefs.remove(_baseUrlKey);
        }
      } else {
        debugPrint('🚀 ApiService initialized with DEFAULT baseUrl: $_currentBaseUrl');
      }

      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌐 API Request: [${options.method}] ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ API Response: [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ API Error: [${error.response?.statusCode}] ${error.requestOptions.path}');
          debugPrint('   Message: ${error.message}');
          return handler.next(error);
        },
      ));
    } catch (e) {
      debugPrint('⚠️ ApiService initialization error: $e');
    }
  }

  String get baseUrl => _currentBaseUrl;

  Future<void> updateBaseUrl(String newUrl) async {
    await _initializationFuture;
    if (newUrl.isEmpty) return;
    _currentBaseUrl = newUrl;
    _dio.options.baseUrl = _currentBaseUrl;
    await _prefs.setString(_baseUrlKey, _currentBaseUrl);
    debugPrint('🔄 ApiService baseUrl updated to: $_currentBaseUrl');
  }

  Future<void> saveToken(String token) async {
    await _initializationFuture;
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _initializationFuture;
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    await _initializationFuture;
    return _cachedToken;
  }

  Future<bool> _testConnectionInternal(String url) async {
    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
      )).get('$url/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection Test Failed for $url: $e');
      return false;
    }
  }

  Future<bool> testConnection([String? testUrl]) async {
    if (testUrl == null) await _initializationFuture;
    final url = testUrl ?? _currentBaseUrl;
    return _testConnectionInternal(url);
  }

  /// Secure Image URL with Authentication Header Support
  Map<String, String> get authHeader => {
    'Authorization': 'Bearer ${_cachedToken ?? ''}'
  };

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    // Standardize URL based on biometric vs evidence
    String fileName = path.split('/').last.split('\\').last;

    if (path.contains('faces/')) {
        final parts = path.split('faces/');
        if (parts.length > 1) {
            return '$_currentBaseUrl/api/files/faces/${parts[1].replaceAll('\\', '/')}';
        }
    } 

    if (path.contains('unauthorized/')) {
         return '$_currentBaseUrl/api/logs/unauthorized/$fileName';
    }

    return '$_currentBaseUrl/api/files/logs/$fileName';
  }

  // ─── Auth Endpoints ──────────────────────────────────
  Future<AuthResponse> login(String username, String password) async {
    await _initializationFuture;
    debugPrint('🚀 [DIAGNOSTIC] Login Attempt: $username');
    debugPrint('🚀 [DIAGNOSTIC] Using URL: $_currentBaseUrl');
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });
      debugPrint('🚀 [DIAGNOSTIC] Server Response Code: ${response.statusCode}');
      final result = AuthResponse.fromJson(response.data);
      if (result.token != null) await saveToken(result.token!);
      return result;
    } catch (e) {
      debugPrint('🚀 [DIAGNOSTIC] Login Error Detail: $e');
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  Future<AuthResponse> register(Map<String, dynamic> data) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/auth/register', data: data);
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  Future<bool> logout() async {
    await _initializationFuture;
    try {
      await _dio.post('/api/auth/logout');
      await clearToken();
      return true;
    } catch (e) {
      await clearToken();
      return true;
    }
  }

  Future<User?> getProfile() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/auth/profile');
      return User.fromJson(response.data['user']);
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse> updateProfile(Map<String, dynamic> data) async {
    await _initializationFuture;
    try {
      final response = await _dio.put('/api/auth/profile', data: data);
      return AuthResponse(success: true, user: User.fromJson(response.data['user']));
    } catch (e) {
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/auth/change-password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<AuthResponse> verifyResetCode(String token, String code) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/auth/verify-reset-code', data: {
        'token': token,
        'code': code,
      });
      return AuthResponse(success: response.data['success'], message: response.data['message']);
    } catch (e) {
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
      return AuthResponse(success: response.data['success'], message: response.data['message']);
    } catch (e) {
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  Future<AuthResponse> forgotPassword(String email) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/auth/forgot-password', data: {'email': email});
      return AuthResponse(
        success: response.data['success'],
        message: response.data['message'],
        token: response.data['token'],
      );
    } catch (e) {
      return AuthResponse(success: false, message: _parseError(e));
    }
  }

  // ─── Dashboard Endpoints ─────────────────────────────
  Future<DashboardStats?> getDashboardStats() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/dashboard/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getSystemStatus() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/dashboard/system-status');
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      return {};
    }
  }

  // ─── Face Recognition Endpoints ──────────────────────
  Future<RecognitionResult?> recognizeImage(File imageFile) async {
    await _initializationFuture;
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });
      final response = await _dio.post('/api/recognize/image', data: formData);
      return RecognitionResult.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<RecognitionResult>> recognizeBatch(List<File> files) async {
    await _initializationFuture;
    try {
      final formData = FormData();
      for (var file in files) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(file.path)));
      }
      final response = await _dio.post('/api/recognize/batch', data: formData);
      return (response.data['results'] as List)
          .map((e) => RecognitionResult.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<RecognitionResult?> recognizeFrame(List<int> frameBytes) async {
    await _initializationFuture;
    try {
      final formData = FormData.fromMap({
        'frame': MultipartFile.fromBytes(frameBytes, filename: 'frame.jpg'),
      });
      final response = await _dio.post('/api/recognize/frame', data: formData);
      return RecognitionResult.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> recognizeMulti(List<int> frameBytes) async {
    await _initializationFuture;
    try {
      final formData = FormData.fromMap({
        'frame': MultipartFile.fromBytes(frameBytes, filename: 'frame.jpg'),
      });
      final response = await _dio.post('/api/recognize/multi', data: formData);
      return response.data;
    } catch (e) {
      return {'results': [], 'error': e.toString()};
    }
  }

  Future<List<FaceRecognitionResult>> recognizeFrameAdv(String base64Image, String gate) async {
    await _initializationFuture;
    try {
      final response = await _dio.post('/api/recognize/frame', data: {
        'frame': base64Image,
        'gate': gate,
      });
      final results = response.data['results'] as List? ?? [];
      return results.map((r) => FaceRecognitionResult.fromJson(r)).toList();
    } catch (e) {
      debugPrint('❌ Recognition API error: $e');
      return [];
    }
  }

  // ─── Face Registration Endpoints ─────────────────────
  Future<Map<String, dynamic>> registerFace({
    required String personName,
    required String personId,
    required List<File> images,
    String? department,
    String? accessLevel,
  }) async {
    await _initializationFuture;
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('person_name', personName));
      formData.fields.add(MapEntry('person_id', personId));
      if (department != null) formData.fields.add(MapEntry('department', department));
      if (accessLevel != null) formData.fields.add(MapEntry('access_level', accessLevel));
      for (var file in images) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(file.path)));
      }
      final response = await _dio.post('/api/faces/register', data: formData);
      return response.data;
    } catch (e) {
      return {'success': false, 'message': _parseError(e)};
    }
  }

  Future<List<FaceRecord>> getAllFaces({int page = 1, int limit = 20, String? search}) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/faces', queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return (response.data['faces'] as List)
          .map((e) => FaceRecord.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteFace(dynamic faceId) async {
    await _initializationFuture;
    try {
      await _dio.delete('/api/faces/$faceId');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFaceStatus(dynamic faceId, String status) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/faces/$faceId/toggle', data: {'status': status});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<FaceRecord?> getFaceDetails(dynamic faceId) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/faces/$faceId');
      return FaceRecord.fromJson(response.data['face']);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateFace(dynamic faceId, Map<String, dynamic> data) async {
    await _initializationFuture;
    try {
      await _dio.put('/api/faces/$faceId', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Entry Log Endpoints ──────────────────────────────
  Future<Map<String, dynamic>> getEntryLogs({
    int page = 1,
    int limit = 20,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/logs', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      });
      return response.data;
    } catch (e) {
      return {'logs': [], 'total': 0};
    }
  }

  Future<bool> overrideEntry(dynamic logId, String decision, String? note) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/logs/$logId/override', data: {
        'decision': decision,
        if (note != null) 'note': note,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> exportLogs(String format) async {
    await _initializationFuture;
    try {
      String endpoint = '/api/admin/export-logs';
      if (format == 'pdf') {
        endpoint = '/api/admin/export-logs-pdf';
      } else if (format == 'word') {
        endpoint = '/api/admin/export-logs-word';
      }
      
      await _dio.get(endpoint, options: Options(responseType: ResponseType.bytes));
      return 'success'; // or return bytes if handled
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUnauthorizedImages() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/logs/unauthorized/images');
      return List<Map<String, dynamic>>.from(response.data['images'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // ─── Alert Endpoints ──────────────────────────────────
  Future<List<SecurityAlert>> getAlerts() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/alerts');
      return (response.data['alerts'] as List)
          .map((e) => SecurityAlert.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> resolveAlert(dynamic alertId, String? note) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/alerts/$alertId/resolve', data: {'note': note});
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── User Management Endpoints ────────────────────────
  Future<List<User>> getAllUsers({String? status}) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/users', queryParameters: {
        if (status != null) 'status': status,
      });
      return (response.data['users'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveUser(dynamic userId) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/users/$userId/approve');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectUser(dynamic userId, String? reason) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/users/$userId/reject', data: {'reason': reason});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserStatus(dynamic userId, {String? status, String? role}) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/users/$userId/status', data: {
        if (status != null) 'status': status,
        if (role != null) 'role': role,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(dynamic userId) async {
    await _initializationFuture;
    try {
      await _dio.delete('/api/users/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Training Endpoints ───────────────────────────────
  Future<TrainingJob?> startTraining({required List<File> datasetFiles, String? modelType}) async {
    await _initializationFuture;
    try {
      final formData = FormData();
      for (var file in datasetFiles) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path)));
      }
      if (modelType != null) formData.fields.add(MapEntry('model_type', modelType));
      final response = await _dio.post('/api/training/start', data: formData);
      return TrainingJob.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<TrainingJob?> getTrainingStatus(String jobId) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/training/status/$jobId');
      return TrainingJob.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRegisterJobStatus(String jobId) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/faces/register/status/$jobId');
      return jsonEncode(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTrainingHistory() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/training/history');
      return List<Map<String, dynamic>>.from(response.data['history'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // ─── Camera Endpoints ─────────────────────────────────
  Future<List<CameraDevice>> getCameras() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/cameras');
      return (response.data['cameras'] as List)
          .map((e) => CameraDevice.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Settings Endpoints ───────────────────────────────
  Future<Map<String, dynamic>> getSettings() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/settings');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    await _initializationFuture;
    try {
      await _dio.put('/api/settings', data: settings);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/admin/storage-usage');
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getApiHealth() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/admin/api-status');
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getAnalytics({String period = '7d'}) async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/analytics', queryParameters: {'period': period});
      return response.data;
    } catch (e) {
      return {};
    }
  }

  // ─── Notifications ────────────────────────────────────
  Future<List<AppNotification>> getNotifications() async {
    await _initializationFuture;
    try {
      final response = await _dio.get('/api/notifications');
      return (response.data['notifications'] as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> markNotificationRead(dynamic notifId) async {
    await _initializationFuture;
    try {
      await _dio.post('/api/notifications/$notifId/read');
      return true;
    } catch (e) {
      return false;
    }
  }

  String _parseError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout || 
          error.type == DioExceptionType.receiveTimeout) {
        return 'Server busy (Load Spike). Retrying...';
      }
      if (error.type == DioExceptionType.connectionError) {
         return 'Server unreachable. Ensure you are on the same network.';
      }
      if (error.response?.statusCode == 401) return error.response?.data?['message'] ?? 'Wrong Credits';
      if (error.response?.statusCode == 403) return 'Account pending approval or disabled.';
      if (error.response?.statusCode == 404) return 'Endpoint missing. Check version.';
      if (error.response?.statusCode == 500) return 'Server Stability Error (Fixed with Cache).';
      return error.response?.data?['message'] ?? 'Network error (${error.response?.statusCode})';
    }
    return error.toString();
  }
}
