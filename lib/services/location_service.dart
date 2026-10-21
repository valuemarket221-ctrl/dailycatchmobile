import 'package:geolocator/geolocator.dart';
import 'package:myapp/demo/demo_mode.dart';

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

  Future<LocationResult> resolveCurrentLocation({
    bool requestPermission = false,
  }) async {
    if (DemoMode.enabled) {
      return const LocationResult(
        latitude: 52.5200,
        longitude: 13.4050,
        label: 'Berlin, Allemagne (demo)',
        isFallback: true,
      );
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallback(warning: 'GPS désactivé: résultats autour de Dakar.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
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

      final cached = await _lastKnownPositionSafely();
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
    } catch (_) {
      final cached = await _lastKnownPositionSafely();
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
        warning: 'Localisation indisponible: résultats autour de Dakar.',
      );
    }
  }

  Future<Position?> _lastKnownPositionSafely() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
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
