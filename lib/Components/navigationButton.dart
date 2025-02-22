import 'package:flutter/material.dart';
import '../Controller/navigationController.dart';

class NavigationButton extends StatelessWidget {
  final NavigationController navigationController;
  final bool hasRoutes;
  final VoidCallback onStartNavigation;
  final VoidCallback onStopNavigation;

  const NavigationButton({
    super.key,
    required this.navigationController,
    required this.hasRoutes,
    required this.onStartNavigation,
    required this.onStopNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'navigation',
      onPressed: hasRoutes
          ? () {
        navigationController.isNavigationActive
            ? onStopNavigation()
            : onStartNavigation();
      }
          : null,
      child: Icon(
        navigationController.isNavigationActive ? Icons.stop : Icons.navigation,
      ),
    );
  }
}