import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as Math;

import '../Services/mapBoxDirectionService.dart';

class NavigationController {
  List<List<LatLng>> allRoutes; // Removed final
  int selectedRouteIndex = 0;
  bool isNavigationActive = false;
  StreamSubscription<Position>? positionStreamSubscription;
  late Function(List<LatLng>) updatePolylinePoints;
  late Function(LatLng, double?) updateCurrentLocation;
  late Function(String, String) updateTurnInstructions;
  late Function(List<LatLng>) updateCoveredPolyline;
  late Function() clearNavigation;
  final MapBoxDirectionsService directionsService;
  LatLng currentPosition = const LatLng(0, 0);
  int currentSegmentIndex = 0;
  VoidCallback? onNavigationStart;
  VoidCallback? onNavigationStop;
  bool _isRerouting = false;
  double deviationThreshold =
  30.0;

  NavigationController({
    required this.allRoutes,
    required this.directionsService,
    this.onNavigationStart,
    this.onNavigationStop,
  });

  void startNavigation() {
    isNavigationActive = true;
    updateNavigationRoute();
    startLocationUpdates();
    if (onNavigationStart != null) {
      onNavigationStart!();
    }
  }

  void stopNavigation() {
    isNavigationActive = false;
    positionStreamSubscription?.cancel();
    clearNavigation();
    if (onNavigationStop != null) {
      onNavigationStop!();
    }
  }

