import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    // iOS simulator can reach the host via localhost.
    // Android emulator needs 10.0.2.2 to reach the host machine.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static const Duration timeout = Duration(seconds: 15);
}
