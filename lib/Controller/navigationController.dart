import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as Math;

import '../Services/mapBoxDirectionService.dart';

class NavigationController {
  List<List<LatLng>> allRoutes;
  int selectedRouteIndex = 0;
  bool isNavigationActive = false;
  StreamSubscription<Position>? positionStreamSubscription;
  late Function(List<LatLng>) updatePolylinePoints;
  late Function(LatLng, double?) updateCurrentLocation;
  late Function(String, String, String) updateTurnInstructions;
  late Function(List<LatLng>) updateCoveredPolyline;
  late Function() clearNavigation;
  final MapBoxDirectionsService directionsService;
  LatLng currentPosition = const LatLng(0, 0);
  int currentSegmentIndex = 0;
  VoidCallback? onNavigationStart;
  VoidCallback? onNavigationStop;
  bool _isRerouting = false;
  double deviationThreshold = 30.0;
  double instructionDistanceThreshold = 15.0;

  List<_CachedInstruction> cachedInstructions = [];
  int currentInstructionIndex = 0;

  Timer? _rerouteTimer;
  DateTime? _lastRerouteTime;
  final Duration rerouteDebounceDuration = const Duration(seconds: 5);
  final Duration minRerouteInterval = const Duration(seconds: 15);

  NavigationController({
    required this.allRoutes,
    required this.directionsService,
    this.onNavigationStart,
    this.onNavigationStop,
  });

  void startNavigation() {
    isNavigationActive = true;
    updateNavigationRoute();
    _generateCachedInstructions();
    startLocationUpdates();
    _lastRerouteTime = null;
    if (onNavigationStart != null) {
      onNavigationStart!();
    }
  }

  void stopNavigation() {
    isNavigationActive = false;
    positionStreamSubscription?.cancel();
    clearNavigation();
    cachedInstructions.clear();
    currentInstructionIndex = 0;
    _rerouteTimer?.cancel();
    _rerouteTimer = null;
    _lastRerouteTime = null;
    if (onNavigationStop != null) {
      onNavigationStop!();
    }
  }

