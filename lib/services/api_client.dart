import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final dynamic data;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Injectable HTTP client for tests. When null, a new `http.Client` is used.
  static http.Client? debugClient;

  http.Client get _client => debugClient ?? http.Client();

  Future<void>? _refreshing;

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await TokenStorage.access();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.access();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> _refreshAccessToken() async {
    // Avoid parallel refresh attempts.
    if (_refreshing != null) {
      await _refreshing;
      return true;
    }
    final completer = Completer<void>();
    _refreshing = completer.future;
    try {
      final refresh = await TokenStorage.refresh();
      if (refresh == null || refresh.isEmpty) return false;
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/token/refresh/');
      final resp = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh': refresh}),
          )
          .timeout(ApiConfig.timeout);
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final newAccess = data['access']?.toString();
      if (newAccess == null || newAccess.isEmpty) return false;
      final newRefresh = data['refresh']?.toString() ?? refresh;
      await TokenStorage.save(
        access: newAccess,
        refresh: newRefresh,
        user: await TokenStorage.user(),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      completer.complete();
      _refreshing = null;
    }
  }

  Future<http.Response> _sendJson(
    String method,
    Uri uri, {
    Object? body,
  }) async {
    http.Response resp;
    final client = _client;
    switch (method) {
      case 'GET':
        resp = await client
            .get(uri, headers: await _jsonHeaders())
            .timeout(ApiConfig.timeout);
        break;
      case 'POST':
        resp = await client
            .post(uri, headers: await _jsonHeaders(), body: body)
            .timeout(ApiConfig.timeout);
        break;
      case 'PATCH':
        resp = await client
            .patch(uri, headers: await _jsonHeaders(), body: body)
            .timeout(ApiConfig.timeout);
        break;
      case 'PUT':
        resp = await client
            .put(uri, headers: await _jsonHeaders(), body: body)
            .timeout(ApiConfig.timeout);
        break;
      case 'DELETE':
        resp = await client
            .delete(uri, headers: await _jsonHeaders())
            .timeout(ApiConfig.timeout);
        break;
      default:
        throw ArgumentError('Unsupported method $method');
    }
    if (resp.statusCode == 401 && await _refreshAccessToken()) {
      return _sendJson(method, uri, body: body);
    }
    return resp;
  }

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await _sendJson('GET', uri);
    return _decode(resp);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await _sendJson('POST', uri, body: jsonEncode(body));
    return _decode(resp);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await _sendJson('PATCH', uri, body: jsonEncode(body));
    return _decode(resp);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await _sendJson('PUT', uri, body: jsonEncode(body));
    return _decode(resp);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final resp = await _sendJson('DELETE', uri);
    if (resp.statusCode == 204) return null;
    return _decode(resp);
  }

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, File> files = const {},
    String method = 'POST',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    Future<http.Response> doRequest() async {
      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(await _authHeaders());
      fields.forEach((k, v) => request.fields[k] = v);
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }
      final streamed =
          await _client.send(request).timeout(ApiConfig.timeout);
      return http.Response.fromStream(streamed);
    }

    http.Response resp = await doRequest();
    if (resp.statusCode == 401 && await _refreshAccessToken()) {
      resp = await doRequest();
    }
    if (resp.statusCode == 204) return null;
    return _decode(resp);
  }

  Future<dynamic> patchMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, File> files = const {},
  }) =>
      postMultipart(path, fields: fields, files: files, method: 'PATCH');

  dynamic _decode(http.Response resp) {
    final ok = resp.statusCode >= 200 && resp.statusCode < 300;
    dynamic data;
    try {
      data = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    } catch (_) {
      data = resp.body;
    }
    if (!ok) {
      String message = 'HTTP ${resp.statusCode}';
      if (data is Map) {
        if (data['detail'] is String) {
          message = data['detail'] as String;
        } else {
          for (final entry in data.entries) {
            final v = entry.value;
            if (v is List && v.isNotEmpty) {
              message = '${entry.key}: ${v.first}';
              break;
            }
            if (v is String) {
              message = '${entry.key}: $v';
              break;
            }
          }
        }
      }
      throw ApiException(message, statusCode: resp.statusCode, data: data);
    }
    return data;
  }
}
