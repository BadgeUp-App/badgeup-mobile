class CaptureEntry {
  final int id;
  final int stickerId;
  final String stickerName;
  final String albumTitle;
  final DateTime? unlockedAt;

  const CaptureEntry({
    required this.id,
    required this.stickerId,
    required this.stickerName,
    required this.albumTitle,
    required this.unlockedAt,
  });

  factory CaptureEntry.fromJson(Map<String, dynamic> json) {
    final ts = json['unlocked_at']?.toString();
    return CaptureEntry(
      id: _asInt(json['id']),
      stickerId: _asInt(json['sticker_id']),
      stickerName: (json['sticker_name'] ?? '').toString(),
      albumTitle: (json['album_title'] ?? '').toString(),
      unlockedAt: ts != null && ts.isNotEmpty ? DateTime.tryParse(ts) : null,
    );
  }
}

class StickerLocationEntry {
  final int id;
  final int stickerId;
  final String stickerName;
  final String albumTitle;
  final String username;
  final double lat;
  final double lng;
  final String? rarity;
  final DateTime? unlockedAt;

  const StickerLocationEntry({
    required this.id,
    required this.stickerId,
    required this.stickerName,
    required this.albumTitle,
    required this.username,
    required this.lat,
    required this.lng,
    this.rarity,
    required this.unlockedAt,
  });

  factory StickerLocationEntry.fromJson(Map<String, dynamic> json) {
    final ts = json['unlocked_at']?.toString();
    return StickerLocationEntry(
      id: _asInt(json['id']),
      stickerId: _asInt(json['sticker_id']),
      stickerName: (json['sticker_name'] ?? '').toString(),
      albumTitle: (json['album_title'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      lat: _asDouble(json['location_lat']),
      lng: _asDouble(json['location_lng']),
      rarity: json['rarity']?.toString(),
      unlockedAt: ts != null && ts.isNotEmpty ? DateTime.tryParse(ts) : null,
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
