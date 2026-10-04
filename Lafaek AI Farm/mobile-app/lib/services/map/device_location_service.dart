import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Why a position could not be read, in words the farmer sees.
enum LocationFailure { disabled, denied, deniedForever, unavailable }

extension LocationFailureMessage on LocationFailure {
  String get message {
    switch (this) {
      case LocationFailure.disabled:
        return 'Location is switched off on this phone. Turn it on, or tap the map to place your field.';
      case LocationFailure.denied:
        return 'Location permission was not given. Tap the map to place your field instead.';
      case LocationFailure.deniedForever:
        return 'Location is blocked for this app in Android settings. Tap the map to place your field instead.';
      case LocationFailure.unavailable:
        return 'Could not get a GPS fix. Move into the open, or tap the map to place your field.';
    }
  }
}

/// The result of asking for the phone's position.
class LocationResult {
  const LocationResult.success(this.latitude, this.longitude) : failure = null;
  const LocationResult.failed(this.failure)
      : latitude = null,
        longitude = null;

  final double? latitude;
  final double? longitude;
  final LocationFailure? failure;

  bool get ok => failure == null;
}

/// Reads the phone's GPS position for the "Use my current location" button.
///
/// Entirely optional: every screen that uses it also lets the farmer tap the
/// map, so refusing the permission costs nothing. No position is ever sent
/// anywhere — it is stored in SQLite and used to ask Open-Meteo for the
/// forecast at that point.
class DeviceLocationService {
  const DeviceLocationService();

  Future<LocationResult> current({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationFailure.disabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failed(LocationFailure.deniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.failed(LocationFailure.denied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return LocationResult.success(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('location lookup failed: $e');
      return const LocationResult.failed(LocationFailure.unavailable);
    }
  }
}
