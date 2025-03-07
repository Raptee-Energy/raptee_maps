import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ETACalculator {
  List<List<LatLng>>? allRoutes;
  int selectedRouteIndex = 0;
  List<LatLng> coveredRoutePoints = [];
  double totalDistance = 0;
  double totalDuration = 0;
  DateTime initialArrivalTime = DateTime.now();

  ETACalculator();

  void initializeETAData(
      List<List<LatLng>> routes, int routeIndex, List<Map<String, dynamic>> routeDetails) {
    allRoutes = routes;
    selectedRouteIndex = routeIndex;
    if (routeDetails.isNotEmpty) {
      totalDistance = (routeDetails[selectedRouteIndex]['distance'] as double) / 1000;
      totalDuration = (routeDetails[selectedRouteIndex]['duration'] as double) / 60;
      initialArrivalTime = DateTime.now().add(Duration(minutes: totalDuration.toInt()));
    } else if (allRoutes != null && allRoutes!.isNotEmpty) {
      _calculateTotalRouteDistanceAndDuration();
    }
    coveredRoutePoints = []; // Reset covered route when new route starts
  }

  void _calculateTotalRouteDistanceAndDuration() {
    totalDistance = 0;
    totalDuration = 0;
    if (allRoutes != null && allRoutes!.isNotEmpty) {
      final currentRoute = allRoutes![selectedRouteIndex];
      for (int i = 0; i < currentRoute.length - 1; i++) {
        totalDistance += Geolocator.distanceBetween(
            currentRoute[i].latitude,
            currentRoute[i].longitude,
            currentRoute[i + 1].latitude,
            currentRoute[i + 1].longitude);
      }

      totalDistance /= 1000;
      totalDuration = totalDistance * 2;
      initialArrivalTime = DateTime.now().add(Duration(minutes: totalDuration.toInt()));
    }
  }


  void updateCoveredRoute(List<LatLng> coveredPoints) {
    coveredRoutePoints = coveredPoints;
  }

  Map<String, String> getETAData() {
    double distanceCovered = _calculateDistanceCovered();
    double distanceRemaining = totalDistance - distanceCovered;
    double percentageCovered = totalDistance > 0 ? distanceCovered / totalDistance : 0;
    double durationRemainingMinutes = totalDuration * (1 - percentageCovered);

    DateTime currentArrivalTime = DateTime.now().add(Duration(minutes: durationRemainingMinutes.toInt()));
    String arrivalTimeFormatted = DateFormat('hh:mm a').format(currentArrivalTime);


    return {
      'arrivalTime': arrivalTimeFormatted,
      'distanceRemaining': '${distanceRemaining.toStringAsFixed(1)} km',
      'durationRemaining': '${durationRemainingMinutes.toStringAsFixed(0)} mins',
    };
  }


  double _calculateDistanceCovered() {
    double coveredDistance = 0;
    if (coveredRoutePoints.length > 1) {
      for (int i = 0; i < coveredRoutePoints.length - 1; i++) {
        coveredDistance += Geolocator.distanceBetween(
          coveredRoutePoints[i].latitude,
          coveredRoutePoints[i].longitude,
          coveredRoutePoints[i + 1].latitude,
          coveredRoutePoints[i + 1].longitude,
        );
      }
    }
    return coveredDistance / 1000;
  }
}