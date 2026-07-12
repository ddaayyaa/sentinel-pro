class AppConfig {
  /// The base URL for the API server.
  /// Can be overridden at compile time using:
  /// `flutter run --dart-define=API_BASE_URL=http://your-ip:5000`
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.225.200.156:5000',
  );

  /// OpenAI API Key for the AI Service.
  /// Can be overridden at compile time using:
  /// `flutter run --dart-define=AI_API_KEY=your-key`
  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
  );

  /// OpenAI API Endpoint.
  static const String aiEndpoint = 'https://api.openai.com/v1/chat/completions';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 90);
  static const Duration sendTimeout = Duration(seconds: 90);

  /// Storage Keys
  static const String apiBaseUrlKey = 'api_base_url';
  static const String authTokenKey = 'auth_token';
}
