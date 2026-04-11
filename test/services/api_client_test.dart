import 'dart:convert';

import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorage.save(
      access: 'access-old',
      refresh: 'refresh-ok',
      user: {'id': 1, 'username': 'fer'},
    );
  });

  tearDown(() {
    ApiClient.debugClient = null;
  });

  group('ApiClient basic methods', () {
    test('GET returns decoded JSON and sends bearer token', () async {
      http.Request? captured;
      ApiClient.debugClient = MockClient((req) async {
        captured = req as http.Request;
        return http.Response(
          jsonEncode({'ok': true, 'value': 42}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final data = await ApiClient.instance.get('/albums/');
      expect(data, isA<Map<String, dynamic>>());
      expect(data['value'], 42);
      expect(captured, isNotNull);
      expect(captured!.url.path.endsWith('/albums/'), true);
      expect(captured!.headers['Authorization'], 'Bearer access-old');
    });

    test('POST encodes body and decodes response', () async {
      String? sentBody;
      ApiClient.debugClient = MockClient((req) async {
        sentBody = req.body;
        return http.Response(jsonEncode({'id': 7}), 201);
      });

      final data = await ApiClient.instance.post('/stickers/', {'name': 'x'});
      expect(data['id'], 7);
      expect(jsonDecode(sentBody!)['name'], 'x');
    });

    test('PATCH works', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.method, 'PATCH');
        return http.Response(jsonEncode({'id': 1, 'name': 'y'}), 200);
      });
      final data = await ApiClient.instance.patch('/stickers/1/', {'name': 'y'});
      expect(data['name'], 'y');
    });

    test('DELETE returns null on 204', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.method, 'DELETE');
        return http.Response('', 204);
      });
      final data = await ApiClient.instance.delete('/stickers/1/');
      expect(data, isNull);
    });

    test('throws ApiException with detail message', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode({'detail': 'No autorizado'}),
          403,
        );
      });
      expect(
        () => ApiClient.instance.get('/albums/'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'No autorizado')),
      );
    });

    test('throws ApiException with field error message', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'name': ['Este campo es obligatorio.'],
          }),
          400,
        );
      });
      expect(
        () => ApiClient.instance.post('/stickers/', {}),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', contains('name'))
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });

  group('ApiClient auto-refresh on 401', () {
    test('refreshes access token and retries original request', () async {
      var callCount = 0;
      ApiClient.debugClient = MockClient((req) async {
        callCount++;
        final path = req.url.path;
        if (path.endsWith('/auth/token/refresh/')) {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          expect(body['refresh'], 'refresh-ok');
          return http.Response(
            jsonEncode({'access': 'access-new', 'refresh': 'refresh-ok'}),
            200,
          );
        }
        if (path.endsWith('/albums/')) {
          // First call -> 401, second call -> success.
          if (req.headers['Authorization'] == 'Bearer access-old') {
            return http.Response(jsonEncode({'detail': 'expired'}), 401);
          }
          if (req.headers['Authorization'] == 'Bearer access-new') {
            return http.Response(jsonEncode([
              {'id': 1, 'title': 'Italianos'}
            ]), 200);
          }
        }
        return http.Response('unexpected', 500);
      });

      final data = await ApiClient.instance.get('/albums/');
      expect(data, isA<List>());
      expect((data as List).first['title'], 'Italianos');
      expect(callCount, 3); // 401 + refresh + retry

      // Token was updated in storage.
      expect(await TokenStorage.access(), 'access-new');
    });

    test('gives up and throws when refresh also fails', () async {
      ApiClient.debugClient = MockClient((req) async {
        if (req.url.path.endsWith('/auth/token/refresh/')) {
          return http.Response(jsonEncode({'detail': 'invalid'}), 401);
        }
        return http.Response(jsonEncode({'detail': 'expired'}), 401);
      });

      expect(
        () => ApiClient.instance.get('/albums/'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
