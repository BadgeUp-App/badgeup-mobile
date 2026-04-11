import 'dart:convert';

import 'package:badgeup_mobile/models/sticker.dart';
import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/content_api.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorage.save(access: 'acc', refresh: 'ref');
  });

  tearDown(() {
    ApiClient.debugClient = null;
  });

  group('ContentApi.fetchAlbums', () {
    test('parses list response', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/albums/'), true);
        return http.Response(
          jsonEncode([
            {'id': 1, 'title': 'Italianos', 'theme': 'cars'},
            {'id': 2, 'title': 'Alemanes', 'theme': 'cars'},
          ]),
          200,
        );
      });
      final albums = await ContentApi.instance.fetchAlbums();
      expect(albums.length, 2);
      expect(albums.first.title, 'Italianos');
    });

    test('parses paginated results shape', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'results': [
              {'id': 10, 'title': 'Clasicos'}
            ],
          }),
          200,
        );
      });
      final albums = await ContentApi.instance.fetchAlbums();
      expect(albums.length, 1);
      expect(albums.first.id, 10);
    });

    test('returns empty list on unexpected shape', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response('{"foo": "bar"}', 200);
      });
      final albums = await ContentApi.instance.fetchAlbums();
      expect(albums, isEmpty);
    });
  });

  group('ContentApi.fetchAlbumDetail', () {
    test('returns album with stickers', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/albums/7/'), true);
        return http.Response(
          jsonEncode({
            'id': 7,
            'title': 'Italianos',
            'stickers': [
              {'id': 100, 'name': 'Ferrari F40', 'rarity': 'legendario'}
            ],
          }),
          200,
        );
      });
      final album = await ContentApi.instance.fetchAlbumDetail(7);
      expect(album.id, 7);
      expect(album.stickers.length, 1);
      expect(album.stickers.first.rarity, Rarity.legendario);
    });

    test('throws on invalid response', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response('[]', 200);
      });
      expect(
        () => ContentApi.instance.fetchAlbumDetail(1),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('ContentApi.fetchCaptureHistory', () {
    test('parses entries', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/captures/history/'), true);
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'sticker_id': 10,
              'sticker_name': 'Ferrari F40',
              'album_title': 'Italianos',
              'unlocked_at': '2026-01-01T10:00:00Z',
            }
          ]),
          200,
        );
      });
      final captures = await ContentApi.instance.fetchCaptureHistory();
      expect(captures.length, 1);
      expect(captures.first.stickerName, 'Ferrari F40');
    });
  });

  group('ContentApi.fetchStickerLocations', () {
    test('parses location entries', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/stickers/locations/'), true);
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'sticker_id': 5,
              'sticker_name': 'BMW',
              'location_lat': 20.67,
              'location_lng': -103.38,
            }
          ]),
          200,
        );
      });
      final locs = await ContentApi.instance.fetchStickerLocations();
      expect(locs.length, 1);
      expect(locs.first.lat, 20.67);
    });
  });

  group('ContentApi.fetchLeaderboard', () {
    test('assigns rank by index', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.query, contains('limit=5'));
        return http.Response(
          jsonEncode([
            {'id': 1, 'username': 'a', 'computed_points': 300},
            {'id': 2, 'username': 'b', 'computed_points': 200},
            {'id': 3, 'username': 'c', 'computed_points': 100},
          ]),
          200,
        );
      });
      final board = await ContentApi.instance.fetchLeaderboard(limit: 5);
      expect(board.length, 3);
      expect(board[0].rank, 1);
      expect(board[2].rank, 3);
      expect(board[0].points, 300);
    });
  });

  group('ContentApi.fetchFriends', () {
    test('parses friend list', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/friends/'), true);
        return http.Response(
          jsonEncode([
            {'id': 1, 'username': 'luis', 'first_name': 'Luis', 'computed_points': 50}
          ]),
          200,
        );
      });
      final friends = await ContentApi.instance.fetchFriends();
      expect(friends.length, 1);
      expect(friends.first.name, 'Luis');
    });
  });

  group('ContentApi.fetchPublicProfile', () {
    test('parses single profile', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/auth/users/9/'), true);
        return http.Response(
          jsonEncode({'id': 9, 'username': 'x', 'first_name': 'X'}),
          200,
        );
      });
      final p = await ContentApi.instance.fetchPublicProfile(9);
      expect(p.id, 9);
    });
  });

  group('ContentApi.setStickerMessage', () {
    test('posts message and returns sticker', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path.endsWith('/stickers/4/message/'), true);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['message'], 'hola');
        return http.Response(
          jsonEncode({'id': 4, 'name': 'x', 'message': 'hola'}),
          200,
        );
      });
      final s = await ContentApi.instance.setStickerMessage(
        stickerId: 4,
        message: 'hola',
      );
      expect(s.id, 4);
    });
  });

  group('MatchPhotoResult.fromJson', () {
    test('parses unlocked payload', () {
      final r = MatchPhotoResult.fromJson({
        'unlocked': true,
        'already_unlocked': false,
        'message': 'nice',
        'match_score': 0.85,
        'fun_fact': 'el F40 fue el ultimo disenado por Enzo',
        'car': {'make': 'Ferrari', 'model': 'F40'},
        'sticker': {'id': 1, 'name': 'Ferrari F40', 'rarity': 'legendario'},
      });
      expect(r.unlocked, true);
      expect(r.matchScore, 0.85);
      expect(r.stickerName, 'Ferrari F40');
      expect(r.carMake, 'Ferrari');
      expect(r.carModel, 'F40');
      expect(r.sticker!.rarity, Rarity.legendario);
    });

    test('handles missing fields', () {
      final r = MatchPhotoResult.fromJson({});
      expect(r.unlocked, false);
      expect(r.matchScore, 0.0);
      expect(r.sticker, isNull);
      expect(r.stickerId, isNull);
    });
  });
}
