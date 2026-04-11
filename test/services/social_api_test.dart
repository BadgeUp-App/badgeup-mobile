import 'dart:convert';

import 'package:badgeup_mobile/models/friend_request.dart';
import 'package:badgeup_mobile/services/api_client.dart';
import 'package:badgeup_mobile/services/social_api.dart';
import 'package:badgeup_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorage.save(access: 'acc', refresh: 'ref');
  });

  tearDown(() {
    ApiClient.debugClient = null;
  });

  group('SocialApi.fetchMembers', () {
    test('parses members list', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/friends/members/'), true);
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'username': 'fer',
              'first_name': 'Fernando',
              'relationship_status': 'friends',
              'friend_request_id': 42,
            },
            {
              'id': 2,
              'username': 'anon',
              'relationship_status': 'none',
            },
          ]),
          200,
        );
      });
      final members = await SocialApi.instance.fetchMembers();
      expect(members.length, 2);
      expect(members[0].isFriend, true);
      expect(members[0].friendRequestId, 42);
      expect(members[1].isFriend, false);
    });
  });

  group('SocialApi.fetchFriendRequests', () {
    test('passes scope query parameter', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.query, contains('scope=incoming'));
        expect(req.url.query, contains('status=pending'));
        return http.Response(jsonEncode([]), 200);
      });
      final reqs = await SocialApi.instance.fetchFriendRequests(scope: 'incoming');
      expect(reqs, isEmpty);
    });

    test('parses pending requests', () async {
      ApiClient.debugClient = MockClient((req) async {
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'status': 'pending',
              'from_user': {'id': 5, 'username': 'fer'},
              'to_user': {'id': 6, 'username': 'luis'},
            }
          ]),
          200,
        );
      });
      final reqs = await SocialApi.instance.fetchFriendRequests();
      expect(reqs.length, 1);
      expect(reqs.first.status, FriendRequestStatus.pending);
    });
  });

  group('SocialApi friend request actions', () {
    test('sendFriendRequest posts to_user', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/friends/requests/'), true);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['to_user'], 99);
        return http.Response(
          jsonEncode({
            'id': 1,
            'status': 'pending',
            'from_user': {'id': 1, 'username': 'me'},
            'to_user': {'id': 99, 'username': 'them'},
          }),
          201,
        );
      });
      final req = await SocialApi.instance.sendFriendRequest(99);
      expect(req.id, 1);
    });

    test('acceptFriendRequest posts to accept endpoint', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/friends/requests/5/accept/'), true);
        return http.Response(
          jsonEncode({
            'id': 5,
            'status': 'accepted',
            'from_user': {'id': 1, 'username': 'a'},
            'to_user': {'id': 2, 'username': 'b'},
          }),
          200,
        );
      });
      final req = await SocialApi.instance.acceptFriendRequest(5);
      expect(req.status, FriendRequestStatus.accepted);
    });

    test('rejectFriendRequest posts to reject endpoint', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/friends/requests/5/reject/'), true);
        return http.Response(
          jsonEncode({
            'id': 5,
            'status': 'rejected',
            'from_user': {'id': 1, 'username': 'a'},
            'to_user': {'id': 2, 'username': 'b'},
          }),
          200,
        );
      });
      final req = await SocialApi.instance.rejectFriendRequest(5);
      expect(req.status, FriendRequestStatus.rejected);
    });

    test('cancelFriendRequest hits cancel endpoint', () async {
      var called = false;
      ApiClient.debugClient = MockClient((req) async {
        called = true;
        expect(req.url.path.endsWith('/friends/requests/5/cancel/'), true);
        return http.Response('{}', 200);
      });
      await SocialApi.instance.cancelFriendRequest(5);
      expect(called, true);
    });

    test('removeFriend hits remove endpoint', () async {
      var called = false;
      ApiClient.debugClient = MockClient((req) async {
        called = true;
        expect(req.url.path.endsWith('/friends/5/remove/'), true);
        return http.Response('{}', 200);
      });
      await SocialApi.instance.removeFriend(5);
      expect(called, true);
    });
  });

  group('SocialApi chat', () {
    test('fetchChatMessages sorts chronologically', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.url.path.endsWith('/chat/7/'), true);
        expect(req.url.query, contains('limit=50'));
        return http.Response(
          jsonEncode([
            {
              'id': 2,
              'sender_id': 1,
              'recipient_id': 7,
              'text': 'b',
              'created_at': '2026-04-10T10:00:00Z',
            },
            {
              'id': 1,
              'sender_id': 7,
              'recipient_id': 1,
              'text': 'a',
              'created_at': '2026-04-10T09:00:00Z',
            }
          ]),
          200,
        );
      });
      final msgs = await SocialApi.instance.fetchChatMessages(7);
      expect(msgs.length, 2);
      expect(msgs.first.text, 'a');
      expect(msgs.last.text, 'b');
    });

    test('sendChatMessage posts text', () async {
      ApiClient.debugClient = MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path.endsWith('/chat/7/'), true);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['text'], 'hola');
        return http.Response(
          jsonEncode({
            'id': 10,
            'sender_id': 1,
            'recipient_id': 7,
            'text': 'hola',
            'created_at': '2026-04-10T09:30:00Z',
          }),
          201,
        );
      });
      final msg = await SocialApi.instance.sendChatMessage(
        otherId: 7,
        text: 'hola',
      );
      expect(msg.id, 10);
      expect(msg.text, 'hola');
    });
  });
}
