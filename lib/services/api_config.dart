import 'dart:io' show Platform;

class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  static const Duration timeout = Duration(seconds: 15);
}
