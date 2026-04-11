import 'package:badgeup_mobile/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parses full profile', () {
      final profile = UserProfile.fromJson({
        'id': 42,
        'username': 'fer',
        'email': 'fer@badgeup.io',
        'first_name': 'Fernando',
        'last_name': 'Chavez',
        'computed_points': 420,
        'stickers_captured': 15,
        'albums_count': 3,
        'rank': 2,
        'avatar': 'https://cdn/fer.png',
        'bio': 'amo los carros',
      });
      expect(profile.id, 42);
      expect(profile.username, 'fer');
      expect(profile.displayName, 'Fernando Chavez');
      expect(profile.email, 'fer@badgeup.io');
      expect(profile.totalPoints, 420);
      expect(profile.totalStickers, 15);
      expect(profile.totalAlbums, 3);
      expect(profile.rank, 2);
      expect(profile.avatarUrl, 'https://cdn/fer.png');
      expect(profile.bio, 'amo los carros');
    });

    test('falls back to username for display name', () {
      final profile = UserProfile.fromJson({
        'id': 1,
        'username': 'anon',
      });
      expect(profile.displayName, 'anon');
    });

    test('reads points fallback field', () {
      final profile = UserProfile.fromJson({
        'id': 1,
        'username': 'a',
        'points': 99,
      });
      expect(profile.totalPoints, 99);
    });
  });

  group('RankingEntry.fromJson', () {
    test('sets rank from argument', () {
      final entry = RankingEntry.fromJson({
        'username': 'fer',
        'first_name': 'Fernando',
        'computed_points': 500,
      }, 3);
      expect(entry.rank, 3);
      expect(entry.displayName, 'Fernando');
      expect(entry.points, 500);
    });
  });

  group('Friend.fromJson', () {
    test('parses friend with full name', () {
      final friend = Friend.fromJson({
        'id': 4,
        'username': 'luis',
        'email': 'luis@test.com',
        'first_name': 'Luis',
        'last_name': 'Perez',
        'computed_points': 120,
        'avatar': 'https://cdn/luis.png',
      });
      expect(friend.id, 4);
      expect(friend.name, 'Luis Perez');
      expect(friend.email, 'luis@test.com');
      expect(friend.points, 120);
      expect(friend.avatarUrl, 'https://cdn/luis.png');
      expect(friend.isOnline, false);
    });
  });
}
