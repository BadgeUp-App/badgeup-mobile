import 'dart:convert';

import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:badgeup_mobile/services/user_session.dart';
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

  group('UserSession', () {
    test('setFromJson with null clears user', () {
      final session = UserSession();
      session.setFromJson({'id': 1, 'username': 'x'});
      expect(session.isLoggedIn, true);
      session.setFromJson(null);
      expect(session.isLoggedIn, false);
      expect(session.user, isNull);
    });

    test('setFromJson notifies listeners', () {
      final session = UserSession();
      var count = 0;
      session.addListener(() => count++);
      session.setFromJson({'id': 1, 'username': 'x'});
      expect(count, 1);
    });

    test('loadFromStorage reads cached user', () async {
      await TokenStorage.save(
        access: 'a',
        refresh: 'r',
        user: {'id': 9, 'username': 'stored'},
      );
      final session = UserSession();
      await session.loadFromStorage();
      expect(session.user!.id, 9);
      expect(session.user!.username, 'stored');
    });

    test('loadFromStorage does nothing when no cached user', () async {
      final session = UserSession();
      await session.loadFromStorage();
      expect(session.user, isNull);
    });

    test('refresh updates from /auth/profile/', () async {
      await TokenStorage.save(access: 'a', refresh: 'r');
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/auth/profile/'), true);
        return http.Response(
          jsonEncode({'id': 3, 'username': 'fer', 'first_name': 'Fernando'}),
          200,
        );
      });
      final session = UserSession();
      await session.refresh();
      expect(session.user!.id, 3);
      expect(session.user!.displayName, 'Fernando');
    });

    test('refresh is silent on network error', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response('nope', 500);
      });
      final session = UserSession();
      await session.refresh();
      expect(session.user, isNull);
    });

    test('clear removes user and storage', () async {
      await TokenStorage.save(
        access: 'a',
        refresh: 'r',
        user: {'id': 1, 'username': 'x'},
      );
      final session = UserSession();
      session.setFromJson({'id': 1, 'username': 'x'});
      await session.clear();
      expect(session.user, isNull);
      expect(await TokenStorage.access(), isNull);
    });
  });
}
