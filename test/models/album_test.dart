import 'package:badgeup_mobile/models/album.dart';
import 'package:badgeup_mobile/models/sticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Album.fromJson', () {
    test('parses basic fields', () {
      final album = Album.fromJson({
        'id': 7,
        'title': 'Clasicos',
        'theme': 'Deportivos',
        'description': 'Autos legendarios',
        'is_premium': true,
        'price': '49.99',
        'cover_image': 'https://cdn/img.png',
        'stickers_count': 12,
      });

      expect(album.id, 7);
      expect(album.title, 'Clasicos');
      expect(album.theme, 'Deportivos');
      expect(album.description, 'Autos legendarios');
      expect(album.isPremium, true);
      expect(album.price, 49.99);
      expect(album.coverUrl, 'https://cdn/img.png');
      expect(album.stickers, isEmpty);
      expect(album.totalCount, 12);
      expect(album.unlockedCount, 0);
      expect(album.progress, 0);
    });

    test('falls back to defaults when fields missing', () {
      final album = Album.fromJson({});
      expect(album.id, 0);
      expect(album.title, '');
      expect(album.theme, '');
      expect(album.description, '');
      expect(album.isPremium, false);
      expect(album.price, isNull);
      expect(album.coverUrl, '');
      expect(album.stickers, isEmpty);
      expect(album.totalCount, 0);
      expect(album.progress, 0);
    });

    test('computes progress from nested stickers', () {
      final album = Album.fromJson({
        'id': 1,
        'title': 'Test',
        'stickers': [
          {
            'id': 1,
            'name': 'A',
            'rarity': 'comun',
            'reward_points': 10,
            'is_unlocked': true,
          },
          {
            'id': 2,
            'name': 'B',
            'rarity': 'raro',
            'reward_points': 20,
            'is_unlocked': false,
          },
          {
            'id': 3,
            'name': 'C',
            'rarity': 'epico',
            'reward_points': 30,
            'is_unlocked': true,
          },
        ],
      });

      expect(album.stickers.length, 3);
      expect(album.totalCount, 3);
      expect(album.unlockedCount, 2);
      expect(album.progress, closeTo(2 / 3, 1e-9));
      expect(album.stickers.first.rarity, Rarity.comun);
    });

    test('parses numeric price', () {
      final album = Album.fromJson({'price': 19.5});
      expect(album.price, 19.5);
    });

    test('ignores invalid price string', () {
      final album = Album.fromJson({'price': 'abc'});
      expect(album.price, isNull);
    });
  });
}
