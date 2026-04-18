class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_URL');
  static const String _prodUrl = 'https://badgeup-backend.onrender.com/api';

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    return _prodUrl;
  }

  static const Duration timeout = Duration(seconds: 30);
}
