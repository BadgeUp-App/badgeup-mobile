import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'token_storage.dart';
import 'user_session.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthResult {
  AuthResult({required this.access, required this.refresh, this.user});
  final String access;
  final String refresh;
  final Map<String, dynamic>? user;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _google = GoogleSignIn(
    scopes: const ['email', 'profile', 'openid'],
  );

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(ApiConfig.timeout);

    if (resp.statusCode != 200) {
      throw AuthException(_extractError(resp, fallback: 'Credenciales invalidas.'));
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = AuthResult(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null,
    );
    await TokenStorage.save(
      access: result.access,
      refresh: result.refresh,
      user: result.user,
    );
    UserSession.instance.setFromJson(result.user);
    return result;
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String firstName = '',
    String lastName = '',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'password_confirm': passwordConfirm,
            'first_name': firstName,
            'last_name': lastName,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (resp.statusCode != 201) {
      throw AuthException(_extractError(resp, fallback: 'No se pudo crear la cuenta.'));
    }

    // Backend returns the user but not tokens, so log in right after.
    return login(username: username, password: password);
  }

  Future<AuthResult> signInWithGoogle() async {
    GoogleSignInAccount? account;
    try {
      account = await _google.signIn();
    } catch (e) {
      throw AuthException('Error iniciando Google: $e');
    }
    if (account == null) {
      throw AuthException('Inicio de sesion con Google cancelado.');
    }

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      throw AuthException('No se obtuvo token de Google.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/google/mobile/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'access_token': accessToken}),
        )
        .timeout(ApiConfig.timeout);

    if (resp.statusCode != 200) {
      throw AuthException(
        _extractError(resp, fallback: 'El servidor rechazo Google.'),
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = AuthResult(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null,
    );
    await TokenStorage.save(
      access: result.access,
      refresh: result.refresh,
      user: result.user,
    );
    UserSession.instance.setFromJson(result.user);
    return result;
  }

  Future<void> logout() async {
    try {
      await _google.signOut();
    } catch (_) {}
    await UserSession.instance.clear();
  }

  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? bio,
    File? avatar,
    bool resetAvatar = false,
  }) async {
    final fields = <String, String>{
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (resetAvatar) 'reset_avatar': 'true',
    };
    final files = <String, File>{
      if (avatar != null) 'avatar': avatar,
    };

    dynamic data;
    if (files.isNotEmpty) {
      data = await ApiClient.instance.patchMultipart(
        '/auth/profile/',
        fields: fields,
        files: files,
      );
    } else {
      data = await ApiClient.instance.patch('/auth/profile/', fields);
    }

    if (data is! Map<String, dynamic>) {
      throw AuthException('Respuesta de perfil invalida.');
    }
    final profile = UserProfile.fromJson(data);
    await TokenStorage.save(
      access: (await TokenStorage.access()) ?? '',
      refresh: (await TokenStorage.refresh()) ?? '',
      user: data,
    );
    UserSession.instance.setFromJson(data);
    return profile;
  }

  String _extractError(http.Response resp, {required String fallback}) {
    try {
      final data = jsonDecode(resp.body);
      if (data is Map) {
        if (data['detail'] is String) return data['detail'] as String;
        // Collect the first list of errors we find.
        for (final entry in data.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) return '${entry.key}: ${v.first}';
          if (v is String) return '${entry.key}: $v';
        }
      }
    } catch (_) {}
    return fallback;
  }
}
