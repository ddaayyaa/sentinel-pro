import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentinel_pro/theme/app_theme.dart';
import 'package:sentinel_pro/providers/providers.dart';
import 'package:sentinel_pro/services/api_service.dart';
import 'package:sentinel_pro/services/ai_service.dart';
import 'package:sentinel_pro/services/notification_service.dart';
import 'package:sentinel_pro/screens/onboarding_screen.dart';
import 'package:sentinel_pro/screens/auth/login_screen.dart';
import 'package:sentinel_pro/screens/auth/register_screen.dart';
import 'package:sentinel_pro/screens/auth/forgot_password_screen.dart';
import 'package:sentinel_pro/screens/auth/pending_approval_screen.dart';
import 'package:sentinel_pro/screens/user/user_dashboard_screen.dart';
import 'package:sentinel_pro/screens/user/live_camera_screen.dart';
import 'package:sentinel_pro/screens/user/scanning_screen.dart';
import 'package:sentinel_pro/screens/user/scan_result_screen.dart';
import 'package:sentinel_pro/screens/user/upload_image_screen.dart';
import 'package:sentinel_pro/screens/user/bulk_upload_screen.dart';
import 'package:sentinel_pro/screens/user/scan_history_screen.dart';
import 'package:sentinel_pro/screens/user/result_details_screen.dart';
import 'package:sentinel_pro/screens/user/activity_logs_screen.dart';
import 'package:sentinel_pro/screens/user/notifications_screen.dart';
import 'package:sentinel_pro/screens/user/profile_screen.dart';
import 'package:sentinel_pro/screens/user/settings_screen.dart';
import 'package:sentinel_pro/screens/user/help_support_screen.dart';
import 'package:sentinel_pro/screens/user/ai_support_chat_screen.dart';
import 'package:sentinel_pro/screens/admin/admin_dashboard_screen.dart';
import 'package:sentinel_pro/screens/admin/live_monitoring_screen.dart';
import 'package:sentinel_pro/screens/admin/security_alerts_screen.dart';
import 'package:sentinel_pro/screens/admin/user_approvals_screen.dart';
import 'package:sentinel_pro/screens/admin/admin_user_details_screen.dart';
import 'package:sentinel_pro/screens/admin/face_database_screen.dart';
import 'package:sentinel_pro/screens/admin/add_person_screen.dart';
import 'package:sentinel_pro/screens/admin/edit_person_screen.dart';
import 'package:sentinel_pro/screens/admin/dataset_upload_screen.dart';
import 'package:sentinel_pro/screens/admin/model_training_screen.dart';
import 'package:sentinel_pro/screens/admin/training_progress_screen.dart';
import 'package:sentinel_pro/screens/admin/entry_logs_screen.dart';
import 'package:sentinel_pro/screens/admin/log_details_screen.dart';
import 'package:sentinel_pro/screens/admin/manual_override_screen.dart';
import 'package:sentinel_pro/screens/admin/reports_screen.dart';
import 'package:sentinel_pro/screens/admin/analytics_screen.dart';
import 'package:sentinel_pro/screens/admin/system_settings_screen.dart';
import 'package:sentinel_pro/screens/admin/role_management_screen.dart';
import 'package:sentinel_pro/screens/admin/admin_profile_screen.dart';
import 'package:sentinel_pro/screens/admin/audit_logs_screen.dart';
import 'package:sentinel_pro/screens/admin/admin_camera_screen.dart';
import 'package:sentinel_pro/screens/user/face_detection_screen.dart';
import 'package:sentinel_pro/screens/user/multi_face_detection_screen.dart';
import 'package:sentinel_pro/screens/user/support_center_screen.dart';
import 'package:sentinel_pro/screens/user/raise_ticket_screen.dart';
import 'package:sentinel_pro/screens/user/my_tickets_screen.dart';
import 'package:sentinel_pro/screens/user/live_support_chat_screen.dart';
import 'package:sentinel_pro/screens/user/rate_experience_screen.dart';
import 'package:sentinel_pro/screens/user/detailed_feedback_screen.dart';
import 'package:sentinel_pro/screens/user/thank_you_screen.dart';
import 'package:sentinel_pro/screens/user/camera_error_screen.dart';
import 'package:sentinel_pro/screens/user/camera_permission_screen.dart';
import 'package:sentinel_pro/screens/admin/server_status_screen.dart';
import 'package:sentinel_pro/screens/admin/storage_usage_screen.dart';
import 'package:sentinel_pro/screens/admin/api_status_screen.dart';
import 'package:sentinel_pro/screens/admin/security_logs_screen.dart';
import 'package:sentinel_pro/screens/auth/sign_out_screen.dart';
import 'package:sentinel_pro/screens/auth/session_expired_screen.dart';
import 'package:sentinel_pro/screens/user/onboarding_secure_screen.dart';
import 'package:sentinel_pro/screens/user/no_internet_connection_screen.dart';
import 'package:sentinel_pro/screens/user/data_sync_screen.dart';
import 'package:sentinel_pro/screens/user/notification_settings_screen.dart';
import 'package:sentinel_pro/screens/user/privacy_settings_screen.dart';
import 'package:sentinel_pro/screens/user/about_screen.dart';
import 'package:sentinel_pro/screens/admin/admin_ai_chat_screen.dart';
import 'package:sentinel_pro/screens/admin/evidence_vault_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('???? Flutter Error: ${details.exception}');
  };

  // Initialize Hive for Persistence
  bool hiveReady = false;
  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('cache');
    hiveReady = true;
    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Hive initialization failed: $e');
  }

  final apiService = ApiService();
  final aiService = AIService();
  final authProvider = AuthProvider(apiService);
  final entryLogProvider = EntryLogProvider(apiService);

  // Initialize Notification Service
  try {
    await NotificationService().init();
    debugPrint('✅ Notification Service initialized');
  } catch (e) {
    debugPrint('⚠️ Notification initialization failed: $e');
  }

  // Check Auth State (Auto-login disabled by user request, but we still verify token)
  if (hiveReady) {
    try {
      await authProvider.checkAuth();
      // Force unauthenticated state for next launch to require login
      authProvider.logout();
    } catch (e) {
      debugPrint('⚠️ Initial auth check failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<AIService>.value(value: aiService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider(apiService)),
        ChangeNotifierProvider<FaceProvider>(create: (_) => FaceProvider(apiService)),
        ChangeNotifierProvider<EntryLogProvider>.value(value: entryLogProvider),
        ChangeNotifierProvider<AlertProvider>(create: (_) => AlertProvider(apiService)),
        ChangeNotifierProvider<UserManagementProvider>(create: (_) => UserManagementProvider(apiService)),
        ChangeNotifierProvider<TrainingProvider>(create: (_) => TrainingProvider(apiService)),
        ChangeNotifierProvider<RecognitionProvider>(create: (_) => RecognitionProvider(apiService, entryLogProvider)),
        ChangeNotifierProvider<CameraProvider>(create: (_) => CameraProvider(apiService)),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider(apiService)),
        ChangeNotifierProvider<UserNavigationProvider>(create: (_) => UserNavigationProvider()),
      ],
      child: const SentinelProApp(),
    ),
  );
}

