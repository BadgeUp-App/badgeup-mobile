class UserProfile {
  final String username;
  final String displayName;
  final String email;
  final int totalPoints;
  final int totalStickers;
  final int totalAlbums;
  final int rank;

  const UserProfile({
    required this.username,
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.totalStickers,
    required this.totalAlbums,
    required this.rank,
  });
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
}

class Friend {
  final String name;
  final String email;
  final int points;
  final bool isOnline;

  const Friend({
    required this.name,
    required this.email,
    required this.points,
    required this.isOnline,
  });
}
