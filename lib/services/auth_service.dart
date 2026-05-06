import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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

  FirebaseAuth get _firebase => FirebaseAuth.instance;

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final email = username.trim();
    try {
      await _firebase.signOut();
    } catch (_) {}

    UserCredential cred;
    try {
      cred = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseErrorToMessage(e));
    } catch (e) {
      throw AuthException('Error al iniciar sesion: $e');
    }

    final idToken = await cred.user?.getIdToken();
    if (idToken == null) {
      throw AuthException('Firebase no devolvio un token.');
    }
    return _exchangeFirebaseToken(idToken);
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String firstName = '',
    String lastName = '',
  }) async {
    if (password != passwordConfirm) {
      throw AuthException('Las contrasenas no coinciden.');
    }
    try {
      await _firebase.signOut();
    } catch (_) {}

    UserCredential cred;
    try {
      cred = await _firebase.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseErrorToMessage(e));
    } catch (e) {
      throw AuthException('Error al crear la cuenta: $e');
    }

    final displayName = [firstName, lastName]
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (displayName.isNotEmpty) {
      try {
        await cred.user?.updateDisplayName(displayName);
        await cred.user?.reload();
      } catch (_) {}
    }

    final idToken = await _firebase.currentUser?.getIdToken(true);
    if (idToken == null) {
      throw AuthException('Firebase no devolvio un token despues de registrar.');
    }
    return _exchangeFirebaseToken(idToken);
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      try {
        await _google.signOut();
      } catch (_) {}

      GoogleSignInAccount? account;
      try {
        account = await _google.signIn();
      } catch (e) {
        throw AuthException('Error iniciando Google: $e');
      }
      if (account == null) {
        throw AuthException('Inicio de sesion con Google cancelado.');
      }

      final gAuth = await account.authentication;
      if (gAuth.idToken == null) {
        throw AuthException('Google no devolvio idToken. Revisa la config del client ID.');
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      try {
        await _firebase.signOut();
      } catch (_) {}

      UserCredential cred;
      try {
        cred = await _firebase.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        throw AuthException(_firebaseErrorToMessage(e));
      } catch (e) {
        throw AuthException('Firebase rechazo las credenciales de Google: $e');
      }

      final idToken = await cred.user?.getIdToken();
      if (idToken == null) {
        throw AuthException('Firebase no devolvio un token.');
      }
      return await _exchangeFirebaseToken(idToken);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google login fallo: $e');
    }
  }

  Future<AuthResult> _exchangeFirebaseToken(String idToken) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/firebase/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_token': idToken}),
        )
        .timeout(ApiConfig.timeout);

    if (resp.statusCode != 200) {
      throw AuthException(
        _extractError(resp, fallback: 'El servidor rechazo el token de Firebase.'),
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

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es valido.';
      case 'user-disabled':
        return 'La cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya tiene una cuenta.';
      case 'weak-password':
        return 'La contrasena es demasiado debil (minimo 6 caracteres).';
      case 'network-request-failed':
        return 'Sin conexion. Intenta de nuevo.';
      default:
        return e.message ?? 'Error de autenticacion (${e.code}).';
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(ApiConfig.timeout);

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['detail'] as String? ?? 'Solicitud enviada.';
  }

  Future<String> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/confirm/');
    final resp = await (ApiClient.debugClient ?? http.Client())
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'code': code,
            'new_password': newPassword,
          }),
        )
        .timeout(ApiConfig.timeout);

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw AuthException(data['detail'] as String? ?? 'Error al cambiar contrasena.');
    }
    return data['detail'] as String? ?? 'Contrasena actualizada.';
  }

  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final data = await ApiClient.instance.post('/auth/change-password/', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    if (data is Map<String, dynamic>) {
      return data['detail'] as String? ?? 'Contrasena actualizada.';
    }
    return 'Contrasena actualizada.';
  }

  Future<void> logout() async {
    try {
      await _google.signOut();
    } catch (_) {}
    try {
      await _firebase.signOut();
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
