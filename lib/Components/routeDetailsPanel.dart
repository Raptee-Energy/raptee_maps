import 'package:flutter/material.dart';
import '../../Methods/minutesToHours.dart';

class RouteDetailsWidget extends StatelessWidget {
  final int selectedRouteIndex;
  final List<Map<String, dynamic>> routeDetails;
  final int routeCount;
  final VoidCallback onSelectNextRoute;

  const RouteDetailsWidget({
    super.key,
    required this.selectedRouteIndex,
    required this.routeDetails,
    required this.routeCount,
    required this.onSelectNextRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Route ${selectedRouteIndex + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Distance: ${(routeDetails[selectedRouteIndex]['distance'] / 1000).toStringAsFixed(2)} km',
            style: const TextStyle(fontSize: 16.0),
          ),
          Text(
            'Duration: ${convertRemainingTimeHHMM((routeDetails[selectedRouteIndex]['duration'] / 60).toInt())}',
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          if (routeCount > 1)
            ElevatedButton(
              onPressed: onSelectNextRoute,
              child: const Text('Select Alternate Route'),
            ),
        ],
      ),
    );
  }
}
