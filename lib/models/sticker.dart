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

class Sticker {
  final int id;
  final String name;
  final String description;
  final Rarity rarity;
  final int points;
  final bool unlocked;
  final String imageUrl;
  final String? captureDate;
  final String? captureLocation;

  const Sticker({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.points,
    this.unlocked = false,
    required this.imageUrl,
    this.captureDate,
    this.captureLocation,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rarity: rarityFromString(json['rarity']?.toString()),
      points: _asInt(json['reward_points']),
      unlocked: json['is_unlocked'] == true,
      imageUrl: (json['image'] ?? json['image_reference'] ?? '').toString(),
      captureDate: json['unlocked_at']?.toString(),
      captureLocation: json['location_label']?.toString(),
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
