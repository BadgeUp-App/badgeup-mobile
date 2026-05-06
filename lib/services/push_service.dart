import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  String? _lastSentToken;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    if (Platform.isIOS) {
      await _fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    const androidChannel = AndroidNotificationChannel(
      'badgeup_default',
      'BadgeUp',
      description: 'Notificaciones de stickers desbloqueados',
      importance: Importance.high,
    );

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
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _fm.onTokenRefresh.listen(_uploadToken);
  }

  Future<void> registerWithBackend() async {
    if (!_initialized) await init();
    try {
      final token = await _fm.getToken();
      if (token == null || token.isEmpty) return;
      await _uploadToken(token);
    } catch (e) {
      if (kDebugMode) print('PushService.registerWithBackend error: $e');
    }
  }

  Future<void> unregister() async {
    _lastSentToken = null;
    try {
      await ApiClient.instance.delete('/auth/device-token/');
    } catch (_) {}
    try {
      await _fm.deleteToken();
    } catch (_) {}
  }

  Future<void> _uploadToken(String token) async {
    if (token.isEmpty || token == _lastSentToken) return;
    try {
      await ApiClient.instance.post(
        '/auth/device-token/',
        {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      _lastSentToken = token;
    } catch (e) {
      if (kDebugMode) print('PushService.uploadToken error: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'badgeup_default',
          'BadgeUp',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
