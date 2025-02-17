///TODO: OG CODE
// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import '../Services/mapBoxDirectionService.dart';
// import 'dart:math' as Math;
//
// class NavigationController {
//   final List<List<LatLng>> allRoutes;
//   int selectedRouteIndex = 0;
//   bool isNavigationActive = false;
//   StreamSubscription<Position>? positionStreamSubscription;
//   late Function(List<LatLng>) updatePolylinePoints;
//   late Function(LatLng) updateCurrentLocation;
//   late Function(String, String) updateTurnInstructions;
//   late Function(List<LatLng>) updateCoveredPolyline;
//   late Function() clearNavigation;
//   final MapBoxDirectionsService directionsService;
//   LatLng currentPosition = const LatLng(0, 0);
//   int currentSegmentIndex = 0;
//
//   NavigationController({
//     required this.allRoutes,
//     required this.directionsService,
//   });
//
//   void startNavigation() {
//     isNavigationActive = true;
//     updateNavigationRoute();
//     startLocationUpdates();
//   }
//
//   void stopNavigation() {
//     isNavigationActive = false;
//     positionStreamSubscription?.cancel();
//     clearNavigation();
//   }
//
//   void startLocationUpdates() {
//     positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 1,
//       ),
//     ).listen((Position position) {
//       LatLng rawPosition = LatLng(position.latitude, position.longitude);
//       List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
//       LatLng projectedPosition = projectOnRoute(rawPosition, currentRoute);
//
//       currentPosition = projectedPosition;
//       updateCurrentLocation(currentPosition);
//       updateCoveredRoute(currentPosition);
//
//       if (isDeviationTooFar(rawPosition)) {
//         reroute();
//       } else {
//         updateNavigationRoute();
//         updateTurnInstruction();
//       }
//     });
//   }
//
//   LatLng projectOnRoute(LatLng point, List<LatLng> route) {
//     double minDistance = double.infinity;
//     LatLng closestPoint = route[0];
//     int closestSegmentIndex = 0;
//
//     for (int i = 0; i < route.length - 1; i++) {
//       LatLng start = route[i];
//       LatLng end = route[i + 1];
//       LatLng projectedPoint = projectPointOnLineSegment(point, start, end);
//       double distance = Geolocator.distanceBetween(
//         point.latitude,
//         point.longitude,
//         projectedPoint.latitude,
//         projectedPoint.longitude,
//       );
//
//       if (distance < minDistance) {
//         minDistance = distance;
//         closestPoint = projectedPoint;
//         closestSegmentIndex = i;
//       }
//     }
//
//     currentSegmentIndex = closestSegmentIndex;
//     return closestPoint;
//   }
//
//   LatLng projectPointOnLineSegment(LatLng p, LatLng start, LatLng end) {
//     double dx = end.longitude - start.longitude;
//     double dy = end.latitude - start.latitude;
//     double t = ((p.longitude - start.longitude) * dx + (p.latitude - start.latitude) * dy) / (dx * dx + dy * dy);
//     t = t.clamp(0.0, 1.0);
//     return LatLng(start.latitude + t * dy, start.longitude + t * dx);
//   }
//
//   void updateCoveredRoute(LatLng newPoint) {
//     List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
//     List<LatLng> coveredPart = currentRoute.sublist(0, currentSegmentIndex + 1);
//     coveredPart.add(newPoint);
//     updateCoveredPolyline(coveredPart);
//   }
//
//   bool isDeviationTooFar(LatLng rawPosition) {
//     List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
//     LatLng closestPoint = projectOnRoute(rawPosition, currentRoute);
//     double distance = Geolocator.distanceBetween(
//       rawPosition.latitude,
//       rawPosition.longitude,
//       closestPoint.latitude,
//       closestPoint.longitude,
//     );
//     return distance > 50.0; // 50 meters threshold, adjust as needed
//   }
//
//   Future<void> reroute() async {
//     LatLng destination = allRoutes[selectedRouteIndex].last;
//     try {
//       final directions = await directionsService.getDirections(currentPosition, destination);
//       allRoutes.clear();
//       for (var route in directions) {
//         allRoutes.add(route['points']);
//       }
//       selectedRouteIndex = 0;
//       currentSegmentIndex = 0;
//       updateNavigationRoute();
//       updateTurnInstruction();
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void updateNavigationRoute() {
//     if (allRoutes.isNotEmpty && isNavigationActive) {
//       List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
//       updatePolylinePoints(currentRoute);
//     }
//   }
//
//   double getBearing(LatLng start, LatLng end) {
//     double lat1 = start.latitude * (Math.pi / 180.0);
//     double lat2 = end.latitude * (Math.pi / 180.0);
//     double diffLong = (end.longitude - start.longitude) * (Math.pi / 180.0);
//
//     double x = Math.sin(diffLong) * Math.cos(lat2);
//     double y = Math.cos(lat1) * Math.sin(lat2) -
//         (Math.sin(lat1) * Math.cos(lat2) * Math.cos(diffLong));
//
//     double initialBearing = Math.atan2(x, y) * (180.0 / Math.pi);
//     return (initialBearing + 360.0) % 360.0;
//   }
//
//   Map<String, String> getTurnInstruction(LatLng current, LatLng next) {
//     double bearing = getBearing(current, next);
//     String instruction;
//
//     if (bearing >= -45 && bearing < 45) {
//       instruction = "Go straight";
//     } else if (bearing >= 45 && bearing < 135) {
//       instruction = "Turn right";
//     } else if (bearing >= -135 && bearing < -45) {
//       instruction = "Turn left";
//     } else {
//       instruction = "Turn back";
//     }
//
//     return {
//       'instruction': instruction,
//       'icon': getTurnIcon(instruction),
//     };
//   }
//
//   String getTurnIcon(String instruction) {
//     switch (instruction) {
//       case 'Go straight':
//         return 'assets/goStraight.png';
//       case 'Turn right':
//         return 'assets/turnRight.png';
//       case 'Turn left':
//         return 'assets/turnLeft.png';
//       case 'Turn back':
//         return 'assets/turnBack.png';
//       default:
//         return 'assets/goStraight.png';
//     }
//   }
//
//   void updateTurnInstruction() {
//     if (allRoutes.isNotEmpty) {
//       List<LatLng> currentRoute = allRoutes[selectedRouteIndex];
//       if (currentSegmentIndex < currentRoute.length - 1) {
//         Map<String, String> turnInstruction = getTurnInstruction(
//           currentRoute[currentSegmentIndex],
//           currentRoute[currentSegmentIndex + 1],
//         );
//         updateTurnInstructions(
//             turnInstruction['instruction']!, turnInstruction['icon']!);
//       }
//     }
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Services/mapBoxDirectionService.dart';

class NavigationController {
  final MapBoxDirectionsService directionsService;
  final List<List<LatLng>> allRoutes;
  bool isNavigationActive = false;
  List<LatLng> _currentRoutePoints = [];
  List<LatLng> _coveredRoutePoints = [];
  LatLng? currentLocation;
  StreamSubscription<Position>? _locationStreamSubscription;

  // Callbacks to update MapScreen UI
  void Function(List<LatLng>)? updatePolylinePoints;
  void Function(LatLng)? updateCurrentLocation;
  VoidCallback? clearNavigation;
  void Function(String, String)? updateTurnInstructions;
  void Function(List<LatLng>)? updateCoveredPolyline;

  NavigationController({
    required this.allRoutes,
    required this.directionsService,
  });

  void startNavigation() {
    if (allRoutes.isEmpty) return;

    isNavigationActive = true;
    _currentRoutePoints = List.from(allRoutes[0]);
    updatePolylinePoints?.call(_currentRoutePoints);
    _coveredRoutePoints.clear();
    updateCoveredPolyline?.call(_coveredRoutePoints);

    _startLocationUpdates();
  }

  void stopNavigation() {
    isNavigationActive = false;
    _stopLocationUpdates();
    clearNavigation?.call();
  }

  void _startLocationUpdates() {
    _locationStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      currentLocation = LatLng(position.latitude, position.longitude);
      updateCurrentLocation?.call(currentLocation!);

      if (isNavigationActive && _currentRoutePoints.isNotEmpty) {
        _updateNavigationProgress();
      }
    });
  }

  void _stopLocationUpdates() {
    _locationStreamSubscription?.cancel();
    _locationStreamSubscription = null;
  }

  void _updateNavigationProgress() {
    if (currentLocation == null || _currentRoutePoints.isEmpty) return;

    List<LatLng> newCoveredPoints = [];
    double coveredDistance = 0;

    for (int i = 0; i < _currentRoutePoints.length - 1; i++) {
      LatLng startPoint = _currentRoutePoints[i];
      LatLng endPoint = _currentRoutePoints[i + 1];

      // Project current location onto the segment
      LatLng? projection = _projectPointOnSegment(currentLocation!, startPoint, endPoint);

      if (projection != null) {
        // If projected point is on the segment, add points up to the projection
        for(int j=0; j<=i; ++j) {
          newCoveredPoints.add(_currentRoutePoints[j]);
        }
        newCoveredPoints.add(projection); // Add the projected point

        coveredDistance = const Distance().as(LengthUnit.Meter, _currentRoutePoints[0], projection);


        // Simplified Turn Instructions (Improve with API data parsing in future)
        if (i < _currentRoutePoints.length - 2) {
          LatLng nextPoint = _currentRoutePoints[i + 2]; // Point after next segment for bearing calculation

          String instruction = "Continue Straight";
          String icon = 'assets/icons/straight.png';

          double bearingToNext = getBearing(projection, endPoint); // Bearing to end of current segment
          double bearingToFarNext = getBearing(endPoint, nextPoint); // Bearing to start of next segment
          double bearingDiff = (bearingToFarNext - bearingToNext + 360) % 360;

          if (bearingDiff > 30 && bearingDiff < 150) {
            instruction = "Turn Right";
            icon = 'assets/icons/right_turn.png';
          } else if (bearingDiff > 210 && bearingDiff < 330) {
            instruction = "Turn Left";
            icon = 'assets/icons/left_turn.png';
          }
          updateTurnInstructions?.call(instruction, icon);
        } else {
          updateTurnInstructions?.call("Destination Reached", 'assets/icons/destination.png');
        }
        break; // Stop after finding the segment with projection
      } else {
        // If no projection on this segment, the whole segment is considered covered
        newCoveredPoints.add(startPoint);
      }
    }
    _coveredRoutePoints = newCoveredPoints;
    updateCoveredPolyline?.call(_coveredRoutePoints);
  }


  LatLng? _projectPointOnSegment(LatLng point, LatLng segmentStart, LatLng segmentEnd) {
    final pLat = point.latitude, pLng = point.longitude;
    final startLat = segmentStart.latitude, startLng = segmentStart.longitude;
    final endLat = segmentEnd.latitude, endLng = segmentEnd.longitude;

    final segmentLengthSq = const Distance().as(LengthUnit.Meter, segmentStart, segmentEnd) * const Distance().as(LengthUnit.Meter, segmentStart, segmentEnd);
    if (segmentLengthSq == 0.0) return segmentStart; // Segment is a point

    double u = ((pLat - startLat) * (endLat - startLat) + (pLng - startLng) * (endLng - startLng)) / segmentLengthSq;
    if (u < 0 || u > 1) return null; // Projection is outside segment bounds

    final projLat = startLat + u * (endLat - startLat);
    final projLng = startLng + u * (endLng - startLng);
    return LatLng(projLat, projLng);
  }


  double getBearing(LatLng from, LatLng to) {
    var lat1 = degreesToRadians(from.latitude);
    var lon1 = degreesToRadians(from.longitude);
    var lat2 = degreesToRadians(to.latitude);
    var lon2 = degreesToRadians(to.longitude);

    var y = sin(lon2 - lon1) * cos(lat2);
    var x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    var bearing = radiansToDegrees(atan2(y, x));
    return bearing;
  }

  double degreesToRadians(double degrees) => degrees * pi / 180;
  double radiansToDegrees(double radians) => radians * 180 / pi;
}


