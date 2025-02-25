import 'package:latlong2/latlong.dart';

class MapConfig {
  static const LatLng initialMapCenter = LatLng(22, 74);
  static const double initialMapZoom = 13.0;
  static const double minZoom = 0;
  static const double maxZoom = 20;
  static const String tileLayerUrlTemplate = 'https://maps.raptee.com/styles/test-style/{z}/{x}/{y}.png';

  static double getZoomLevelForDistance(double distanceInKm) {
    if (distanceInKm < 0.5) {
      return 16;
    } else if (distanceInKm < 1) {
      return 15;
    } else if (distanceInKm < 5) {
      return 14;
    } else if (distanceInKm < 10) {
      return 13;
    } else if (distanceInKm < 20) {
      return 12;
    } else if (distanceInKm < 50) {
      return 11;
    } else if (distanceInKm < 100) {
      return 10;
    } else if (distanceInKm < 200) {
      return 9;
    } else {
      return 7;
    }
  }
}