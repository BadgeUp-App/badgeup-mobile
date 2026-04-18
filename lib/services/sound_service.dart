import 'package:flutter/services.dart';

import 'preferences_service.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  Future<void> playUnlockSound() async {
    final enabled = await PreferencesService.instance.soundEnabled;
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
