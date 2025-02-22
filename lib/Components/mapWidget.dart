import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/mapConfig.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final Widget? tappablePolylineLayer;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.polylines,
    this.tappablePolylineLayer,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: MapConfig.initialMapCenter,
        initialZoom: MapConfig.initialMapZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: MapConfig.tileLayerUrlTemplate,
        ),
        if (tappablePolylineLayer != null) tappablePolylineLayer!,
        PolylineLayer(polylines: polylines),
        MarkerLayer(
          markers: markers,
          rotate: true,
        ),
      ],
    );
  }
}