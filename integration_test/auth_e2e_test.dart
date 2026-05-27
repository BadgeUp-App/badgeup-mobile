import 'dart:convert';

import 'package:badgeup_mobile/screens/login_screen.dart';
import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/auth_service.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:badgeup_mobile/services/user_session.dart';
import 'package:badgeup_mobile/theme/app_theme.dart';
import 'package:badgeup_mobile/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp({required Widget home}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<UserSession>.value(value: UserSession.instance),
    ],
    child: Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'BadgeUp Test',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeProvider.themeMode,
        home: home,
      ),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorage.clear();
    await UserSession.instance.loadFromStorage();
  });

  tearDown(() {
    ApiClient.debugClient = null;
  });

  testWidgets('login screen renderea con campos y boton', (tester) async {
    await tester.pumpWidget(_buildTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('BadgeUp'), findsWidgets);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
  });

  testWidgets('login screen permite ingresar email y password',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'usuario@test.com');
    await tester.enterText(fields.at(1), 'mipassword');
    await tester.pump();

    expect(tester.widget<TextField>(fields.first).controller?.text,
        'usuario@test.com');
  });

  testWidgets('AuthService.register valida que passwords coinciden',
      (tester) async {
    ApiClient.debugClient = MockClient((req) async {
      return http.Response('{}', 200);
    });

    try {
      await AuthService.instance.register(
        username: 'nu',
        email: 'nu@test.com',
        password: 'p1',
        passwordConfirm: 'p2',
      );
      fail('debio lanzar AuthException por mismatch');
    } catch (e) {
      expect(e, isA<AuthException>());
      expect((e as AuthException).message, contains('coinciden'));
    }
  });

  testWidgets('TokenStorage.save y access regresan los valores guardados',
      (tester) async {
    await TokenStorage.save(
      access: 'acc-token',
      refresh: 'ref-token',
      user: {'id': 1, 'username': 'tester'},
    );
    expect(await TokenStorage.access(), 'acc-token');
    expect(await TokenStorage.refresh(), 'ref-token');
    final user = await TokenStorage.user();
    expect(user?['username'], 'tester');
  });

  testWidgets('TokenStorage.clear elimina todos los tokens', (tester) async {
    await TokenStorage.save(
      access: 'a1',
      refresh: 'r1',
      user: {'id': 1, 'username': 'temp'},
    );
    expect(await TokenStorage.access(), 'a1');
    await TokenStorage.clear();
    expect(await TokenStorage.access(), isNull);
    expect(await TokenStorage.refresh(), isNull);
    expect(await TokenStorage.user(), isNull);
  });

  testWidgets('UserSession.loadFromStorage carga user si hay tokens',
      (tester) async {
    await TokenStorage.save(
      access: 'a1',
      refresh: 'r1',
      user: {
        'id': 1,
        'username': 'storedtester',
        'email': 'stored@test.com',
        'points': 50,
      },
    );
    await UserSession.instance.loadFromStorage();
    expect(UserSession.instance.isLoggedIn, true);
    expect(UserSession.instance.user?.username, 'storedtester');
  });

  testWidgets('ApiClient.debugClient permite interceptar requests',
      (tester) async {
    final received = <String>[];
    ApiClient.debugClient = MockClient((req) async {
      received.add(req.url.path);
      return http.Response(
        jsonEncode({'count': 0, 'results': <Map<String, dynamic>>[]}),
        200,
      );
    });

    try {
      await ApiClient.instance.get('/auth/leaderboard/?limit=5');
    } catch (_) {}

    expect(received.any((p) => p.contains('/auth/leaderboard/')), true);
  });
}
