import 'package:flutter/material.dart';

import '../Controller/mapController.dart';

class ZoomControls extends StatelessWidget {
  final MapAnimationController mapAnimationController;

  const ZoomControls({super.key, required this.mapAnimationController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'zoom_in',
          onPressed: () {
            mapAnimationController.updateZoom(
                mapAnimationController.mapController.camera.zoom + 1,
                animated: true);
            print(mapAnimationController.mapController.camera.zoom);
          },
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'zoom_out',
          onPressed: () => mapAnimationController.updateZoom(
              mapAnimationController.mapController.camera.zoom - 1,
              animated: true),
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
