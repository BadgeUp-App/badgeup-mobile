import 'sticker.dart';

class Album {
  final int id;
  final String title;
  final String theme;
  final String description;
  final bool isPremium;
  final double? price;
  final String coverUrl;
  final List<Sticker> stickers;
  final int stickersCount;

  const Album({
    required this.id,
    required this.title,
    required this.theme,
    required this.description,
    this.isPremium = false,
    this.price,
    required this.coverUrl,
    this.stickers = const [],
    this.stickersCount = 0,
  });

  int get unlockedCount => stickers.where((s) => s.unlocked).length;
  int get totalCount => stickers.isEmpty ? stickersCount : stickers.length;
  double get progress => totalCount > 0 ? unlockedCount / totalCount : 0;

  factory Album.fromJson(Map<String, dynamic> json) {
    final stickersJson = json['stickers'];
    final List<Sticker> stickers = stickersJson is List
        ? stickersJson
            .whereType<Map<String, dynamic>>()
            .map(Sticker.fromJson)
            .toList()
        : const [];
    double? price;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice);
    }
    return Album(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '').toString(),
      theme: (json['theme'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isPremium: json['is_premium'] == true,
      price: price,
      coverUrl: (json['cover_image'] ?? '').toString(),
      stickers: stickers,
      stickersCount: (json['stickers_count'] ?? stickers.length) is int
          ? (json['stickers_count'] ?? stickers.length) as int
          : int.tryParse('${json['stickers_count']}') ?? stickers.length,
    );
  }
}
