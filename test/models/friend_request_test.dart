import 'package:badgeup_mobile/models/friend_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FriendRequestUser.fromJson', () {
    test('builds display name from first_name + last_name', () {
      final user = FriendRequestUser.fromJson({
        'id': 1,
        'username': 'fercar',
        'first_name': 'Fernando',
        'last_name': 'Chavez',
        'computed_points': 250,
        'avatar': 'https://cdn/a.png',
      });
      expect(user.id, 1);
      expect(user.displayName, 'Fernando Chavez');
      expect(user.username, 'fercar');
      expect(user.points, 250);
      expect(user.avatarUrl, 'https://cdn/a.png');
    });

    test('falls back to username when no name', () {
      final user = FriendRequestUser.fromJson({
        'id': 2,
        'username': 'anon',
      });
      expect(user.displayName, 'anon');
    });

    test('reads points fallback field', () {
      final user = FriendRequestUser.fromJson({'points': 10});
      expect(user.points, 10);
    });
  });

  group('FriendRequestModel.fromJson', () {
    test('parses pending request with both users', () {
      final req = FriendRequestModel.fromJson({
        'id': 5,
        'status': 'pending',
        'created_at': '2026-02-01T10:00:00Z',
        'from_user': {'id': 1, 'username': 'a'},
        'to_user': {'id': 2, 'username': 'b'},
      });
      expect(req.id, 5);
      expect(req.status, FriendRequestStatus.pending);
      expect(req.fromUser.id, 1);
      expect(req.toUser.id, 2);
      expect(req.createdAt!.year, 2026);
    });

    test('maps accepted and rejected statuses', () {
      final accepted = FriendRequestModel.fromJson({
        'id': 1,
        'status': 'accepted',
        'from_user': {'id': 1, 'username': 'a'},
        'to_user': {'id': 2, 'username': 'b'},
      });
      final rejected = FriendRequestModel.fromJson({
        'id': 2,
        'status': 'rejected',
        'from_user': {'id': 1, 'username': 'a'},
        'to_user': {'id': 2, 'username': 'b'},
      });
      expect(accepted.status, FriendRequestStatus.accepted);
      expect(rejected.status, FriendRequestStatus.rejected);
    });
  });

  group('Member.fromJson', () {
    test('isFriend true when relationship=friends', () {
      final m = Member.fromJson({
        'id': 1,
        'username': 'x',
        'relationship_status': 'friends',
        'friend_request_id': 99,
      });
      expect(m.isFriend, true);
      expect(m.friendRequestId, 99);
    });

    test('isFriend false for pending or none', () {
      final pending = Member.fromJson({
        'id': 1,
        'username': 'x',
        'relationship_status': 'pending_sent',
      });
      final none = Member.fromJson({'id': 1, 'username': 'x'});
      expect(pending.isFriend, false);
      expect(none.isFriend, false);
      expect(none.relationshipStatus, 'none');
      expect(none.friendRequestId, isNull);
    });
  });

  group('ChatMessageModel.fromJson', () {
    test('parses text message', () {
      final msg = ChatMessageModel.fromJson({
        'id': 10,
        'sender_id': 3,
        'recipient_id': 4,
        'text': 'hola',
        'created_at': '2026-04-10T09:30:00Z',
      });
      expect(msg.id, 10);
      expect(msg.senderId, 3);
      expect(msg.recipientId, 4);
      expect(msg.text, 'hola');
      expect(msg.fileUrl, isNull);
      expect(msg.createdAt, isNotNull);
    });

    test('handles missing text', () {
      final msg = ChatMessageModel.fromJson({});
      expect(msg.text, '');
      expect(msg.createdAt, isNull);
    });
  });
}
