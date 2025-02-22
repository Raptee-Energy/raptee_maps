import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerManager {
  final List<Marker> markers;
  final void Function(VoidCallback fn) setState;

  MarkerManager({required this.markers, required this.setState});

  void updateCurrentLocationMarker(LatLng location) {
    setState(() {
      markers.removeWhere((marker) =>
      marker.child is Icon && (marker.child as Icon).color == Colors.red);
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: location,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    });
  }

  void removeBlueMarkers() {
    setState(() {
      markers.removeWhere((marker) =>
      marker.child is Icon && (marker.child as Icon).color == Colors.blue);
    });
  }

  void removeRedMarkers() {
    setState(() {
      markers.removeWhere((marker) =>
      marker.child is Icon && (marker.child as Icon).color == Colors.red);
    });
  }

  void removeGreenMarkers() {
    setState(() {
      markers.removeWhere((marker) =>
      marker.child is Icon && (marker.child as Icon).color == Colors.green);
    });
  }

  void addBlueMarker(LatLng location) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: location,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40.0,
          ),
        ),
      );
    });
  }

  void addGreenNavigationMarker(LatLng location) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: location,
          child: const Icon(
            Icons.navigation,
            color: Colors.green,
            size: 40.0,
          ),
        ),
      );
    });
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
}