class SentinelProApp extends StatelessWidget {
  const SentinelProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'SENTINEL PRO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/pending-approval': (context) => const PendingApprovalScreen(),
            '/user-dashboard': (context) => const UserDashboardScreen(),
            '/live-camera': (context) => const LiveCameraScreen(),
            '/scanning': (context) => const ScanningScreen(),
            '/upload-image': (context) => const UploadImageScreen(),
            '/bulk-upload': (context) => const BulkUploadScreen(),
            '/scan-history': (context) => const ScanHistoryScreen(),
            '/result-details': (context) => const ResultDetailsScreen(),
            '/activity-logs': (context) => const ActivityLogsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/help-support': (context) => const HelpSupportScreen(),
            '/ai-chat': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return AISupportChatScreen(mode: args?['mode'] ?? 'chat');
            },
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/live-monitoring': (context) => const LiveMonitoringScreen(),
            '/security-alerts': (context) => const SecurityAlertsScreen(),
            '/user-approvals': (context) => const UserApprovalsScreen(),
            '/admin-user-details': (context) => const AdminUserDetailsScreen(),
            '/face-database': (context) => const FaceDatabaseScreen(),
            '/add-person': (context) => const AddPersonScreen(),
            '/edit-person': (context) => const EditPersonScreen(),
            '/dataset-upload': (context) => const DatasetUploadScreen(),
            '/model-training': (context) => const ModelTrainingScreen(),
            '/training-progress': (context) => const TrainingProgressScreen(),
            '/entry-logs': (context) => const EntryLogsScreen(),
            '/log-details': (context) => const LogDetailsScreen(),
            '/manual-override': (context) => const ManualOverrideScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
            '/system-settings': (context) => const SystemSettingsScreen(),
            '/role-management': (context) => const RoleManagementScreen(),
            '/admin-profile': (context) => const AdminProfileScreen(),
            '/audit-logs': (context) => const AuditLogsScreen(),
            '/admin-camera': (context) => const AdminCameraScreen(),
            '/face-detection': (context) => const FaceDetectionScreen(),
            '/multi-face-detection': (context) => const MultiFaceDetectionScreen(),
            '/support-center': (context) => const SupportCenterScreen(),
            '/raise-ticket': (context) => const RaiseTicketScreen(),
            '/my-tickets': (context) => const MyTicketsScreen(),
            '/live-support': (context) => const LiveSupportChatScreen(),
            '/rate-experience': (context) => const RateExperienceScreen(),
            '/detailed-feedback': (context) => const DetailedFeedbackScreen(),
            '/thank-you': (context) => const ThankYouScreen(),
            '/camera-error': (context) => const CameraErrorScreen(),
            '/camera-permission': (context) => const CameraPermissionScreen(),
            '/server-status': (context) => const ServerStatusScreen(),
            '/storage-usage': (context) => const StorageUsageScreen(),
            '/api-status': (context) => const ApiStatusScreen(),
            '/security-logs': (context) => const SecurityLogsScreen(),
            '/sign-out': (context) => const SignOutScreen(),
            '/session-expired': (context) => const SessionExpiredScreen(),
            '/onboarding-secure': (context) => const OnboardingSecureScreen(),
            '/no-internet': (context) => const NoInternetConnectionScreen(),
            '/data-sync': (context) => const DataSyncScreen(),
            '/notification-settings': (context) => const NotificationSettingsScreen(),
            '/privacy-settings': (context) => const PrivacySettingsScreen(),
            '/about': (context) => const AboutScreen(),
            '/admin-ai-chat': (context) => const AdminAIChatScreen(),
            '/evidence-vault': (context) => const EvidenceVaultScreen(),
            '/scan-result': (context) => const ScanResultScreen(),
          },
        );
      }
    );
  }
}
