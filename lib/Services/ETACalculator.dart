import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  Timer? _periodicUpdateTimer;
  Function()? _onETAUpdated;

  ETACalculator() {
    _startPeriodicUpdates();
  }

  void setETAUpdateCallback(Function() callback) {
    _onETAUpdated = callback;
  }

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

    _resetPeriodicUpdates();
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

    _resetPeriodicUpdates();

    if (_onETAUpdated != null) {
      _onETAUpdated!();
    }
  }

  Map<String, String> getETAData() {
    final distanceCovered = _calculateDistanceCovered();
    final distanceRemaining =
        (totalDistance - distanceCovered).clamp(0, double.infinity);
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    elapsed.inMinutes.toDouble();

    double remainingDurationMinutes;

    if (totalDistance <= 0) {
      remainingDurationMinutes = 0;
    } else if (distanceCovered >= totalDistance) {
      remainingDurationMinutes = 0;
    } else {
      double currentSpeed = 0;
      final timeDiffInMinutes =
          now.difference(lastUpdateTime).inMinutes.toDouble();
      final distanceDiff = distanceCovered - lastDistanceCovered;

      if (timeDiffInMinutes > 0) {
        currentSpeed = distanceDiff / timeDiffInMinutes;
      }

      if (currentSpeed > 0) {
        remainingDurationMinutes = distanceRemaining / currentSpeed;
      } else {
        remainingDurationMinutes =
            (distanceRemaining / totalDistance) * initialTotalDuration;
      }

      remainingDurationMinutes =
          remainingDurationMinutes.clamp(0, initialTotalDuration * 2);
    }

    final DateTime currentArrivalTime =
        now.add(Duration(minutes: remainingDurationMinutes.ceil()));

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

  void _startPeriodicUpdates() {
    _periodicUpdateTimer?.cancel();

    _periodicUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      print('***************** UPDATING ETA *****************');
      if (_onETAUpdated != null) {
        _onETAUpdated!();
      }
    });
  }

  void _resetPeriodicUpdates() {
    _startPeriodicUpdates();
  }

  void dispose() {
    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = null;
  }
}
