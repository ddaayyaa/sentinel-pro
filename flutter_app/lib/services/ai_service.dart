import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../config/app_config.dart';

class AIService {
  static const String _apiKey = AppConfig.aiApiKey;
  static const String _endpoint = AppConfig.aiEndpoint;

  final Dio _dio = Dio();

  Future<String> getChatResponse(String userPrompt, DashboardStats? stats) async {
    final projectKnowledge = _getProjectKnowledge();
    
    if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      debugPrint('⚠️ OpenAI API Key not configured');
      return _generateLocalResponse(userPrompt, stats, projectKnowledge);
    }

    try {
      final systemContext = _buildSystemContext(stats);
      
      final response = await _dio.post(
        _endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemContext},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'].toString().trim();
      } else {
        return "System error: Failed to reach AI Core (Status: ${response.statusCode})";
      }
    } catch (e) {
      debugPrint('❌ AI Service Error: $e');
      return "Network error: Unable to connect to AI Core. Please check your internet connection.";
    }
  }

  String _buildSystemContext(DashboardStats? stats) {
    final recentLog = stats?.recentEntries.isNotEmpty == true ? stats!.recentEntries.first : null;
    final logContext = recentLog != null 
      ? "LAST EVENT: ${recentLog.personName} at ${recentLog.entryPoint} (Status: ${recentLog.status}, Confidence: ${recentLog.confidence})"
      : "LAST EVENT: No recent activity.";

    return """
${_getProjectKnowledge()}

CORE SYSTEM METRICS (REAL-TIME):
- Registered Person Base: ${stats?.totalFaces ?? 0}
- Total Entry Events Today: ${stats?.todayEntries ?? 0}
- Unauthorized Detections Today: ${stats?.unauthorizedToday ?? 0}
- High Priority Alerts (Unresolved): ${stats?.activeAlerts ?? 0}
- Functioning Camera Nodes: ${stats?.onlineCameras ?? 0}
- Current Recognition Accuracy: ${stats?.recognitionAccuracy ?? 0}%

$logContext

INSTRUCTIONS:
1. Use the "PROJECT OVERVIEW" above to explain how the system works.
2. Use the "CORE SYSTEM METRICS" and the "LAST EVENT" info to give specific status updates.
3. Be professional, technical, and predictive. If metrics show issues (e.g., unauthorized attempts), provide advice based on the project features.
4. If asked about the last person who entered, refer to the "LAST EVENT".
""";
  }

  String _getProjectKnowledge() {
    return """
PROJECT NAME: SENTINEL PRO v2
TYPE: Advanced AI Facial Recognition & Security Management System.

PROJECT ARCHITECTURE:
1. Frontend: Flutter (Mobile App) providing real-time monitoring, admin dashboard, and user access.
2. Backend: Python Flask API server managing face encodings, database (SQLite), and JWT authentication.
3. AI Engine: DeepFace & face_recognition libraries for biometric processing.

CORE FEATURES:
- Face Database: Admins can register people with multiple images for biometric training.
- Live Monitoring: Real-time camera feeds with face detection overlays.
- Entry Logs: Every entry is logged with a person name, timestamp, and confidence level.
- Security Alerts: System triggers alerts for 'unauthorized' persons (confidence below threshold).
- Role Management: Distinct roles for 'Admin' (full control) and 'Standard User' (view only).
- AI Core: This chat interface, powered by GPT, providing system-wide intelligence.

HOW IT WORKS:
- When a face is detected by a camera, the backend compares it against the encoded 'Face Database'.
- If a match is found with confidence > 0.75, access is 'GRANTED'.
- If no match or low confidence, an 'UNAUTHORIZED' alert is triggered.
- Admins can manually override logs, approve new user registrations, and train new datasets.
""";
  }

  String _generateLocalResponse(String prompt, DashboardStats? stats, String knowledge) {
    final query = prompt.toLowerCase();
    String response = "I am the Sentinel Pro AI Core. For a full GPT analysis, please add your API Key. However, I can still assist with project info:\n\n";

    if (query.contains('what is this') || query.contains('about') || query.contains('project')) {
      response += "Sentinel Pro is an AI-driven security system using Flutter and Python. It features real-time face recognition, automated entry logs, and advanced threat detection.";
    } else if (query.contains('how it work') || query.contains('mechanism')) {
      response += "It works by matching live camera frames against a biometric SQLite database using DeepFace. Access is granted only when confidence exceeds the system threshold (default 0.75).";
    } else if (query.contains('status') || query.contains('summary')) {
      response += "System Health: STABLE.\nRegistered People: ${stats?.totalFaces ?? 0}\nUnauthorized Events Today: ${stats?.unauthorizedToday ?? 0}\nActive Alerts: ${stats?.activeAlerts ?? 0}.";
    } else if (query.contains('alert') || query.contains('unauthorized')) {
      response += "Currently there are ${stats?.unauthorizedToday ?? 0} unauthorized events. You should check the 'Live Monitoring' screen to verify the camera feeds.";
    } else {
      response += "I've analyzed your query regarding '${prompt}'. Based on my project training, I suggest checking the Admin Dashboard for real-time metrics or the Face Database to manage authorized personnel.";
    }
    
    return response;
  }
}