  void startLocationUpdates() {
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      LatLng rawPosition = LatLng(position.latitude, position.longitude);
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      LatLng projectedPosition = projectOnRoute(rawPosition, currentRoute);

      currentPosition = projectedPosition;
      double bearingToNextPoint = 0.0;
      if (currentRoute.isNotEmpty &&
          currentSegmentIndex < currentRoute.length - 1) {
        bearingToNextPoint =
            getBearing(currentPosition, currentRoute[currentSegmentIndex + 1]);
      }
      updateCurrentLocation(currentPosition, bearingToNextPoint);
      updateCoveredRoute(currentPosition);

      if (isDeviationTooFar(rawPosition)) {
        if (!_isRerouting) {
          // Prevent immediate re-rerouting if already rerouting
          reroute();
        }
      } else {
        updateTurnInstruction();
      }
    });
  }

  LatLng projectOnRoute(LatLng point, List<LatLng> route) {
    double minDistance = double.infinity;
    LatLng closestPoint = route[0];
    int closestSegmentIndex = 0;

    for (int i = 0; i < route.length - 1; i++) {
      LatLng start = route[i];
      LatLng end = route[i + 1];
      LatLng projectedPoint = projectPointOnLineSegment(point, start, end);
      double distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        projectedPoint.latitude,
        projectedPoint.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = projectedPoint;
        closestSegmentIndex = i;
      }
    }
    currentSegmentIndex = closestSegmentIndex;
    return closestPoint;
  }

  LatLng projectPointOnLineSegment(LatLng p, LatLng start, LatLng end) {
    double dx = end.longitude - start.longitude;
    double dy = end.latitude - start.latitude;
    double t = ((p.longitude - start.longitude) * dx +
        (p.latitude - start.latitude) * dy) /
        (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    return LatLng(start.latitude + t * dy, start.longitude + t * dx);
  }

  void updateCoveredRoute(LatLng newPoint) {
    List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
    if (currentRoute.isEmpty) return;

    List<LatLng> coveredPart = currentRoute.sublist(
        0, Math.min(currentSegmentIndex + 1, currentRoute.length));
    coveredPart.add(newPoint);
    updateCoveredPolyline(coveredPart);
  }

  bool isDeviationTooFar(LatLng rawPosition) {
    List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
    if (currentRoute.isEmpty) return false;

    LatLng closestPoint = projectOnRoute(rawPosition, currentRoute);
    double distance = Geolocator.distanceBetween(
      rawPosition.latitude,
      rawPosition.longitude,
      closestPoint.latitude,
      closestPoint.longitude,
    );
    return distance > deviationThreshold;
  }

  Future<void> reroute() async {
    if (_isRerouting) return;

    _isRerouting = true;
    updateTurnInstructions('Rerouting...', 'assets/rerouting.png');

    LatLng destination = allRoutes[selectedRouteIndex].last;
    try {
      final directions =
      await directionsService.getDirections(currentPosition, destination);
      if (directions.isNotEmpty) {
        allRoutes.clear();
        for (var route in directions) {
          allRoutes.add(route['points']);
        }
        selectedRouteIndex = 0;
        currentSegmentIndex = 0;
        updateNavigationRoute();
        updateTurnInstruction();
      } else {
        updateTurnInstructions(
            'Rerouting failed: No route found', 'assets/error.png');
      }
      _isRerouting = false;
    } catch (e) {
      _isRerouting = false;
      updateTurnInstructions('Error rerouting', 'assets/error.png');
      print('Rerouting error: $e');
    }
  }

  void updateNavigationRoute() {
    if (allRoutes.isNotEmpty && isNavigationActive) {
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      updatePolylinePoints(currentRoute);
    }
  }

  double getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (Math.pi / 180.0);
    double lat2 = end.latitude * (Math.pi / 180.0);
    double diffLong = (end.longitude - start.longitude) * (Math.pi / 180.0);

    double x = Math.sin(diffLong) * Math.cos(lat2);
    double y = Math.cos(lat1) * Math.sin(lat2) -
        (Math.sin(lat1) * Math.cos(lat2) * Math.cos(diffLong));

    double initialBearing = Math.atan2(x, y) * (180.0 / Math.pi);
    return (initialBearing + 360.0) % 360.0;
  }

  Map<String, String> getTurnInstruction(List<LatLng> route, int segmentIndex) {
    if (_isRerouting) {
      return {
        'instruction': 'Rerouting...',
        'icon': 'assets/rerouting.png',
        'distance': ''
      };
    }

    if (segmentIndex >= route.length - 1) {
      LatLng destination = route.last;
      double distanceToDestination = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        destination.latitude,
        destination.longitude,
      );
      if (distanceToDestination <= 20.0) {
        return {
          'instruction': 'Destination Reached',
          'icon': 'assets/destination.png',
          'distance': 'Arrived'
        };
      } else {
        return {
          'instruction': 'Continue to Destination',
          'icon': 'assets/goStraight.png',
          'distance': '${distanceToDestination.toStringAsFixed(0)}m'
        };
      }
    }

    LatLng currentSegmentStart = route[segmentIndex];
    LatLng currentSegmentEnd = route[segmentIndex + 1];
    double bearing = getBearing(currentSegmentStart, currentSegmentEnd);
    String instruction;
    String icon;

    double distanceToNextPoint = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      currentSegmentEnd.latitude,
      currentSegmentEnd.longitude,
    );

    if (segmentIndex > 0) {
      LatLng lastSegmentEnd = route[segmentIndex - 1];
      double lastBearing = getBearing(lastSegmentEnd, currentSegmentStart);
      double angleDiff = bearing - lastBearing;

      if (angleDiff > 30) {
        instruction = "Turn right";
        icon = 'assets/turnRight.png';
      } else if (angleDiff < -30) {
        instruction = "Turn left";
        icon = 'assets/turnLeft.png';
      } else {
        instruction = "Go straight";
        icon = 'assets/goStraight.png';
      }
    } else {
      instruction = "Start Navigation";
      icon = 'assets/goStraight.png';
    }

    return {
      'instruction': instruction,
      'icon': icon,
      'distance':
      '${distanceToNextPoint.toStringAsFixed(0)}m'
    };
  }

  void updateTurnInstruction() { // Corrected method name
    if (allRoutes.isNotEmpty && isNavigationActive) {
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      if (currentSegmentIndex < currentRoute.length) {
        Map<String, String> turnInstruction = getTurnInstruction(
          currentRoute,
          currentSegmentIndex,
        );
        updateTurnInstructions(
            turnInstruction['instruction']!, turnInstruction['icon']!);
      }
    }
  }
}