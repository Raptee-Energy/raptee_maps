import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Controller/navigationController.dart';
import '../Services/mapBoxDirectionService.dart';

class RouteDataManager {
  List<Marker> markers;
  List<LatLng> polylinePoints;
  List<List<LatLng>> allRoutes;
  List<Map<String, dynamic>> routeDetails;
  List<LatLng> coveredRoutePoints;
  List<LatLng> plannedRoutePoints;
  List<LatLng> remainingRoutePoints;
  bool isRouteSelected;
  int selectedRouteIndex;
  final void Function(VoidCallback fn) setState;
  final MapBoxDirectionsService directionsService;
  final NavigationController navigationController;


  RouteDataManager({
    required this.markers,
    required this.polylinePoints,
    required this.allRoutes,
    required this.routeDetails,
    required this.coveredRoutePoints,
    required this.plannedRoutePoints,
    required this.remainingRoutePoints,
    required this.isRouteSelected,
    required this.selectedRouteIndex,
    required this.setState,
    required this.directionsService,
    required this.navigationController,
  });


  Future<void> getDirections(LatLng start, LatLng end) async {
    try {
      final directions = await directionsService.getDirections(start, end);
      clearRouteData();
      for (var route in directions) {
        final points = route['points'];
        final distance = route['distance'];
        final duration = route['duration'];
        allRoutes.add(points);
        routeDetails.add({
          'distance': distance,
          'duration': duration,
        });
      }
      plannedRoutePoints.addAll(allRoutes[0]);
      remainingRoutePoints.addAll(allRoutes[0]);
      selectRoute(0);
      setState(() {
        isRouteSelected = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void clearRouteData() {
    allRoutes.clear();
    routeDetails.clear();
    plannedRoutePoints.clear();
    remainingRoutePoints.clear();
  }

  void updatePolylinePoints(List<LatLng> points) {
    setState(() {
      polylinePoints.clear();
      polylinePoints.addAll(points);
      remainingRoutePoints.clear();
      remainingRoutePoints.addAll(points);
    });
  }

  void clearNavigation(LatLng currentLocation) {
    setState(() {
      clearMapMarkersAndPolylines(currentLocation);
      resetRouteAndNavigationData();
    });
  }

  void clearMapMarkersAndPolylines(LatLng currentLocation) {
    markers.clear();
    markers.add(
        buildRedCurrentLocationMarker(currentLocation));
    polylinePoints.clear();
    coveredRoutePoints.clear();
    plannedRoutePoints.clear();
    remainingRoutePoints.clear();
  }

  Marker buildRedCurrentLocationMarker(LatLng point) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      child: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 40.0,
      ),
    );
  }

  void resetRouteAndNavigationData() {
    allRoutes.clear();
    routeDetails.clear();
    isRouteSelected = false;
  }

  void selectRoute(int index) {
    if (!navigationController.isNavigationActive) {
      setState(() {
        selectedRouteIndex = index;
        updatePolylineForSelectedRoute(index);
        updatePlannedRoutePoints();
      });
    }
  }

  void updatePolylineForSelectedRoute(int index) {
    polylinePoints.clear();
    polylinePoints.addAll(allRoutes[index]);
    remainingRoutePoints.clear();
    remainingRoutePoints.addAll(allRoutes[index]);
  }

  void updatePlannedRoutePoints() {
    setState(() {
      plannedRoutePoints.clear();
      if (selectedRouteIndex >= 0 && selectedRouteIndex < allRoutes.length) {
        plannedRoutePoints.addAll(allRoutes[selectedRouteIndex]);
      }
    });
  }

  void updateCoveredPolyline(List<LatLng> points) {
    setState(() {
      coveredRoutePoints = points;
      updateRemainingRoutePoints();
    });
  }

  void updateRemainingRoutePoints() {
    if (plannedRoutePoints.isNotEmpty && coveredRoutePoints.isNotEmpty) {
      int coveredPointsCount = coveredRoutePoints.length;
      if (coveredPointsCount <= plannedRoutePoints.length) {
        remainingRoutePoints =
            plannedRoutePoints.sublist(coveredPointsCount - 1);
      } else {
        remainingRoutePoints = [];
      }
    } else {
      remainingRoutePoints = [];
    }
  }
}