  void startLocationUpdates() {
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(milliseconds: 500),
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      LatLng rawPosition = LatLng(position.latitude, position.longitude);
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      if (currentRoute.isEmpty) return;

      LatLng projectedPosition = projectOnRoute(rawPosition, currentRoute);

      currentPosition = projectedPosition;
      double bearingToNextPoint = 0.0;
      if (currentRoute.isNotEmpty &&
          currentSegmentIndex < currentRoute.length - 1) {
        bearingToNextPoint =
            getBearing(currentPosition, currentRoute[currentSegmentIndex + 1]);
      }
      updateCurrentLocation(currentPosition, bearingToNextPoint);
      updateCoveredRoute(currentPosition, currentRoute);

      if (isDeviationTooFar(rawPosition)) {
        if (!_isRerouting) {
          _debounceReroute(rawPosition);
        }
      } else {
        _cancelRerouteDebounce();
        updateTurnInstruction();
      }
    });
  }

  void _debounceReroute(LatLng rawPosition) {
    if (_rerouteTimer?.isActive ?? false) return;

    _rerouteTimer = Timer(rerouteDebounceDuration, () {
      _rerouteTimer = null;
      _rerouteIfStillDeviated(rawPosition);
    });
  }

  void _cancelRerouteDebounce() {
    if (_rerouteTimer?.isActive ?? false) {
      _rerouteTimer?.cancel();
      _rerouteTimer = null;
    }
  }

  Future<void> _rerouteIfStillDeviated(LatLng rawPosition) async {
    if (isDeviationTooFar(rawPosition)) {
      final now = DateTime.now();
      if (_lastRerouteTime == null ||
          now.difference(_lastRerouteTime!) > minRerouteInterval) {
        await reroute();
        _lastRerouteTime = now;
      } else {
        print("Rerouting suppressed due to rate limiting");
      }
    }
  }

  LatLng projectOnRoute(LatLng point, List<LatLng> route) {
    if (route.isEmpty) return point;

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

  void updateCoveredRoute(LatLng newPoint, List<LatLng> currentRoute) {
    if (currentRoute.isEmpty) return;

    List<LatLng> coveredPart = [];
    if (currentRoute.isNotEmpty) {
      coveredPart = currentRoute.sublist(
          0, Math.min(currentSegmentIndex + 1, currentRoute.length));
      coveredPart.add(newPoint);
    }
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
    updateTurnInstructions('Rerouting...', 'assets/rerouting.png', '');

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
        _generateCachedInstructions();
        updateTurnInstruction();
        updateCoveredPolyline([]);
      } else {
        updateTurnInstructions(
            'Rerouting failed: No route found', 'assets/error.png', '');
      }
      _isRerouting = false;
    } catch (e) {
      _isRerouting = false;
      updateTurnInstructions('Error rerouting', 'assets/error.png', '');
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

  void _generateCachedInstructions() {
    cachedInstructions.clear();
    currentInstructionIndex = 0;
    if (allRoutes.isEmpty) return;
    List<LatLng> route = allRoutes[selectedRouteIndex];

    for (int i = 0; i < route.length; i++) {
      Map<String, String> instructionMap =
          getTurnInstructionForSegment(route, i);
      cachedInstructions.add(_CachedInstruction(
        instruction: instructionMap['instruction']!,
        icon: instructionMap['icon']!,
        triggerPoint: (i < route.length - 1) ? route[i + 1] : route.last,
        segmentIndex: i,
      ));
    }
    if (route.isNotEmpty) {
      cachedInstructions.add(_CachedInstruction(
        instruction: 'Destination Reached',
        icon: 'assets/destination.png',
        triggerPoint: route.last,
        segmentIndex: route.length - 1,
      ));
    }
  }

  Map<String, String> getTurnInstructionForSegment(
      List<LatLng> route, int segmentIndex) {
    if (_isRerouting) {
      return {
        'instruction': 'Rerouting...',
        'icon': 'assets/rerouting.png',
        'distance': ''
      };
    }

    if (segmentIndex >= route.length - 1) {
      return {
        'instruction': 'Continue to Destination',
        'icon': 'assets/goStraight.png',
        'distance': ''
      };
    }

    LatLng currentSegmentStart = route[segmentIndex];
    LatLng currentSegmentEnd = route[segmentIndex + 1];

    String instruction = "Go straight";
    String icon = 'assets/goStraight.png';

    if (segmentIndex > 0) {
      LatLng lastSegmentStart = route[segmentIndex - 1];
      double lastSegmentBearing =
          getBearing(lastSegmentStart, currentSegmentStart);
      double currentSegmentBearing =
          getBearing(currentSegmentStart, currentSegmentEnd);
      double angleDiff = currentSegmentBearing - lastSegmentBearing;
      angleDiff = ((angleDiff + 180) % 360) - 180;

      if (angleDiff > 135 || angleDiff < -135) {
        instruction = "Make U-Turn";
        icon = 'assets/turnBack.png';
      } else if (angleDiff > 25) {
        instruction = "Turn right";
        icon = 'assets/turnRight.png';
      } else if (angleDiff < -25) {
        instruction = "Turn left";
        icon = 'assets/turnLeft.png';
      } else {
        instruction = "Go straight";
        icon = 'assets/goStraight.png';
      }
    } else {
      if (route.length > 2) {
        LatLng nextSegmentEnd = route[segmentIndex + 2];
        double currentSegmentBearing =
            getBearing(currentSegmentStart, currentSegmentEnd);
        double nextSegmentBearing =
            getBearing(currentSegmentEnd, nextSegmentEnd);
        double angleDiff = nextSegmentBearing - currentSegmentBearing;
        angleDiff = ((angleDiff + 180) % 360) - 180;

        if (angleDiff > 135 || angleDiff < -135) {
          instruction = "Make U-Turn";
          icon = 'assets/turnBack.png';
        } else if (angleDiff > 25) {
          instruction = "Turn right";
          icon = 'assets/turnRight.png';
        } else if (angleDiff < -25) {
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
    }

    return {
      'instruction': instruction,
      'icon': icon,
      'distance': '',
    };
  }

  void updateTurnInstruction() {
    if (allRoutes.isNotEmpty && isNavigationActive) {
      if (cachedInstructions.isEmpty) return;

      double closestDistance = double.infinity;
      _CachedInstruction? nextInstruction;

      while (currentInstructionIndex < cachedInstructions.length) {
        _CachedInstruction instruction =
            cachedInstructions[currentInstructionIndex];
        double distanceToTrigger = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          instruction.triggerPoint.latitude,
          instruction.triggerPoint.longitude,
        );

        if (distanceToTrigger <= instructionDistanceThreshold ||
            currentInstructionIndex == 0) {
          nextInstruction = instruction;
          closestDistance = distanceToTrigger;
          currentInstructionIndex++;
          break;
        } else {
          currentInstructionIndex++;
        }
      }

      if (nextInstruction != null) {
        String distanceText = '';
        if (nextInstruction.instruction != 'Destination Reached') {
          distanceText = '${closestDistance.toStringAsFixed(0)}m';
        }

        updateTurnInstructions(
            nextInstruction.instruction, nextInstruction.icon, distanceText);
      }
    }
  }
}

class _CachedInstruction {
  String instruction;
  String icon;
  LatLng triggerPoint;
  int segmentIndex;

  _CachedInstruction({
    required this.instruction,
    required this.icon,
    required this.triggerPoint,
    required this.segmentIndex,
  });
}
