//  ///TODO: OG CODE
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import '../Components/searchWidget.dart';
// import '../Controller/navigationController.dart';
// import '../Methods/minutesToHours.dart';
// import '../Package/tappablePolyline.dart';
// import '../Services/googlePlacesService.dart';
// import '../Services/mapBoxDirectionService.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
//   final MapController _mapController = MapController();
//   final List<Marker> _markers = [];
//   final List<LatLng> _polylinePoints = [];
//   final List<List<LatLng>> _allRoutes = [];
//   final List<Map<String, dynamic>> _routeDetails = [];
//   final TextEditingController _searchController = TextEditingController();
//   final GooglePlacesService _placesService;
//   final MapBoxDirectionsService _directionsService;
//   late LatLng _currentLocation;
//   List<dynamic> _suggestions = [];
//   bool _isRouteSelected = false;
//   int _selectedRouteIndex = 0;
//
//   late NavigationController _navigationController;
//
//   late List<LatLng> _coveredRoutePoints = [];
//   final List<LatLng> _plannedRoutePoints = [];
//
//   String _turnInstruction = '';
//   String _turnIcon = '';
//
//   _MapScreenState()
//       : _placesService = GooglePlacesService(),
//         _directionsService = MapBoxDirectionsService() {
//     _navigationController = NavigationController(
//       allRoutes: _allRoutes,
//       directionsService: _directionsService,
//     )
//       ..updatePolylinePoints = _updatePolylinePoints
//       ..updateCurrentLocation = _updateCurrentLocation
//       ..clearNavigation = _clearNavigation
//       ..updateTurnInstructions = _updateTurnInstructions
//       ..updateCoveredPolyline = _updateCoveredPolyline;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _requestLocationPermission();
//   }
//
//   Future<void> _requestLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _currentLocation = LatLng(position.latitude, position.longitude);
//
//       setState(() {
//         _markers.add(
//           Marker(
//             width: 80.0,
//             height: 80.0,
//             point: _currentLocation,
//             child: Container(
//               child: const Icon(
//                 Icons.location_on,
//                 color: Colors.red,
//                 size: 40.0,
//               ),
//             ),
//           ),
//         );
//         _mapController.move(_currentLocation, 15.0);
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void _onSearchChanged(String value) {
//     _placesService.debounceSearch(value, _currentLocation, _updateSuggestions);
//   }
//
//   void _updateSuggestions(List<dynamic> results) {
//     setState(() {
//       _suggestions = results;
//     });
//   }
//
//   Future<void> _onSuggestionSelected(dynamic suggestion) async {
//     final placeDetails = await _placesService.getPlaceDetails(
//       suggestion['place_id'],
//       _currentLocation,
//     );
//     final lat = placeDetails['geometry']['location']['lat'];
//     final lng = placeDetails['geometry']['location']['lng'];
//     final selectedLocation = LatLng(lat, lng);
//
//     final avgLat = (_currentLocation.latitude + lat) / 2;
//     final avgLng = (_currentLocation.longitude + lng) / 2;
//     final midPoint = LatLng(avgLat, avgLng);
//
//     setState(() {
//       _markers.add(
//         Marker(
//           width: 80.0,
//           height: 80.0,
//           point: selectedLocation,
//           child: Container(
//             child: const Icon(
//               Icons.location_on,
//               color: Colors.blue,
//               size: 40.0,
//             ),
//           ),
//         ),
//       );
//       _searchController.clear();
//       _suggestions = [];
//     });
//
//     final distance = const Distance()
//         .as(LengthUnit.Kilometer, _currentLocation, selectedLocation);
//
//     double zoomLevel;
//     if (distance < 1) {
//       zoomLevel = 15;
//     } else if (distance < 5) {
//       zoomLevel = 14;
//     } else if (distance < 10) {
//       zoomLevel = 13;
//     } else if (distance < 20) {
//       zoomLevel = 12;
//     } else if (distance < 50) {
//       zoomLevel = 11;
//     } else if (distance < 100) {
//       zoomLevel = 10;
//     } else if (distance < 200) {
//       zoomLevel = 9;
//     } else {
//       zoomLevel = 7;
//     }
//
//     _mapController.move(midPoint, zoomLevel);
//
//     await _getDirections(_currentLocation, selectedLocation);
//   }
//
//   Future<void> _getDirections(LatLng start, LatLng end) async {
//     try {
//       final directions = await _directionsService.getDirections(start, end);
//       _allRoutes.clear();
//       _routeDetails.clear();
//       _plannedRoutePoints.clear();
//       for (var route in directions) {
//         final points = route['points'];
//         final distance = route['distance'];
//         final duration = route['duration'];
//         _allRoutes.add(points);
//         _routeDetails.add({
//           'distance': distance,
//           'duration': duration,
//         });
//       }
//       _plannedRoutePoints.addAll(_allRoutes[0]);
//       _selectRoute(0);
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void _updatePolylinePoints(List<LatLng> polylinePoints) {
//     setState(() {
//       _polylinePoints.clear();
//       _polylinePoints.addAll(polylinePoints);
//     });
//   }
//
//   void _updateCurrentLocation(LatLng location) {
//     setState(() {
//       _markers.removeWhere((marker) => marker.point == _currentLocation);
//       _currentLocation = location;
//       _markers.add(
//           Marker(
//             width: 80.0,
//             height: 80.0,
//             point: location,
//             child: Container(
//               child: const Icon(
//                 Icons.navigation,
//                 color: Colors.green,
//                 size: 40.0,
//               ),
//             ),
//           ),
//       );
//
//       if (_plannedRoutePoints.isNotEmpty) {
//         _plannedRoutePoints[0] = _currentLocation;
//       }
//     });
//   }
//
//   void _clearNavigation() {
//     setState(() {
//       _markers.clear();
//       _polylinePoints.clear();
//       _coveredRoutePoints.clear();
//       _plannedRoutePoints.clear();
//       _allRoutes.clear();
//       _routeDetails.clear();
//       _isRouteSelected = false;
//     });
//   }
//
//   void _onPanToCurrentLocation() {
//     _mapController.move(_currentLocation, 15.0);
//   }
//
//   void _selectRoute(int index) {
//     if (!_navigationController.isNavigationActive) {
//       setState(() {
//         _selectedRouteIndex = index;
//         _polylinePoints.clear();
//         _polylinePoints.addAll(_allRoutes[index]);
//         _updatePlannedRoutePoints();
//       });
//     }
//   }
//
//   void _updatePlannedRoutePoints() {
//     setState(() {
//       _plannedRoutePoints.clear();
//       if (_selectedRouteIndex >= 0 && _selectedRouteIndex < _allRoutes.length) {
//         _plannedRoutePoints.addAll(_allRoutes[_selectedRouteIndex]);
//       }
//     });
//   }
//
//   void _updateTurnInstructions(String instruction, String icon) {
//     setState(() {
//       _turnInstruction = instruction;
//       _turnIcon = icon;
//     });
//   }
//
//   void _startNavigation() {
//     setState(() {
//       _isRouteSelected = true;
//     });
//     _navigationController.startNavigation();
//   }
//
//   void _updateCoveredPolyline(List<LatLng> coveredPoints) {
//     setState(() {
//       _coveredRoutePoints = coveredPoints;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Raptee Maps")),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: LatLng(22, 74),
//               initialZoom: 13.0,
//               minZoom: 0,
//               maxZoom: 20,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
//               ),
//               if (!_navigationController.isNavigationActive && _allRoutes.isNotEmpty)
//                 TappablePolylineLayer(
//                   polylines: _allRoutes
//                       .asMap()
//                       .entries
//                       .map((entry) {
//                     int index = entry.key;
//                     List<LatLng> route = entry.value;
//                     return TaggedPolyline(
//                       points: route,
//                       strokeWidth: 4.0,
//                       color: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
//                       tag: 'route_$index',
//                     );
//                   }).toList(),
//                   onTap: (String tag) {
//                     if (!_navigationController.isNavigationActive) {
//                       int tappedIndex = int.parse(tag.split('_')[1]);
//                       _selectRoute(tappedIndex);
//                     }
//                   },
//                 ),
//               PolylineLayer(
//                 polylines: [
//                   Polyline(
//                     points: _plannedRoutePoints,
//                     strokeWidth: 4.0,
//                     color: Colors.blue.withOpacity(0.5),
//                   ),
//                   Polyline(
//                     points: _coveredRoutePoints,
//                     strokeWidth: 4.0,
//                     color: Colors.green,
//                   ),
//                 ],
//               ),
//               MarkerLayer(
//                 markers: _markers,
//                 rotate: true,
//               ),
//             ],
//           ),
//           if (!_navigationController.isNavigationActive)
//             Positioned(
//               top: 16.0,
//               left: 16.0,
//               right: 16.0,
//               child: SearchWidget(
//                 searchController: _searchController,
//                 suggestions: _suggestions,
//                 onSearchChanged: _onSearchChanged,
//                 onSuggestionSelected: _onSuggestionSelected,
//               ),
//             ),
//           if (_isRouteSelected && !_navigationController.isNavigationActive)
//             Positioned(
//               top: 16.0,
//               left: 16.0,
//               right: 16.0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Distance: ${(_routeDetails[_selectedRouteIndex]['distance'] /
//                           1000).toStringAsFixed(2)} km',
//                       style: const TextStyle(fontSize: 16.0),
//                     ),
//                     Text(
//                       'Duration: ${convertRemainingTimeHHMM(
//                           (_routeDetails[_selectedRouteIndex]['duration'] / 60)
//                               .toInt())}',
//                       style: const TextStyle(fontSize: 16.0),
//                     ),
//                     const SizedBox(height: 8.0),
//                     if (_allRoutes.length > 1)
//                       ElevatedButton(
//                         onPressed: () {
//                           int nextRouteIndex = (_selectedRouteIndex + 1) %
//                               _allRoutes.length;
//                           _selectRoute(nextRouteIndex);
//                         },
//                         child: const Text('Select Alternate Route'),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           if (_navigationController.isNavigationActive)
//             Positioned(
//               top: 16.0,
//               right: 16.0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     if (_turnIcon.isNotEmpty)
//                       Image.asset(
//                         '$_turnIcon',
//                         width: 32.0,
//                         height: 32.0,
//                       ),
//                     const SizedBox(width: 8.0),
//                     Text(
//                       _turnInstruction,
//                       style: const TextStyle(fontSize: 16.0),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: 'zoom_in',
//             onPressed: () =>
//                 _mapController.move(
//                     _mapController.camera.center, _mapController.camera.zoom + 1),
//             child: const Icon(Icons.zoom_in),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: 'zoom_out',
//             onPressed: () =>
//                 _mapController.move(
//                     _mapController.camera.center, _mapController.camera.zoom - 1),
//             child: const Icon(Icons.zoom_out),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: 'current_location',
//             onPressed: _onPanToCurrentLocation,
//             child: const Icon(Icons.my_location),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: 'navigation',
//             onPressed: _allRoutes.isNotEmpty
//                 ? _navigationController.isNavigationActive
//                 ? _navigationController.stopNavigation
//                 : _startNavigation
//                 : null,
//             child: Icon(
//               _navigationController.isNavigationActive
//                   ? Icons.stop
//                   : Icons.navigation,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

///TODO: MODIFIED CODE
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Components/searchWidget.dart';
import '../Controller/navigationController.dart';
import '../Methods/minutesToHours.dart';
import '../Package/tappablePolyline.dart';
import '../Services/googlePlacesService.dart';
import '../Services/mapBoxDirectionService.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final List<LatLng> _polylinePoints = [];
  final List<List<LatLng>> _allRoutes = [];
  final List<Map<String, dynamic>> _routeDetails = [];
  final TextEditingController _searchController = TextEditingController();
  final GooglePlacesService _placesService;
  final MapBoxDirectionsService _directionsService;
  late LatLng _currentLocation;
  List<dynamic> _suggestions = [];
  bool _isRouteSelected = false;
  int _selectedRouteIndex = 0;

  late NavigationController _navigationController;

  List<LatLng> _coveredRoutePoints = []; // No longer lateinit, initialize here
  final List<LatLng> _plannedRoutePoints = [];

  String _turnInstruction = '';
  String _turnIcon = '';

  _MapScreenState()
      : _placesService = GooglePlacesService(),
        _directionsService = MapBoxDirectionsService() {
    _navigationController = NavigationController(
      allRoutes: _allRoutes,
      directionsService: _directionsService,
    )
      ..updatePolylinePoints = _updatePolylinePoints
      ..updateCurrentLocation = _updateCurrentLocation
      ..clearNavigation = _clearNavigation
      ..updateTurnInstructions = _updateTurnInstructions
      ..updateCoveredPolyline = _updateCoveredPolyline;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: _currentLocation,
            child: Container(
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ),
        );
        _mapController.move(_currentLocation, 15.0);
      });
    } catch (e) {
      print(e);
    }
  }

  void _onSearchChanged(String value) {
    _placesService.debounceSearch(value, _currentLocation, _updateSuggestions);
  }

  void _updateSuggestions(List<dynamic> results) {
    setState(() {
      _suggestions = results;
    });
  }

  Future<void> _onSuggestionSelected(dynamic suggestion) async {
    final placeDetails = await _placesService.getPlaceDetails(
      suggestion['place_id'],
      _currentLocation,
    );
    final lat = placeDetails['geometry']['location']['lat'];
    final lng = placeDetails['geometry']['location']['lng'];
    final selectedLocation = LatLng(lat, lng);

    final avgLat = (_currentLocation.latitude + lat) / 2;
    final avgLng = (_currentLocation.longitude + lng) / 2;
    final midPoint = LatLng(avgLat, avgLng);

    setState(() {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: selectedLocation,
          child: Container(
            child: const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        ),
      );
      _searchController.clear();
      _suggestions = [];
    });

    final distance = const Distance()
        .as(LengthUnit.Kilometer, _currentLocation, selectedLocation);

    double zoomLevel;
    if (distance < 1) {
      zoomLevel = 15;
    } else if (distance < 5) {
      zoomLevel = 14;
    } else if (distance < 10) {
      zoomLevel = 13;
    } else if (distance < 20) {
      zoomLevel = 12;
    } else if (distance < 50) {
      zoomLevel = 11;
    } else if (distance < 100) {
      zoomLevel = 10;
    } else if (distance < 200) {
      zoomLevel = 9;
    } else {
      zoomLevel = 7;
    }

    _mapController.move(midPoint, zoomLevel);

    await _getDirections(_currentLocation, selectedLocation);
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    try {
      final directions = await _directionsService.getDirections(start, end);
      _allRoutes.clear();
      _routeDetails.clear();
      _plannedRoutePoints.clear();
      for (var route in directions) {
        final points = route['points'];
        final distance = route['distance'];
        final duration = route['duration'];
        _allRoutes.add(points);
        _routeDetails.add({
          'distance': distance,
          'duration': duration,
        });
      }
      _plannedRoutePoints.addAll(_allRoutes[0]);
      _selectRoute(0);
    } catch (e) {
      print(e);
    }
  }

  void _updatePolylinePoints(List<LatLng> polylinePoints) {
    setState(() {
      _polylinePoints.clear();
      _polylinePoints.addAll(polylinePoints);
    });
  }

  void _updateCurrentLocation(LatLng location) {
    setState(() {
      _markers.removeWhere((marker) => marker.point == _currentLocation);
      _currentLocation = location;
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: location,
          child: Container(
            child: const Icon(
              Icons.navigation,
              color: Colors.green,
              size: 40.0,
            ),
          ),
        ),
      );

      if (_plannedRoutePoints.isNotEmpty) {
        // _plannedRoutePoints[0] = _currentLocation; // No longer updating first point directly, handled in _updateNavigationProgress indirectly
      }
    });
  }

  void _clearNavigation() {
    setState(() {
      _markers.clear();
      _polylinePoints.clear();
      _coveredRoutePoints.clear();
      _plannedRoutePoints.clear();
      _allRoutes.clear();
      _routeDetails.clear();
      _isRouteSelected = false;
      _turnInstruction = ''; // Clear instruction
      _turnIcon = '';        // Clear icon
    });
  }

  void _onPanToCurrentLocation() {
    _mapController.move(_currentLocation, 15.0);
  }

  void _selectRoute(int index) {
    if (!_navigationController.isNavigationActive) {
      setState(() {
        _selectedRouteIndex = index;
        _polylinePoints.clear();
        _polylinePoints.addAll(_allRoutes[index]);
        _updatePlannedRoutePoints();
      });
    }
  }

  void _updatePlannedRoutePoints() {
    setState(() {
      _plannedRoutePoints.clear();
      if (_selectedRouteIndex >= 0 && _selectedRouteIndex < _allRoutes.length) {
        _plannedRoutePoints.addAll(_allRoutes[_selectedRouteIndex]);
      }
    });
  }

  void _updateTurnInstructions(String instruction, String icon) {
    setState(() {
      _turnInstruction = instruction;
      _turnIcon = icon;
    });
  }

  void _startNavigation() {
    setState(() {
      _isRouteSelected = true;
    });
    _navigationController.startNavigation();
  }

  void _updateCoveredPolyline(List<LatLng> coveredPoints) {
    setState(() {
      _coveredRoutePoints = coveredPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Raptee Maps")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(22, 74),
              initialZoom: 13.0,
              minZoom: 0,
              maxZoom: 20,
            ),
            children: [
              TileLayer(
                urlTemplate: 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png', // Use your tile URL here
              ),
              if (!_navigationController.isNavigationActive && _allRoutes.isNotEmpty)
                TappablePolylineLayer(
                  polylines: _allRoutes
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final route = entry.value;
                    return TaggedPolyline(
                      points: route,
                      strokeWidth: 4.0,
                      color: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
                      tag: 'route_$index',
                    );
                  }).toList(),
                  onTap: (String tag) {
                    if (!_navigationController.isNavigationActive) {
                      final tappedIndex = int.parse(tag.split('_')[1]);
                      _selectRoute(tappedIndex);
                    }
                  },
                ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _plannedRoutePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                  Polyline(
                    points: _coveredRoutePoints,
                    strokeWidth: 6.0, // Make covered line thicker and more prominent
                    color: Colors.green,
                  ),
                ],
              ),
              MarkerLayer(
                markers: _markers,
                rotate: true,
              ),
            ],
          ),
          if (!_navigationController.isNavigationActive)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: SearchWidget(
                searchController: _searchController,
                suggestions: _suggestions,
                onSearchChanged: _onSearchChanged,
                onSuggestionSelected: _onSuggestionSelected,
              ),
            ),
          if (_isRouteSelected && !_navigationController.isNavigationActive)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Distance: ${(_routeDetails[_selectedRouteIndex]['distance'] /
                          1000).toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Duration: ${convertRemainingTimeHHMM(
                          (_routeDetails[_selectedRouteIndex]['duration'] / 60)
                              .toInt())}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    if (_allRoutes.length > 1)
                      ElevatedButton(
                        onPressed: () {
                          final nextRouteIndex = (_selectedRouteIndex + 1) %
                              _allRoutes.length;
                          _selectRoute(nextRouteIndex);
                        },
                        child: const Text('Select Alternate Route'),
                      ),
                  ],
                ),
              ),
            ),
          if (_navigationController.isNavigationActive)
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (_turnIcon.isNotEmpty)
                      Image.asset(
                        'assets/icons/turn_left.png', // Replace with your actual icon path and logic for different icons
                        width: 32.0,
                        height: 32.0,
                      ),
                    const SizedBox(width: 8.0),
                    Text(
                      _turnInstruction,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () =>
                _mapController.move(
                    _mapController.camera.center, _mapController.camera.zoom + 1),
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () =>
                _mapController.move(
                    _mapController.camera.center, _mapController.camera.zoom - 1),
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _onPanToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'navigation',
            onPressed: _allRoutes.isNotEmpty
                ? _navigationController.isNavigationActive
                ? _navigationController.stopNavigation
                : _startNavigation
                : null,
            child: Icon(
              _navigationController.isNavigationActive
                  ? Icons.stop
                  : Icons.navigation,
            ),
          ),
        ],
      ),
    );
  }
}
