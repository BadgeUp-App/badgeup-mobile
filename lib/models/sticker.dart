enum Rarity { comun, raro, epico, legendario }

Rarity rarityFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'legendary':
    case 'legendario':
      return Rarity.legendario;
    case 'epic':
    case 'epico':
      return Rarity.epico;
    case 'rare':
    case 'raro':
      return Rarity.raro;
    default:
      return Rarity.comun;
  }
}

class CapturePhotoEntry {
  final int id;
  final String url;
  final String? capturedAt;

  const CapturePhotoEntry({
    required this.id,
    required this.url,
    this.capturedAt,
  });

  factory CapturePhotoEntry.fromJson(Map<String, dynamic> json) {
    return CapturePhotoEntry(
      id: _asInt(json['id']),
      url: (json['url'] ?? '').toString(),
      capturedAt: json['captured_at']?.toString(),
    );
  }
}

class Sticker {
  final int id;
  final String name;
  final String description;
  final Rarity rarity;
  final int points;
  final bool unlocked;
  final String imageUrl;
  final String? unlockedPhotoUrl;
  final List<CapturePhotoEntry> capturePhotos;
  final String? funFact;
  final String? userMessage;
  final String? captureDate;
  final String? captureLocation;
  final String? albumTitle;
  final int? albumId;

  const Sticker({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.points,
    this.unlocked = false,
    required this.imageUrl,
    this.unlockedPhotoUrl,
    this.capturePhotos = const [],
    this.funFact,
    this.userMessage,
    this.captureDate,
    this.captureLocation,
    this.albumTitle,
    this.albumId,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    final photosJson = json['capture_photos'];
    final List<CapturePhotoEntry> photos = photosJson is List
        ? photosJson
            .whereType<Map<String, dynamic>>()
            .map(CapturePhotoEntry.fromJson)
            .toList()
        : const [];
    return Sticker(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rarity: rarityFromString(json['rarity']?.toString()),
      points: _asInt(json['reward_points']),
      unlocked: json['is_unlocked'] == true,
      imageUrl: (json['image'] ?? json['image_reference'] ?? '').toString(),
      unlockedPhotoUrl: json['unlocked_photo_url']?.toString(),
      capturePhotos: photos,
      funFact: json['fun_fact']?.toString(),
      userMessage: json['user_message']?.toString(),
      captureDate: json['unlocked_at']?.toString(),
      captureLocation: json['location_label']?.toString(),
      albumTitle: json['album_title']?.toString(),
      albumId: json['album_id'] is int ? json['album_id'] as int : null,
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
