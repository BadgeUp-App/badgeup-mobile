import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class AroaErrors {
  static String? _key;
  static String _endpoint = 'https://internal.aroagroup.com/api/errors/ingest';
  static String _release = 'dev';
  static String _environment = 'dev';
  static String? _userHash;
  static bool _enabled = false;
  static final List<Map<String, dynamic>> _breadcrumbs = <Map<String, dynamic>>[];

  static void init({
    required String ingestKey,
    String release = 'dev',
    String environment = 'dev',
    String? endpoint,
  }) {
    _key = ingestKey.isEmpty ? null : ingestKey;
    _release = release;
    _environment = environment;
    if (endpoint != null && endpoint.isNotEmpty) _endpoint = endpoint;
    _enabled = _key != null;

    final prevFlutter = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      prevFlutter?.call(details);
      capture(details.exception, details.stack, level: 'error');
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      capture(error, stack, level: 'fatal');
      return true;
    };
  }

  static void setUser(String? userHash) => _userHash = userHash;

  static void addBreadcrumb(String message, {String? category}) {
    _breadcrumbs.add(<String, dynamic>{
      'message': message,
      if (category != null) 'category': category,
      'ts': DateTime.now().toUtc().toIso8601String(),
    });
    if (_breadcrumbs.length > 25) _breadcrumbs.removeAt(0);
  }

  static Future<void> guard(FutureOr<void> Function() body) async {
    await runZonedGuarded(() async {
      await body();
    }, (Object error, StackTrace stack) {
      capture(error, stack, level: 'fatal');
    });
  }

  @visibleForTesting
  static Map<String, dynamic> buildPayload(
    Object error,
    StackTrace? stack, {
    String level = 'error',
  }) {
    return <String, dynamic>{
      'exception_type': error.runtimeType.toString(),
      'message': error.toString(),
      'stack_trace': (stack ?? StackTrace.current).toString(),
      'level': level,
      'release': _release,
      'environment': _environment,
      'platform_meta': _platformMeta(),
      if (_userHash != null) 'user_hash': _userHash,
      if (_breadcrumbs.isNotEmpty)
        'breadcrumbs': List<Map<String, dynamic>>.from(_breadcrumbs),
    };
  }

  static Future<void> capture(
    Object error,
    StackTrace? stack, {
    String level = 'error',
  }) async {
    if (!_enabled || _key == null) return;
    await _post(buildPayload(error, stack, level: level));
  }

  static Map<String, dynamic> _platformMeta() {
    return <String, dynamic>{
      'os': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'app_version': _release,
      'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
      'dart_mode': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
    };
  }

  static Future<void> _post(Map<String, dynamic> payload) async {
    final key = _key;
    if (key == null) return;
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set('x-aroa-ingest-key', key);
      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(const Duration(seconds: 6));
      await response.drain<void>();
      client.close();
    } catch (_) {
      // el reporter nunca debe tirar la app
    }
  }
}
