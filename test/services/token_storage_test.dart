import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TokenStorage', () {
    test('save and read access/refresh/user', () async {
      await TokenStorage.save(
        access: 'a',
        refresh: 'r',
        user: {'id': 1, 'username': 'fer'},
      );
      expect(await TokenStorage.access(), 'a');
      expect(await TokenStorage.refresh(), 'r');
      final user = await TokenStorage.user();
      expect(user!['username'], 'fer');
    });

    test('user is null when not set', () async {
      await TokenStorage.save(access: 'a', refresh: 'r');
      expect(await TokenStorage.user(), isNull);
    });

    test('user returns null for invalid JSON', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('badgeup.user', 'not-json-{');
      expect(await TokenStorage.user(), isNull);
    });

    test('clear removes everything', () async {
      await TokenStorage.save(
        access: 'a',
        refresh: 'r',
        user: {'id': 1},
      );
      await TokenStorage.clear();
      expect(await TokenStorage.access(), isNull);
      expect(await TokenStorage.refresh(), isNull);
      expect(await TokenStorage.user(), isNull);
    });

    test('save without user does not overwrite existing user', () async {
      await TokenStorage.save(
        access: 'a',
        refresh: 'r',
        user: {'id': 42},
      );
      await TokenStorage.save(access: 'a2', refresh: 'r2');
      expect(await TokenStorage.access(), 'a2');
      final user = await TokenStorage.user();
      expect(user!['id'], 42);
    });
  });
}
