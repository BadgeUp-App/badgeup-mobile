import '../models/friend_request.dart';
import 'api_client.dart';

class SocialApi {
  SocialApi._();
  static final SocialApi instance = SocialApi._();

  // ---------- Members / community ----------

  Future<List<Member>> fetchMembers() async {
    final data = await ApiClient.instance.get('/friends/members/');
    final list = _asList(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Member.fromJson)
        .toList();
  }

  // ---------- Friend requests ----------

  Future<List<FriendRequestModel>> fetchFriendRequests({String scope = 'all'}) async {
    final data =
        await ApiClient.instance.get('/friends/requests/?scope=$scope&status=pending');
    final list = _asList(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(FriendRequestModel.fromJson)
        .toList();
  }

  Future<FriendRequestModel> sendFriendRequest(int toUserId) async {
    final data = await ApiClient.instance.post(
      '/friends/requests/',
      {'to_user': toUserId},
    );
    if (data is Map<String, dynamic>) return FriendRequestModel.fromJson(data);
    throw StateError('No se pudo enviar la solicitud.');
  }

  Future<FriendRequestModel> acceptFriendRequest(int requestId) async {
    final data = await ApiClient.instance.post('/friends/requests/$requestId/accept/', {});
    if (data is Map<String, dynamic>) return FriendRequestModel.fromJson(data);
    throw StateError('No se pudo aceptar la solicitud.');
  }

  Future<FriendRequestModel> rejectFriendRequest(int requestId) async {
    final data = await ApiClient.instance.post('/friends/requests/$requestId/reject/', {});
    if (data is Map<String, dynamic>) return FriendRequestModel.fromJson(data);
    throw StateError('No se pudo rechazar la solicitud.');
  }

  Future<void> cancelFriendRequest(int requestId) async {
    await ApiClient.instance.post('/friends/requests/$requestId/cancel/', {});
  }

  Future<void> removeFriend(int requestId) async {
    await ApiClient.instance.post('/friends/$requestId/remove/', {});
  }

  // ---------- Chat ----------

  Future<List<ChatMessageModel>> fetchChatMessages(int otherId, {int limit = 50}) async {
    final data =
        await ApiClient.instance.get('/chat/$otherId/?limit=$limit');
    final list = _asList(data);
    final out = list
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageModel.fromJson)
        .toList();
    out.sort((a, b) {
      final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return da.compareTo(db);
    });
    return out;
  }

  Future<ChatMessageModel> sendChatMessage({
    required int otherId,
    required String text,
  }) async {
    final data =
        await ApiClient.instance.post('/chat/$otherId/', {'text': text});
    if (data is Map<String, dynamic>) return ChatMessageModel.fromJson(data);
    throw StateError('No se pudo enviar el mensaje.');
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List;
    }
    return const [];
  }
}
