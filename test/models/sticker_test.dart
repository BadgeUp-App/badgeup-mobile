import 'package:badgeup_mobile/models/sticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rarityFromString', () {
    test('handles spanish and english variants', () {
      expect(rarityFromString('comun'), Rarity.comun);
      expect(rarityFromString('common'), Rarity.comun);
      expect(rarityFromString('raro'), Rarity.raro);
      expect(rarityFromString('rare'), Rarity.raro);
      expect(rarityFromString('epico'), Rarity.epico);
      expect(rarityFromString('epic'), Rarity.epico);
      expect(rarityFromString('legendario'), Rarity.legendario);
      expect(rarityFromString('legendary'), Rarity.legendario);
    });

    test('defaults unknown values to comun', () {
      expect(rarityFromString(null), Rarity.comun);
      expect(rarityFromString(''), Rarity.comun);
      expect(rarityFromString('random'), Rarity.comun);
    });

    test('is case insensitive', () {
      expect(rarityFromString('LEGENDARIO'), Rarity.legendario);
      expect(rarityFromString('Epic'), Rarity.epico);
    });
  });

  group('Sticker.fromJson', () {
    test('parses all fields', () {
      final sticker = Sticker.fromJson({
        'id': 42,
        'name': 'Porsche 911',
        'description': 'Alemana icónica',
        'rarity': 'legendario',
        'reward_points': 150,
        'is_unlocked': true,
        'image_reference': 'https://cdn/porsche.png',
        'unlocked_at': '2026-01-01T12:00:00Z',
        'location_label': 'Guadalajara',
      });
      expect(sticker.id, 42);
      expect(sticker.name, 'Porsche 911');
      expect(sticker.description, 'Alemana icónica');
      expect(sticker.rarity, Rarity.legendario);
      expect(sticker.points, 150);
      expect(sticker.unlocked, true);
      expect(sticker.imageUrl, 'https://cdn/porsche.png');
      expect(sticker.captureDate, '2026-01-01T12:00:00Z');
      expect(sticker.captureLocation, 'Guadalajara');
    });

    test('handles missing image_reference with image field', () {
      final sticker = Sticker.fromJson({
        'id': 1,
        'name': 'A',
        'image': 'https://cdn/a.png',
      });
      expect(sticker.imageUrl, 'https://cdn/a.png');
    });

    test('parses points from string', () {
      final sticker = Sticker.fromJson({
        'id': 1,
        'name': 'A',
        'reward_points': '99',
      });
      expect(sticker.points, 99);
    });

    test('defaults unknowns gracefully', () {
      final sticker = Sticker.fromJson({});
      expect(sticker.id, 0);
      expect(sticker.name, '');
      expect(sticker.rarity, Rarity.comun);
      expect(sticker.points, 0);
      expect(sticker.unlocked, false);
      expect(sticker.imageUrl, '');
    });
  });
}
