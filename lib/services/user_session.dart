import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'api_client.dart';
import 'token_storage.dart';

class UserSession extends ChangeNotifier {
  UserSession();
  static final UserSession instance = UserSession();

  UserProfile? _user;
  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;

  void setFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _user = null;
    } else {
      _user = UserProfile.fromJson(json);
    }
    notifyListeners();
  }

  Future<void> loadFromStorage() async {
    final cached = await TokenStorage.user();
    if (cached != null) {
      _user = UserProfile.fromJson(cached);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      final data = await ApiClient.instance.get('/auth/profile/');
      if (data is Map<String, dynamic>) {
        _user = UserProfile.fromJson(data);
        await TokenStorage.save(
          access: (await TokenStorage.access()) ?? '',
          refresh: (await TokenStorage.refresh()) ?? '',
          user: data,
        );
        notifyListeners();
      }
    } catch (_) {
      // silent — keep whatever we have.
    }
  }

  Future<void> clear() async {
    _user = null;
    await TokenStorage.clear();
    notifyListeners();
  }
}
