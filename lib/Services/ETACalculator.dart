import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

//// TODO: When Idle, the ETA Logic rebuild does not happen. Make it rebuild each minute.

class ETACalculator {
  List<List<LatLng>>? allRoutes;
  int selectedRouteIndex = 0;
  List<LatLng> coveredRoutePoints = [];
  double totalDistance = 0;
  double totalDuration = 0;
  DateTime startTime = DateTime.now();
  double initialTotalDuration = 0;
  double lastDistanceCovered = 0;
  DateTime lastUpdateTime = DateTime.now();

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
    lastDistanceCovered = 0;
    lastUpdateTime = DateTime.now();
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

    if (totalDistance <= 0) {
      remainingDurationMinutes = 0;
    } else if (distanceCovered >= totalDistance) {
      remainingDurationMinutes = 0; // Already reached, no time remaining
    } else {
      double currentSpeed = 0;
      double timeDiffInMinutes =
          now.difference(lastUpdateTime).inMinutes.toDouble();
      double distanceDiff = distanceCovered - lastDistanceCovered;

      if (timeDiffInMinutes > 0) {
        currentSpeed = distanceDiff / timeDiffInMinutes; // km per minute
      }

      if (currentSpeed > 0) {
        remainingDurationMinutes = distanceRemaining / currentSpeed;
      } else {
        // If speed is 0 or negative, recalculate based on initial total duration and remaining distance
        remainingDurationMinutes =
            (distanceRemaining / totalDistance) * initialTotalDuration;
      }

      // Adjust ETA to be realistic and avoid negative or illogical values
      if (elapsedMinutes > initialTotalDuration) {
        remainingDurationMinutes =
            initialTotalDuration; // Stuck for too long, reset to initial. Consider more sophisticated logic.
      }
    }

    remainingDurationMinutes =
        remainingDurationMinutes.clamp(0, initialTotalDuration * 2);

    DateTime currentArrivalTime =
        now.add(Duration(minutes: remainingDurationMinutes.ceil()));

    // Ensure arrival time is never in the past
    if (currentArrivalTime.isBefore(now)) {
      currentArrivalTime = now.add(const Duration(
          minutes: 1)); // Add a minute to be safe, or more sophisticated logic
      remainingDurationMinutes =
          currentArrivalTime.difference(now).inMinutes.toDouble();
    }

    //Correct the Math to avoid time mismatch issues:
    remainingDurationMinutes =
        (currentArrivalTime.difference(now).inMinutes).toDouble();

    lastDistanceCovered = distanceCovered;
    lastUpdateTime = now;

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
