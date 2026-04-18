import 'dart:io';

import '../models/album.dart';
import '../models/capture_entry.dart';
import '../models/sticker.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'content_cache.dart';

class MatchPhotoResult {
  final bool unlocked;
  final bool alreadyUnlocked;
  final bool photoAdded;
  final String message;
  final double matchScore;
  final String? stickerName;
  final int? stickerId;
  final String? funFact;
  final String? detectedItem;
  final String? detectedCategory;
  final int? albumId;
  final String? albumTitle;
  final String? carMake;
  final String? carModel;
  final Sticker? sticker;

  const MatchPhotoResult({
    required this.unlocked,
    required this.alreadyUnlocked,
    required this.photoAdded,
    required this.message,
    required this.matchScore,
    required this.stickerName,
    required this.stickerId,
    required this.funFact,
    required this.detectedItem,
    required this.detectedCategory,
    required this.albumId,
    required this.albumTitle,
    required this.carMake,
    required this.carModel,
    required this.sticker,
  });

  factory MatchPhotoResult.fromJson(Map<String, dynamic> json) {
    final stickerJson = json['sticker'];
    Sticker? sticker;
    String? name;
    int? id;
    if (stickerJson is Map<String, dynamic>) {
      sticker = Sticker.fromJson(stickerJson);
      name = sticker.name;
      id = sticker.id;
    }
    final car = (json['car'] is Map) ? json['car'] as Map : const {};
    final score = json['match_score'];
    return MatchPhotoResult(
      unlocked: json['unlocked'] == true,
      alreadyUnlocked: json['already_unlocked'] == true,
      photoAdded: json['photo_added'] == true,
      message: (json['message'] ?? '').toString(),
      matchScore: score is num ? score.toDouble() : 0.0,
      stickerName: name,
      stickerId: id,
      funFact: json['fun_fact']?.toString(),
      detectedItem: json['detected_item']?.toString(),
      detectedCategory: json['detected_category']?.toString(),
      albumId: json['album_id'] is int ? json['album_id'] as int : null,
      albumTitle: json['album_title']?.toString(),
      carMake: car['make']?.toString(),
      carModel: car['model']?.toString(),
      sticker: sticker,
    );
  }
}

class ContentApi {
  ContentApi._();
  static final ContentApi instance = ContentApi._();

  final _cache = ContentCache.instance;

  Album? getCachedDetail(int id) => _cache.detail(id);

  void clearCache() => _cache.clear();

  // ---------- Albums ----------

  Future<List<Album>> fetchAlbums({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.albums;
      if (cached != null) return cached;
    }
    final data = await ApiClient.instance.get('/albums/');
    final list = _asList(data);
    final albums = list
        .whereType<Map<String, dynamic>>()
        .map(Album.fromJson)
        .toList();
    _cache.albums = albums;
    return albums;
  }

