enum Rarity { comun, raro, epico, legendario }

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
}
