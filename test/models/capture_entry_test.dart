import 'package:badgeup_mobile/models/capture_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureEntry.fromJson', () {
    test('parses all fields', () {
      final entry = CaptureEntry.fromJson({
        'id': 3,
        'sticker_id': 44,
        'sticker_name': 'Ferrari F40',
        'album_title': 'Italianos',
        'unlocked_at': '2026-03-01T08:30:00Z',
      });
      expect(entry.id, 3);
      expect(entry.stickerId, 44);
      expect(entry.stickerName, 'Ferrari F40');
      expect(entry.albumTitle, 'Italianos');
      expect(entry.unlockedAt, isNotNull);
      expect(entry.unlockedAt!.year, 2026);
    });

    test('handles missing timestamp', () {
      final entry = CaptureEntry.fromJson({
        'id': 1,
        'sticker_id': 1,
        'sticker_name': 'X',
      });
      expect(entry.unlockedAt, isNull);
      expect(entry.albumTitle, '');
    });

    test('handles invalid timestamp', () {
      final entry = CaptureEntry.fromJson({'unlocked_at': 'not-a-date'});
      expect(entry.unlockedAt, isNull);
    });

    test('handles integer id as string fallback', () {
      final entry = CaptureEntry.fromJson({'id': '8', 'sticker_id': '9'});
      expect(entry.id, 8);
      expect(entry.stickerId, 9);
    });
  });

  group('StickerLocationEntry.fromJson', () {
    test('parses numeric lat/lng', () {
      final loc = StickerLocationEntry.fromJson({
        'id': 1,
        'sticker_id': 10,
        'sticker_name': 'BMW M3',
        'album_title': 'Alemanes',
        'username': 'fer',
        'location_lat': 20.67,
        'location_lng': -103.38,
        'unlocked_at': '2026-01-15T12:00:00Z',
      });
      expect(loc.lat, 20.67);
      expect(loc.lng, -103.38);
      expect(loc.username, 'fer');
      expect(loc.unlockedAt!.month, 1);
    });

    test('parses string lat/lng', () {
      final loc = StickerLocationEntry.fromJson({
        'location_lat': '20.5',
        'location_lng': '-103.2',
      });
      expect(loc.lat, 20.5);
      expect(loc.lng, -103.2);
    });

    test('defaults invalid lat/lng to 0.0', () {
      final loc = StickerLocationEntry.fromJson({
        'location_lat': 'abc',
        'location_lng': null,
      });
      expect(loc.lat, 0.0);
      expect(loc.lng, 0.0);
    });
  });
}
