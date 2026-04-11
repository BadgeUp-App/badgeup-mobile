class UserProfile {
  final int id;
  final String username;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final int totalPoints;
  final int totalStickers;
  final int totalAlbums;
  final int rank;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.totalPoints,
    required this.totalStickers,
    required this.totalAlbums,
    required this.rank,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final first = (json['first_name'] ?? '').toString().trim();
    final last = (json['last_name'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    final display = full.isNotEmpty
        ? full
        : (json['username'] ?? '').toString();
    return UserProfile(
      id: (json['id'] ?? 0) as int,
      username: (json['username'] ?? '').toString(),
      displayName: display,
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      totalPoints: _asInt(json['computed_points'] ?? json['points']),
      totalStickers: _asInt(json['stickers_captured']),
      totalAlbums: _asInt(json['albums_count']),
      rank: _asInt(json['rank']),
    );
  }
}

class RankingEntry {
  final int rank;
  final String displayName;
  final String username;
  final int points;

  const RankingEntry({
    required this.rank,
    required this.displayName,
    required this.username,
    required this.points,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json, int rank) {
    final first = (json['first_name'] ?? '').toString().trim();
    final last = (json['last_name'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    final display =
        full.isNotEmpty ? full : (json['username'] ?? '').toString();
    return RankingEntry(
      rank: rank,
      displayName: display,
      username: (json['username'] ?? '').toString(),
      points: _asInt(json['computed_points'] ?? json['points']),
    );
  }
}

class Friend {
  final int id;
  final String name;
  final String email;
  final int points;
  final String? avatarUrl;
  final bool isOnline;

  const Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    this.avatarUrl,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    final first = (json['first_name'] ?? '').toString().trim();
    final last = (json['last_name'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    final display =
        full.isNotEmpty ? full : (json['username'] ?? '').toString();
    return Friend(
      id: _asInt(json['id']),
      name: display,
      email: (json['email'] ?? '').toString(),
      points: _asInt(json['computed_points'] ?? json['points']),
      avatarUrl: json['avatar']?.toString(),
      isOnline: false,
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
