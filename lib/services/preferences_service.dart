import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  static const _keySoundEnabled = 'pref_sound_enabled';
  static const _keyGpsEnabled = 'pref_gps_enabled';

  Future<bool> get soundEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  Future<bool> get gpsEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGpsEnabled) ?? true;
  }

  Future<void> setGpsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGpsEnabled, value);
  }
}
