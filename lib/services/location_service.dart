import 'package:geolocator/geolocator.dart';

import 'preferences_service.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<Position?> getCurrentPosition() async {
    final gpsOn = await PreferencesService.instance.gpsEnabled;
    if (!gpsOn) return null;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
