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

  const Album({
    required this.id,
    required this.title,
    required this.theme,
    required this.description,
    this.isPremium = false,
    this.price,
    required this.coverUrl,
    required this.stickers,
  });

  int get unlockedCount => stickers.where((s) => s.unlocked).length;
  int get totalCount => stickers.length;
  double get progress => totalCount > 0 ? unlockedCount / totalCount : 0;
}
