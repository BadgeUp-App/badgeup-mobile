import 'dart:convert';

import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/auth_service.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    ApiClient.debugClient = null;
  });

  group('AuthService.login', () {
    test('stores tokens and user on success', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/auth/login/'), true);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['username'], 'fer');
        expect(body['password'], 'secret');
        return http.Response(
          jsonEncode({
            'access': 'acc',
            'refresh': 'ref',
            'user': {'id': 1, 'username': 'fer'},
          }),
          200,
        );
      });

      final result = await AuthService.instance.login(
        username: 'fer',
        password: 'secret',
      );
      expect(result.access, 'acc');
      expect(result.refresh, 'ref');
      expect(result.user!['username'], 'fer');

      expect(await TokenStorage.access(), 'acc');
      expect(await TokenStorage.refresh(), 'ref');
    });

    test('throws AuthException with server error message', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode({'detail': 'Credenciales invalidas.'}),
          401,
        );
      });
      expect(
        () => AuthService.instance.login(username: 'a', password: 'b'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Credenciales invalidas.',
        )),
      );
    });

    test('uses fallback message when body is opaque', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response('oops', 500);
      });
      expect(
        () => AuthService.instance.login(username: 'a', password: 'b'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Credenciales invalidas.',
        )),
      );
    });
  });

  group('AuthService.register', () {
    test('calls register then login', () async {
      final calls = <String>[];
      ApiClient.debugClient = MockClient((req) async {
        calls.add(req.url.path);
        if (req.url.path.endsWith('/auth/register/')) {
          return http.Response(jsonEncode({'id': 1, 'username': 'new'}), 201);
        }
        if (req.url.path.endsWith('/auth/login/')) {
          return http.Response(
            jsonEncode({
              'access': 'acc',
              'refresh': 'ref',
              'user': {'id': 1, 'username': 'new'},
            }),
            200,
          );
        }
        return http.Response('nope', 500);
      });

      final result = await AuthService.instance.register(
        username: 'new',
        email: 'new@test.com',
        password: 'pass123',
        passwordConfirm: 'pass123',
      );
      expect(result.access, 'acc');
      expect(calls.where((p) => p.endsWith('/auth/register/')).length, 1);
      expect(calls.where((p) => p.endsWith('/auth/login/')).length, 1);
    });

    test('throws on 400', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'username': ['Ya existe.'],
          }),
          400,
        );
      });
      expect(
        () => AuthService.instance.register(
          username: 'x',
          email: 'x@y.com',
          password: 'p',
          passwordConfirm: 'p',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthService.updateProfile (json)', () {
    test('patches profile fields and updates session', () async {
      await TokenStorage.save(
        access: 'acc',
        refresh: 'ref',
        user: {'id': 1, 'username': 'fer'},
      );
      Map<String, dynamic>? sent;
      ApiClient.debugClient = MockClient((req) async {
        expect(req.method, 'PATCH');
        expect(req.url.path.endsWith('/auth/profile/'), true);
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 1,
            'username': 'fer',
            'first_name': 'Fernando',
            'last_name': 'Chavez',
            'bio': 'hola',
          }),
          200,
        );
      });

      final profile = await AuthService.instance.updateProfile(
        firstName: 'Fernando',
        lastName: 'Chavez',
        bio: 'hola',
      );
      expect(profile.displayName, 'Fernando Chavez');
      expect(sent!['first_name'], 'Fernando');
      expect(sent!['bio'], 'hola');
    });
  });
}
