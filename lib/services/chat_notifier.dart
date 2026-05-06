import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'token_storage.dart';

class ChatNotifier {
  ChatNotifier._();
  static final ChatNotifier instance = ChatNotifier._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int _lastSeenId = 0;
  bool _suppressed = false;
  int? _activeChatPeer;
  bool _seeded = false;
  bool _initialized = false;

  void suppressFor(int peerId) {
    _suppressed = true;
    _activeChatPeer = peerId;
  }

  void resume() {
    _suppressed = false;
    _activeChatPeer = null;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: initAndroid, iOS: initIOS),
    );
    if (Platform.isIOS) {
      await _local
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _initialized = true;
  }

  Future<void> start() async {
    if (_timer != null) return;
    await _ensureInitialized();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
    _poll();
  }

  Future<void> testNotification() async {
    await _ensureInitialized();
    await _show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Notificacion de prueba',
      'Si ves esto es que las notifs locales jalan.',
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _lastSeenId = 0;
    _seeded = false;
  }

  Future<void> _poll() async {
    if (await TokenStorage.access() == null) return;
    try {
      final query = _seeded ? '?since_id=$_lastSeenId' : '';
      final data = await ApiClient.instance.get('/chat/inbox/recent/$query');
      if (data is! List) return;
      if (data.isEmpty) {
        _seeded = true;
        return;
      }

      var maxId = _lastSeenId;
      for (final item in data) {
        if (item is! Map) continue;
        final id = (item['id'] as num?)?.toInt() ?? 0;
        if (id > maxId) maxId = id;
      }

      if (!_seeded) {
        _lastSeenId = maxId;
        _seeded = true;
        return;
      }

      for (final item in data) {
        if (item is! Map) continue;
        final id = (item['id'] as num?)?.toInt() ?? 0;
        if (id <= _lastSeenId) continue;
        final senderId = (item['sender_id'] as num?)?.toInt();
        if (_suppressed && senderId != null && senderId == _activeChatPeer) {
          continue;
        }
        final senderName = (item['sender_username'] as String?) ??
            (senderId != null ? 'Usuario $senderId' : 'Nuevo mensaje');
        final text = (item['text'] as String?) ?? '';
        await _show(id, senderName, text.isEmpty ? 'Te envio un archivo' : text);
      }
      _lastSeenId = maxId;
    } catch (_) {}
  }

  Future<void> _show(int id, String title, String body) async {
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'badgeup_default',
          'BadgeUp',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }
}
