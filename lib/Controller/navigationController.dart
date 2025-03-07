import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as Math;
import '../Services/ETACalculator.dart';
import '../Services/mapBoxDirectionService.dart';

typedef ETAUpdateCallback = void Function(Map<String, String> etaData);

class NavigationController {
  List<List<LatLng>> allRoutes;
  int selectedRouteIndex = 0;
  bool isNavigationActive = false;
  StreamSubscription<Position>? positionStreamSubscription;
  late Function(List<LatLng>) updatePolylinePoints;
  late Function(LatLng, double?, double?) updateCurrentLocation;
  late Function(String, String, String) updateTurnInstructions;
  late Function(List<LatLng>) updateCoveredPolyline;
  late Function() clearNavigation;
  late ETAUpdateCallback updateETA; // Add ETA update callback

  final MapBoxDirectionsService directionsService;
  final ETACalculator etaCalculator =
      ETACalculator(); // Instantiate ETACalculator
  LatLng currentPosition = const LatLng(0, 0);
  int currentSegmentIndex = 0;
  VoidCallback? onNavigationStart;
  VoidCallback? onNavigationStop;
  bool _isRerouting = false;
  double deviationThreshold = 30.0;
  double instructionDistanceThreshold = 10.0;

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

  void startNavigation(List<Map<String, dynamic>> routeDetails) {
    if (allRoutes.isEmpty) {
      print("No routes available to start navigation.");
      return;
    }
    isNavigationActive = true;
    updateNavigationRoute();
    etaCalculator.initializeETAData(allRoutes, selectedRouteIndex,
        routeDetails); // Initialize ETA Data with routeDetails
    _generateCachedInstructionsInIsolate();
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
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      LatLng rawPosition = LatLng(position.latitude, position.longitude);
      List<LatLng> currentRoute = List.from(allRoutes[selectedRouteIndex]);

      if (currentRoute.isEmpty) return;

      LatLng projectedPosition = projectOnRoute(rawPosition, currentRoute);

      currentPosition = projectedPosition;
      double bearingToNextPoint = 0.0;
      if (currentRoute.isNotEmpty &&
          currentSegmentIndex < currentRoute.length - 1) {
        bearingToNextPoint =
            getBearing(currentPosition, currentRoute[currentSegmentIndex + 1]);
      }
      double? distanceToNextInstruction = _distanceToNextInstruction();
      updateCurrentLocation(
          currentPosition, bearingToNextPoint, distanceToNextInstruction);
      updateCoveredRoute(currentPosition, currentRoute);

      if (isDeviationTooFar(rawPosition)) {
        if (!_isRerouting) {
          _debounceReroute(rawPosition);
        }
      } else {
        _cancelRerouteDebounce();
        updateTurnInstruction();
      }
    }, onError: (error) {
      print("Error in location stream: $error");
      stopNavigation();
    });
  }

  double? _distanceToNextInstruction() {
    if (cachedInstructions.isEmpty ||
        currentInstructionIndex >= cachedInstructions.length) {
      return null;
    }
    _CachedInstruction nextInstruction =
        cachedInstructions[currentInstructionIndex];
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      nextInstruction.triggerPoint.latitude,
      nextInstruction.triggerPoint.longitude,
    );
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
    if (dx == 0 && dy == 0) return start;
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
    etaCalculator.updateCoveredRoute(
        coveredPart);
  }

  bool isDeviationTooFar(LatLng rawPosition) {
    List<LatLng> currentRoute = List.from(allRoutes[selectedRouteIndex]);
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
        etaCalculator.initializeETAData(allRoutes, selectedRouteIndex,
            []); // Re-initialize ETA after reroute, you might need to pass updated routeDetails here as well if available from directions response. For now passing empty list.
        _generateCachedInstructionsInIsolate();
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

  Future<void> _generateCachedInstructionsInIsolate() async {
    cachedInstructions.clear();
    currentInstructionIndex = 0;
    if (allRoutes.isEmpty) return;
    List<LatLng> route = List.from(allRoutes[selectedRouteIndex]);

    final instructionData = _InstructionGenerationData(route: route);
    final List<_CachedInstruction> generatedInstructions =
        await compute(_generateInstructions, instructionData);
    cachedInstructions = generatedInstructions;
    updateTurnInstruction();
  }

  static List<_CachedInstruction> _generateInstructions(
      _InstructionGenerationData data) {
    List<_CachedInstruction> instructions = [];
    List<LatLng> route = data.route;

    for (int i = 0; i < route.length; i++) {
      Map<String, String> instructionMap =
          _getTurnInstructionForSegmentStatic(route, i);
      instructions.add(_CachedInstruction(
        instruction: instructionMap['instruction']!,
        icon: instructionMap['icon']!,
        triggerPoint: (i < route.length - 1) ? route[i + 1] : route.last,
        segmentIndex: i,
      ));
    }
    if (route.isNotEmpty) {
      instructions.add(_CachedInstruction(
        instruction: 'Destination Reached',
        icon: 'assets/destination.png',
        triggerPoint: route.last,
        segmentIndex: route.length - 1,
      ));
    }
    return instructions;
  }

  static Map<String, String> _getTurnInstructionForSegmentStatic(
      List<LatLng> route, int segmentIndex) {
    if (segmentIndex >= route.length - 1) {
      return {
        'instruction': 'Destination Reached',
        'icon': 'assets/destination.png',
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
          _getStaticBearing(lastSegmentStart, currentSegmentStart);
      double currentSegmentBearing =
          _getStaticBearing(currentSegmentStart, currentSegmentEnd);
      double angleDiff = currentSegmentBearing - lastSegmentBearing;
      angleDiff = ((angleDiff + 180) % 360) - 180;

      if (angleDiff.abs() < 20) {
        instruction = "Go straight";
        icon = 'assets/goStraight.png';
      } else if (angleDiff > 135 || angleDiff < -135) {
        instruction = "Make U-Turn";
        icon = 'assets/turnBack.png';
      } else if (angleDiff > 45) {
        instruction = "Turn right";
        icon = 'assets/turnRight.png';
      } else if (angleDiff < -45) {
        instruction = "Turn left";
        icon = 'assets/turnLeft.png';
      }
    } else {
      instruction = "Start Navigation";
      icon = 'assets/goStraight.png';
    }

    return {
      'instruction': instruction,
      'icon': icon,
      'distance': '',
    };
  }

  static double _getStaticBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (Math.pi / 180.0);
    double lat2 = end.latitude * (Math.pi / 180.0);
    double diffLong = (end.longitude - start.longitude) * (Math.pi / 180.0);

    double x = Math.sin(diffLong) * Math.cos(lat2);
    double y = Math.cos(lat1) * Math.sin(lat2) -
        (Math.sin(lat1) * Math.cos(lat2) * Math.cos(diffLong));

    double initialBearing = Math.atan2(x, y) * (180.0 / Math.pi);
    return (initialBearing + 360.0) % 360.0;
  }

  void updateTurnInstruction() {
    if (allRoutes.isNotEmpty && isNavigationActive) {
      if (cachedInstructions.isEmpty) return;

      _CachedInstruction? nextInstruction;
      bool instructionUpdated = false;

      while (currentInstructionIndex < cachedInstructions.length) {
        _CachedInstruction instruction =
            cachedInstructions[currentInstructionIndex];
        double distanceToTrigger = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          instruction.triggerPoint.latitude,
          instruction.triggerPoint.longitude,
        );

        if (distanceToTrigger <= instructionDistanceThreshold) {
          nextInstruction = instruction;
          currentInstructionIndex++;
          instructionUpdated = true;

          if (nextInstruction.instruction == 'Destination Reached') {
            updateTurnInstructions(
                nextInstruction.instruction, nextInstruction.icon, '');
            updateETA(etaCalculator.getETAData());
            return;
          }
        } else {
          break;
        }
      }

      if (nextInstruction != null && instructionUpdated) {
        String distanceText = '';
        double distanceToInstruction = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          nextInstruction.triggerPoint.latitude,
          nextInstruction.triggerPoint.longitude,
        );
        if (nextInstruction.instruction != 'Destination Reached') {
          distanceText = '${distanceToInstruction.toStringAsFixed(0)}m';
        }

        updateTurnInstructions(
            nextInstruction.instruction, nextInstruction.icon, distanceText);
        updateETA(etaCalculator
            .getETAData()); // Update ETA whenever turn instruction changes
      } else {
        if (cachedInstructions.isNotEmpty &&
            currentInstructionIndex >= cachedInstructions.length) {
          updateTurnInstructions(
              'Destination Reached', 'assets/destination.png', '');
          updateETA(
              etaCalculator.getETAData());
        } else {
          updateTurnInstructions('Go straight', 'assets/goStraight.png', '');
          updateETA(etaCalculator
              .getETAData());
        }
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

class _InstructionGenerationData {
  final List<LatLng> route;
  _InstructionGenerationData({required this.route});
}