  Future<Album> fetchAlbumDetail(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.detail(id);
      if (cached != null) return cached;
    }
    final data = await ApiClient.instance.get('/albums/$id/');
    if (data is Map<String, dynamic>) {
      final album = Album.fromJson(data);
      _cache.setDetail(album);
      return album;
    }
    throw StateError('Album response no valida.');
  }

  Future<List<Sticker>> fetchAlbumStickers(int albumId) async {
    final album = await fetchAlbumDetail(albumId);
    return album.stickers;
  }

  Future<Album> createAlbum({
    required String title,
    required String description,
    required String theme,
    bool isPremium = false,
    double? price,
    File? coverImage,
  }) async {
    final fields = <String, String>{
      'title': title,
      'description': description,
      'theme': theme,
      'is_premium': isPremium ? 'true' : 'false',
      if (price != null) 'price': price.toStringAsFixed(2),
    };
    final files = <String, File>{
      if (coverImage != null) 'cover_image': coverImage,
    };
    final data = await ApiClient.instance.postMultipart(
      '/albums/',
      fields: fields,
      files: files,
    );
    if (data is Map<String, dynamic>) {
      _cache.albums = null;
      return Album.fromJson(data);
    }
    throw StateError('No se pudo crear el album.');
  }

  Future<Album> updateAlbum({
    required int id,
    String? title,
    String? description,
    String? theme,
    bool? isPremium,
    double? price,
    File? coverImage,
  }) async {
    final fields = <String, String>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (theme != null) 'theme': theme,
      if (isPremium != null) 'is_premium': isPremium ? 'true' : 'false',
      if (price != null) 'price': price.toStringAsFixed(2),
    };
    final files = <String, File>{
      if (coverImage != null) 'cover_image': coverImage,
    };
    final data = await ApiClient.instance.patchMultipart(
      '/albums/$id/',
      fields: fields,
      files: files,
    );
    if (data is Map<String, dynamic>) {
      _cache.invalidateAlbum(id);
      return Album.fromJson(data);
    }
    throw StateError('No se pudo actualizar el album.');
  }

  // ---------- Stickers ----------

  Future<Sticker> createSticker({
    required int albumId,
    required String name,
    required String description,
    required String rarity,
    int points = 0,
    int order = 0,
    double? lat,
    double? lng,
    File? image,
  }) async {
    final fields = <String, String>{
      'album': albumId.toString(),
      'name': name,
      'description': description,
      'rarity': rarity,
      'reward_points': points.toString(),
      'order': order.toString(),
      if (lat != null) 'location_lat': lat.toString(),
      if (lng != null) 'location_lng': lng.toString(),
    };
    final files = <String, File>{
      if (image != null) 'image_reference': image,
    };
    final data = await ApiClient.instance.postMultipart(
      '/stickers/',
      fields: fields,
      files: files,
    );
    if (data is Map<String, dynamic>) return Sticker.fromJson(data);
    throw StateError('No se pudo crear el sticker.');
  }

  Future<Sticker> updateSticker({
    required int id,
    String? name,
    String? description,
    String? rarity,
    int? points,
    int? order,
    File? image,
  }) async {
    final fields = <String, String>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (rarity != null) 'rarity': rarity,
      if (points != null) 'reward_points': points.toString(),
      if (order != null) 'order': order.toString(),
    };
    final files = <String, File>{
      if (image != null) 'image_reference': image,
    };
    final data = await ApiClient.instance.patchMultipart(
      '/stickers/$id/',
      fields: fields,
      files: files,
    );
    if (data is Map<String, dynamic>) return Sticker.fromJson(data);
    throw StateError('No se pudo actualizar el sticker.');
  }

  Future<Sticker> fetchStickerDetail(int id) async {
    final data = await ApiClient.instance.get('/stickers/$id/');
    if (data is Map<String, dynamic>) return Sticker.fromJson(data);
    throw StateError('Sticker response no valida.');
  }

  Future<Sticker> setStickerMessage({
    required int stickerId,
    required String message,
  }) async {
    final data = await ApiClient.instance.post(
      '/stickers/$stickerId/message/',
      {'message': message},
    );
    if (data is Map<String, dynamic>) return Sticker.fromJson(data);
    throw StateError('No se pudo guardar el mensaje.');
  }

  // ---------- Capture / Unlock ----------

  Future<Map<String, dynamic>> unlockSticker({
    required int stickerId,
    required File photo,
    String? comment,
  }) async {
    final fields = <String, String>{
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final data = await ApiClient.instance.postMultipart(
      '/stickers/$stickerId/unlock/',
      fields: fields,
      files: {'photo': photo},
    );
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<MatchPhotoResult> matchAlbumPhoto({
    required int albumId,
    required File photo,
    double? lat,
    double? lng,
  }) async {
    final fields = <String, String>{
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
    };
    final data = await ApiClient.instance.postMultipart(
      '/albums/$albumId/match-photo/',
      fields: fields,
      files: {'photo': photo},
    );
    if (data is Map<String, dynamic>) return MatchPhotoResult.fromJson(data);
    throw StateError('Respuesta de IA invalida.');
  }

  Future<MatchPhotoResult> scanPhoto({
    required File photo,
    double? lat,
    double? lng,
  }) async {
    final fields = <String, String>{
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
    };
    final data = await ApiClient.instance.postMultipart(
      '/scan/',
      fields: fields,
      files: {'photo': photo},
    );
    if (data is Map<String, dynamic>) return MatchPhotoResult.fromJson(data);
    throw StateError('Respuesta de scan invalida.');
  }

  Future<List<CaptureEntry>> fetchCaptureHistory() async {
    final data = await ApiClient.instance.get('/captures/history/');
    final list = _asList(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CaptureEntry.fromJson)
        .toList();
  }

  Future<List<StickerLocationEntry>> fetchStickerLocations() async {
    final data = await ApiClient.instance.get('/stickers/locations/');
    final list = _asList(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(StickerLocationEntry.fromJson)
        .toList();
  }

  // ---------- Social shared ----------

  Future<List<RankingEntry>> fetchLeaderboard({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.leaderboard;
      if (cached != null) return cached;
    }
    final data = await ApiClient.instance.get('/auth/leaderboard/?limit=$limit');
    final list = _asList(data);
    final out = <RankingEntry>[];
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map<String, dynamic>) {
        out.add(RankingEntry.fromJson(item, i + 1));
      }
    }
    _cache.leaderboard = out;
    return out;
  }

  Future<List<Friend>> fetchFriends({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.friends;
      if (cached != null) return cached;
    }
    final data = await ApiClient.instance.get('/friends/');
    final list = _asList(data);
    final friends = list
        .whereType<Map<String, dynamic>>()
        .map(Friend.fromJson)
        .toList();
    _cache.friends = friends;
    return friends;
  }

  Future<UserProfile> fetchPublicProfile(int userId) async {
    final data = await ApiClient.instance.get('/auth/users/$userId/');
    if (data is Map<String, dynamic>) return UserProfile.fromJson(data);
    throw StateError('Respuesta de perfil invalida.');
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List;
    }
    return const [];
  }
}
