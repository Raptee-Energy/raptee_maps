import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Services/mapBoxDirectionService.dart';
import 'dart:math' as Math;

class NavigationController {
  final List<List<LatLng>> allRoutes;
  int selectedRouteIndex = 0;
  bool isNavigationActive = false;
  StreamSubscription<Position>? positionStreamSubscription;
  late Function(List<LatLng>) updatePolylinePoints;
  late Function(LatLng) updateCurrentLocation;
  late Function(String, String) updateTurnInstructions;
  late Function(List<LatLng>) updateCoveredPolyline;
  late Function() clearNavigation;
  final MapBoxDirectionsService directionsService;
  LatLng currentPosition = const LatLng(0, 0);
  int currentSegmentIndex = 0;

  NavigationController({
    required this.allRoutes,
    required this.directionsService,
  });

  void startNavigation() {
    isNavigationActive = true;
    updateNavigationRoute();
    startLocationUpdates();
  }

  void stopNavigation() {
    isNavigationActive = false;
    positionStreamSubscription?.cancel();
    clearNavigation();
  }

  void startLocationUpdates() {
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      LatLng rawPosition = LatLng(position.latitude, position.longitude);
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      LatLng projectedPosition = projectOnRoute(rawPosition, currentRoute);

      currentPosition = projectedPosition;
      updateCurrentLocation(currentPosition);
      updateCoveredRoute(currentPosition);

      if (isDeviationTooFar(rawPosition)) {
        reroute();
      } else {
        updateNavigationRoute();
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
    double t = ((p.longitude - start.longitude) * dx + (p.latitude - start.latitude) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    return LatLng(start.latitude + t * dy, start.longitude + t * dx);
  }

  void updateCoveredRoute(LatLng newPoint) {
    List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
    List<LatLng> coveredPart = currentRoute.sublist(0, currentSegmentIndex + 1);
    coveredPart.add(newPoint);
    updateCoveredPolyline(coveredPart);
  }

  bool isDeviationTooFar(LatLng rawPosition) {
    List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
    LatLng closestPoint = projectOnRoute(rawPosition, currentRoute);
    double distance = Geolocator.distanceBetween(
      rawPosition.latitude,
      rawPosition.longitude,
      closestPoint.latitude,
      closestPoint.longitude,
    );
    return distance > 50.0; // 50 meters threshold, adjust as needed
  }

  Future<void> reroute() async {
    LatLng destination = allRoutes[selectedRouteIndex].last;
    try {
      final directions = await directionsService.getDirections(currentPosition, destination);
      allRoutes.clear();
      for (var route in directions) {
        allRoutes.add(route['points']);
      }
      selectedRouteIndex = 0;
      currentSegmentIndex = 0;
      updateNavigationRoute();
      updateTurnInstruction();
    } catch (e) {
      print(e);
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

  Map<String, String> getTurnInstruction(LatLng current, LatLng next) {
    double bearing = getBearing(current, next);
    String instruction;

    if (bearing >= -45 && bearing < 45) {
      instruction = "Go straight";
    } else if (bearing >= 45 && bearing < 135) {
      instruction = "Turn right";
    } else if (bearing >= -135 && bearing < -45) {
      instruction = "Turn left";
    } else {
      instruction = "Turn back";
    }

    return {
      'instruction': instruction,
      'icon': getTurnIcon(instruction),
    };
  }

  String getTurnIcon(String instruction) {
    switch (instruction) {
      case 'Go straight':
        return 'assets/goStraight.png';
      case 'Turn right':
        return 'assets/turnRight.png';
      case 'Turn left':
        return 'assets/turnLeft.png';
      case 'Turn back':
        return 'assets/turnBack.png';
      default:
        return 'assets/goStraight.png';
    }
  }

  void updateTurnInstruction() {
    if (allRoutes.isNotEmpty) {
      List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
      if (currentSegmentIndex < currentRoute.length - 1) {
        Map<String, String> turnInstruction = getTurnInstruction(
          currentRoute[currentSegmentIndex],
          currentRoute[currentSegmentIndex + 1],
        );
        updateTurnInstructions(
            turnInstruction['instruction']!, turnInstruction['icon']!);
      }
    }
  }
}