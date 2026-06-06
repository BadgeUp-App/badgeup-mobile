import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'services/api_config.dart';
import 'services/chat_notifier.dart';
import 'services/push_service.dart';
import 'services/user_session.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/aroa_errors.dart';

void main() {
  AroaErrors.guard(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AroaErrors.init(
      ingestKey: const String.fromEnvironment('AROA_ERRORS_KEY'),
      release: const String.fromEnvironment('APP_VERSION', defaultValue: 'dev'),
      environment: kReleaseMode ? 'prod' : 'dev',
    );
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    _warmupBackend();
    await UserSession.instance.loadFromStorage();
    if (UserSession.instance.isLoggedIn) {
      PushService.instance.init().then((_) {
        PushService.instance.registerWithBackend();
      });
      ChatNotifier.instance.start();
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<UserSession>.value(value: UserSession.instance),
        ],
        child: const BadgeUpApp(),
      ),
    );
  });
}

void _warmupBackend() {
  final uri = Uri.parse('${ApiConfig.baseUrl}/auth/leaderboard/?limit=1');
  http
      .get(uri)
      .timeout(const Duration(seconds: 90))
      .then((_) {})
      .catchError((_) {});
}

class BadgeUpApp extends StatelessWidget {
  const BadgeUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'BadgeUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        AppTheme.syncBrightness(Theme.of(context).brightness);
        return child ?? const SizedBox.shrink();
      },
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSession>();
    if (session.isLoggedIn) return const MainShell();
    return const LoginScreen();
  }
}
