enum FriendRequestStatus { pending, accepted, rejected }

FriendRequestStatus _statusFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'accepted':
      return FriendRequestStatus.accepted;
    case 'rejected':
      return FriendRequestStatus.rejected;
    default:
      return FriendRequestStatus.pending;
  }
}

class FriendRequestUser {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int points;

  const FriendRequestUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.points,
  });

  factory FriendRequestUser.fromJson(Map<String, dynamic> json) {
    final first = (json['first_name'] ?? '').toString().trim();
    final last = (json['last_name'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    final display = full.isNotEmpty ? full : (json['username'] ?? '').toString();
    return FriendRequestUser(
      id: _asInt(json['id']),
      username: (json['username'] ?? '').toString(),
      displayName: display,
      avatarUrl: json['avatar']?.toString(),
      points: _asInt(json['computed_points'] ?? json['points']),
    );
  }
}

class FriendRequestModel {
  final int id;
  final FriendRequestUser fromUser;
  final FriendRequestUser toUser;
  final FriendRequestStatus status;
  final DateTime? createdAt;

  const FriendRequestModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    final created = json['created_at']?.toString();
    return FriendRequestModel(
      id: _asInt(json['id']),
      fromUser: FriendRequestUser.fromJson(
        (json['from_user'] ?? const <String, dynamic>{}) as Map<String, dynamic>,
      ),
      toUser: FriendRequestUser.fromJson(
        (json['to_user'] ?? const <String, dynamic>{}) as Map<String, dynamic>,
      ),
      status: _statusFromString(json['status']?.toString()),
      createdAt:
          created != null && created.isNotEmpty ? DateTime.tryParse(created) : null,
    );
  }
}

class Member {
  final int id;
  final String username;
  final String displayName;
  final String email;
  final int points;
  final String? avatarUrl;
  final String relationshipStatus;
  final int? friendRequestId;

  const Member({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.points,
    required this.avatarUrl,
    required this.relationshipStatus,
    required this.friendRequestId,
  });

  bool get isFriend => relationshipStatus == 'friends';

  factory Member.fromJson(Map<String, dynamic> json) {
    final first = (json['first_name'] ?? '').toString().trim();
    final last = (json['last_name'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    final display = full.isNotEmpty ? full : (json['username'] ?? '').toString();
    final rel = (json['relationship_status'] ?? 'none').toString();
    return Member(
      id: _asInt(json['id']),
      username: (json['username'] ?? '').toString(),
      displayName: display,
      email: (json['email'] ?? '').toString(),
      points: _asInt(json['computed_points'] ?? json['points']),
      avatarUrl: json['avatar']?.toString(),
      relationshipStatus: rel,
      friendRequestId:
          json['friend_request_id'] == null ? null : _asInt(json['friend_request_id']),
    );
  }
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final int recipientId;
  final String text;
  final String? fileUrl;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.fileUrl,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final ts = json['created_at']?.toString();
    return ChatMessageModel(
      id: _asInt(json['id']),
      senderId: _asInt(json['sender_id']),
      recipientId: _asInt(json['recipient_id']),
      text: (json['text'] ?? '').toString(),
      fileUrl: json['file_url']?.toString(),
      createdAt: ts != null && ts.isNotEmpty ? DateTime.tryParse(ts) : null,
    );
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
