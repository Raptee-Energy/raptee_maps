import 'package:flutter/material.dart';

import '../Controller/mapController.dart';

class CurrentLocationButton extends StatelessWidget {
  final MapAnimationController mapAnimationController;
  final bool isLoadingLocation;
  final VoidCallback onPanToCurrentLocation;

  const CurrentLocationButton({
    super.key,
    required this.mapAnimationController,
    required this.isLoadingLocation,
    required this.onPanToCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'current_location',
      onPressed: onPanToCurrentLocation,
      child: isLoadingLocation
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.my_location),
    );
  }
}