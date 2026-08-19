import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.isFallback,
    this.warning,
  });

  final double latitude;
  final double longitude;
  final String label;
  final bool isFallback;
  final String? warning;
}

class LocationService {
  static const dakarLatitude = 14.6928;
  static const dakarLongitude = -17.4467;

  Future<LocationResult> resolveCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _fallback(warning: 'GPS désactivé: résultats autour de Dakar.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return _fallback(
        warning:
            'Localisation bloquée: activez-la dans les paramètres pour voir les paniers proches.',
      );
    }

    if (permission == LocationPermission.denied) {
      return _fallback(
        warning: 'Localisation refusée: résultats autour de Dakar.',
      );
    }

    final cached = await Geolocator.getLastKnownPosition();
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Autour de vous',
        isFallback: false,
      );
    } catch (_) {
      if (cached != null) {
        return LocationResult(
          latitude: cached.latitude,
          longitude: cached.longitude,
          label: 'Dernière position connue',
          isFallback: true,
          warning: 'GPS indisponible: dernière position connue utilisée.',
        );
      }
      return _fallback(
        warning: 'Position indisponible: résultats autour de Dakar.',
      );
    }
  }

  LocationResult _fallback({required String warning}) {
    return LocationResult(
      latitude: dakarLatitude,
      longitude: dakarLongitude,
      label: 'Dakar, Sénégal',
      isFallback: true,
      warning: warning,
    );
  }
}
