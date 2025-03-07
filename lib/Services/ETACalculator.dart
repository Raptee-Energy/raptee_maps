import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ETACalculator {
  List<List<LatLng>>? allRoutes;
  int selectedRouteIndex = 0;
  List<LatLng> coveredRoutePoints = [];
  double totalDistance = 0;
  double totalDuration = 0; // In minutes
  DateTime startTime = DateTime.now();
  double initialTotalDuration = 0; // Initial duration estimate in minutes

  ETACalculator();

  void initializeETAData(List<List<LatLng>> routes, int routeIndex,
      List<Map<String, dynamic>> routeDetails) {
    allRoutes = routes;
    selectedRouteIndex = routeIndex;
    startTime = DateTime.now();
    if (routeDetails.isNotEmpty) {
      totalDistance =
          (routeDetails[selectedRouteIndex]['distance'] as double) / 1000;
      totalDuration =
          (routeDetails[selectedRouteIndex]['duration'] as double) / 60;
      initialTotalDuration = totalDuration;
    } else if (allRoutes != null && allRoutes!.isNotEmpty) {
      _calculateTotalRouteDistanceAndDuration();
      initialTotalDuration = totalDuration;
    }
    coveredRoutePoints = [];
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
      totalDuration = totalDistance * 2; // Fallback to 30 km/h average
      initialTotalDuration = totalDuration;
    }
  }

  void updateCoveredRoute(List<LatLng> coveredPoints) {
    coveredRoutePoints = coveredPoints;
  }

  Map<String, String> getETAData() {
    final distanceCovered = _calculateDistanceCovered();
    final distanceRemaining =
        (totalDistance - distanceCovered).clamp(0, double.infinity);
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final elapsedMinutes = elapsed.inMinutes.toDouble();

    double remainingDurationMinutes;

    if (totalDistance <= 0 || elapsedMinutes < 0) {
      remainingDurationMinutes = 0;
    } else if (distanceCovered <= 0 || elapsedMinutes == 0) {
      remainingDurationMinutes =
          totalDuration * (1 - (distanceCovered / totalDistance));
    } else {
      final expectedProgress = elapsedMinutes / initialTotalDuration;
      final actualProgress = distanceCovered / totalDistance;

      double progressRate;
      if (expectedProgress <= 0) {
        progressRate = 1.0;
      } else {
        progressRate = actualProgress / expectedProgress;
      }

      if (progressRate <= 0 || !progressRate.isFinite) {
        // Fallback to initial calculation
        remainingDurationMinutes =
            (distanceRemaining / totalDistance) * initialTotalDuration;
      } else {
        remainingDurationMinutes =
            (initialTotalDuration - elapsedMinutes) / progressRate;
      }
    }

    // Clamp values to reasonable ranges
    remainingDurationMinutes =
        remainingDurationMinutes.clamp(0, initialTotalDuration * 2);

    DateTime currentArrivalTime =
        now.add(Duration(minutes: remainingDurationMinutes.ceil()));

    // Ensure arrival time is never in the past
    if (currentArrivalTime.isBefore(now)) {
      currentArrivalTime = now.add(const Duration(minutes: 1));
    }

    return {
      'arrivalTime': DateFormat('hh:mm a').format(currentArrivalTime),
      'distanceRemaining': '${distanceRemaining.toStringAsFixed(1)} km',
      'durationRemaining': '${remainingDurationMinutes.ceil()} mins',
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
            coveredRoutePoints[i + 1].longitude);
      }
    }
    return coveredDistance / 1000;
  }
}
