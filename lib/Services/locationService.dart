import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationServiceStatus {
  enabled,
  disabled,
  permissionGranted,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationService {
  Future<LocationServiceStatus> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationServiceStatus.disabled;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationServiceStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationServiceStatus.permissionDeniedForever;
    }

    return LocationServiceStatus.permissionGranted;
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null; // Or consider throwing an exception with more context
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}
