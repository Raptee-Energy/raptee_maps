// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:navtesttwo/Package/tappablePolyline.dart';
// // import '../Components/searchWidget.dart';
// // import '../Controller/navigationController.dart';
// // import '../Methods/minutesToHours.dart';
// // import '../Repo/extraPoints.dart';
// // import '../Services/googlePlacesService.dart';
// // import '../Services/mapBoxDirectionService.dart';
// //
// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});
// //
// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }
// //
// // class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
// //   final MapController _mapController = MapController();
// //   final List<Marker> _markers = [];
// //   final List<LatLng> _polylinePoints = [];
// //   final List<List<LatLng>> _allRoutes = [];
// //   final List<Map<String, dynamic>> _routeDetails = [];
// //   final TextEditingController _searchController = TextEditingController();
// //   final GooglePlacesService _placesService;
// //   final MapBoxDirectionsService _directionsService;
// //   late LatLng _currentLocation;
// //   List<dynamic> _suggestions = [];
// //   bool _isRouteSelected = false;
// //   int _selectedRouteIndex = 0;
// //
// //   late NavigationController _navigationController;
// //
// //   final List<LatLng> _coveredRoutePoints = [];
// //   final List<LatLng> _plannedRoutePoints = [];
// //
// //
// //   _MapScreenState()
// //       : _placesService = GooglePlacesService(),
// //         _directionsService = MapBoxDirectionsService();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //     _navigationController = NavigationController(
// //       allRoutes: _allRoutes,
// //       directionsService: _directionsService,
// //     )
// //       ..updatePolylinePoints = _updatePolylinePoints
// //       ..updateCurrentLocation = _updateCurrentLocation
// //       ..clearNavigation = _clearNavigation
// //       ..updateTurnInstructions = _updateTurnInstructions;
// //
// //     _requestLocationPermission();
// //   }
// //
// //
// //
// //   Future<void> _requestLocationPermission() async {
// //     bool serviceEnabled;
// //     LocationPermission permission;
// //
// //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       return Future.error('Location services are disabled.');
// //     }
// //
// //     permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return Future.error('Location permissions are denied');
// //       }
// //     }
// //
// //     if (permission == LocationPermission.deniedForever) {
// //       return Future.error(
// //           'Location permissions are permanently denied, we cannot request permissions.');
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //       _currentLocation = LatLng(position.latitude, position.longitude);
// //
// //       setState(() {
// //         _markers.add(
// //           Marker(
// //             width: 80.0,
// //             height: 80.0,
// //             point: _currentLocation,
// //             child: Container(
// //               child: const Icon(
// //                 Icons.location_on,
// //                 color: Colors.red,
// //                 size: 40.0,
// //               ),
// //             ),
// //           ),
// //         );
// //         _mapController.move(_currentLocation, 15.0);
// //       });
// //     } catch (e) {
// //       print(e);
// //     }
// //   }
// //
// //   void _onRouteSelected(int index) {
// //     setState(() {
// //       _selectedRouteIndex = index;
// //       _updatePlannedRoutePoints();
// //     });
// //   }
// //   void _onSearchChanged(String value) {
// //     _placesService.debounceSearch(value, _currentLocation, _updateSuggestions);
// //   }
// //
// //   void _updateSuggestions(List<dynamic> results) {
// //     setState(() {
// //       _suggestions = results;
// //     });
// //   }
// //
// //   Future<void> _onSuggestionSelected(dynamic suggestion) async {
// //     final placeDetails = await _placesService.getPlaceDetails(
// //       suggestion['place_id'],
// //       _currentLocation,
// //     );
// //     final lat = placeDetails['geometry']['location']['lat'];
// //     final lng = placeDetails['geometry']['location']['lng'];
// //     final selectedLocation = LatLng(lat, lng);
// //
// //     final avgLat = (_currentLocation.latitude + lat) / 2;
// //     final avgLng = (_currentLocation.longitude + lng) / 2;
// //     final midPoint = LatLng(avgLat, avgLng);
// //
// //     setState(() {
// //       _markers.add(
// //         Marker(
// //           width: 80.0,
// //           height: 80.0,
// //           point: selectedLocation,
// //           child: Container(
// //             child: const Icon(
// //               Icons.location_on,
// //               color: Colors.blue,
// //               size: 40.0,
// //             ),
// //           ),
// //         ),
// //       );
// //       _searchController.clear();
// //       _suggestions = [];
// //     });
// //
// //     final distance = const Distance()
// //         .as(LengthUnit.Kilometer, _currentLocation, selectedLocation);
// //
// //     double zoomLevel;
// //     if (distance < 1) {
// //       zoomLevel = 15;
// //     } else if (distance < 5) {
// //       zoomLevel = 14;
// //     } else if (distance < 10) {
// //       zoomLevel = 13;
// //     } else if (distance < 20) {
// //       zoomLevel = 12;
// //     } else if (distance < 50) {
// //       zoomLevel = 11;
// //     } else if (distance < 100) {
// //       zoomLevel = 10;
// //     } else if (distance < 200) {
// //       zoomLevel = 9;
// //     } else {
// //       zoomLevel = 7;
// //     }
// //
// //     _mapController.move(midPoint, zoomLevel);
// //
// //     await _getDirections(_currentLocation, selectedLocation);
// //     setState(() {
// //       _isRouteSelected = true;
// //     });
// //   }
// //
// //   Future<void> _getDirections(LatLng start, LatLng end) async {
// //     try {
// //       final directions = await _directionsService.getDirections(start, end);
// //       _allRoutes.clear();
// //       _routeDetails.clear();
// //       for (var route in directions) {
// //         final points = route['points'];
// //         final distance = route['distance'];
// //         final duration = route['duration'];
// //         _allRoutes.add(points);
// //         _routeDetails.add({
// //           'distance': distance,
// //           'duration': duration,
// //         });
// //       }
// //       _selectedRouteIndex = 0;
// //       _updatePlannedRoutePoints();
// //       setState(() {
// //         _isRouteSelected = true;
// //       });
// //     } catch (e) {
// //       print(e);
// //     }
// //   }
// //
// //   void _updatePolylinePoints(List<LatLng> polylinePoints) {
// //     setState(() {
// //       _polylinePoints.clear();
// //       _polylinePoints.addAll(polylinePoints);
// //     });
// //   }
// //
// //   void _updateCurrentLocation(LatLng location) {
// //     setState(() {
// //       // Update the covered route
// //       if (_coveredRoutePoints.isEmpty) {
// //         _coveredRoutePoints.add(_currentLocation);
// //       }
// //       _coveredRoutePoints.add(location);
// //
// //       // Remove the old marker
// //       _markers.removeWhere((marker) => marker.point == _currentLocation);
// //
// //       // Update the current location
// //       _currentLocation = location;
// //
// //       // Add the new marker
// //       _markers.add(
// //         Marker(
// //           width: 80.0,
// //           height: 80.0,
// //           point: location,
// //           child: Container(
// //             child: const Icon(
// //               Icons.navigation,
// //               color: Colors.green,
// //               size: 40.0,
// //             ),
// //           ),
// //         ),
// //       );
// //
// //       // Update the polyline points to reflect the connection
// //       if (_plannedRoutePoints.isNotEmpty) {
// //         _plannedRoutePoints[0] = _currentLocation;
// //       }
// //     });
// //   }
// //
// //   void _clearNavigation() {
// //     setState(() {
// //       _markers.clear();
// //       _polylinePoints.clear();
// //       _coveredRoutePoints.clear();
// //       _plannedRoutePoints.clear();
// //       _allRoutes.clear();
// //       _routeDetails.clear();
// //       _isRouteSelected = false;
// //     });
// //   }
// //
// //   void _onPanToCurrentLocation() {
// //     _mapController.move(_currentLocation, 15.0);
// //   }
// //
// //   void _selectRoute(int index) {
// //     setState(() {
// //       _selectedRouteIndex = index;
// //       _polylinePoints.clear();
// //       _polylinePoints.addAll(_allRoutes[index]);
// //       if (_navigationController.isNavigationActive) {
// //         _navigationController.updateNavigationRoute();
// //       }
// //       _updatePlannedRoutePoints();
// //     });
// //   }
// //
// //   void _updatePlannedRoutePoints() {
// //     if (_selectedRouteIndex >= 0 && _selectedRouteIndex < _allRoutes.length) {
// //       _plannedRoutePoints.clear();
// //       _plannedRoutePoints.addAll(_allRoutes[_selectedRouteIndex]);
// //     }
// //   }
// //
// //
// //   String _turnInstruction = '';
// //   String _turnIcon = '';
// //
// //   void _updateTurnInstructions(String instruction, String icon) {
// //     setState(() {
// //       _turnInstruction = instruction;
// //       _turnIcon = icon;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Map Screen"),),
// //       body: Stack(
// //         children: [
// //           FlutterMap(
// //             mapController: _mapController,
// //             options: MapOptions(
// //               initialCenter: const LatLng(22, 74),
// //               initialZoom: 13.0,
// //               minZoom: 0,
// //               maxZoom: 20,
// //               onTap: (_, __) {
// //                 if (_navigationController.isNavigationActive) {
// //                   _selectRoute(0);
// //                 }
// //               },
// //             ),
// //             children: [
// //               TileLayer(
// //                 urlTemplate:
// //                 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
// //               ),
// //               MarkerLayer(
// //                 markers: _markers,
// //                 rotate: true,
// //               ),
// //               TappablePolylineLayer(
// //                 polylines: [
// //                   TaggedPolyline(
// //                     tag: "Route 1",
// //                     points: _allRoutes.isNotEmpty ? _allRoutes[0] : [],
// //                     strokeWidth: 4.0,
// //                     color: _selectedRouteIndex == 0 ? Colors.blue : Colors.grey,
// //                     onTap: () {
// //                       setState(() {
// //                         _selectedRouteIndex = 0;
// //                         _updatePlannedRoutePoints();
// //                       });
// //                     },
// //                   ),
// //                   TaggedPolyline(
// //                     tag: "Route 2",
// //                     points: _allRoutes.length > 1 ? _allRoutes[1] : [],
// //                     strokeWidth: 4.0,
// //                     color: _selectedRouteIndex == 1 ? Colors.blue : Colors.grey,
// //                     onTap: () {
// //                       setState(() {
// //                         _selectedRouteIndex = 1;
// //                         _updatePlannedRoutePoints();
// //                       });
// //                     },
// //                   ),
// //
// //                 ],
// //               ),
// //             ],
// //           ),
// //           if (!_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               left: 16.0,
// //               right: 16.0,
// //               child: SearchWidget(
// //                 searchController: _searchController,
// //                 suggestions: _suggestions,
// //                 onSearchChanged: _onSearchChanged,
// //                 onSuggestionSelected: _onSuggestionSelected,
// //               ),
// //             ),
// //           if (_isRouteSelected && !_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               left: 16.0,
// //               right: 16.0,
// //               child: Container(
// //                 color: Colors.white,
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     Text(
// //                       'Distance: ${(_routeDetails[_selectedRouteIndex]['distance'] / 1000).toStringAsFixed(2)} km',
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                     Text(
// //                       'Duration: ${convertRemainingTimeHHMM((_routeDetails[_selectedRouteIndex]['duration'] / 60).toInt())} ',
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                     const SizedBox(height: 8.0),
// //                     if (_allRoutes.length > 1)
// //                       ElevatedButton(
// //                         onPressed: () {
// //                           int nextRouteIndex =
// //                               (_selectedRouteIndex + 1) % _allRoutes.length;
// //                           _selectRoute(nextRouteIndex);
// //                         },
// //                         child: const Text('Select Alternate Route'),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           if (_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               right: 16.0,
// //               child: Container(
// //                 color: Colors.white,
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Row(
// //                   children: [
// //                     if (_turnIcon.isNotEmpty)
// //                       Image.asset(
// //                         '$_turnIcon',
// //                         width: 32.0,
// //                         height: 32.0,
// //                       ),
// //                     const SizedBox(width: 8.0),
// //                     Text(
// //                       _turnInstruction,
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //       floatingActionButton: Column(
// //         mainAxisAlignment: MainAxisAlignment.end,
// //         children: [
// //           FloatingActionButton(
// //             heroTag: 'zoom_in',
// //             onPressed: () => _mapController
// //                 .move(_mapController.camera.center, _mapController.camera.zoom + 1),
// //             child: const Icon(Icons.zoom_in),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'zoom_out',
// //             onPressed: () => _mapController
// //                 .move(_mapController.camera.center, _mapController.camera.zoom - 1),
// //             child: const Icon(Icons.zoom_out),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'current_location',
// //             onPressed: _onPanToCurrentLocation,
// //             child: const Icon(Icons.my_location),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'navigation',
// //             onPressed: _isRouteSelected
// //                 ? _navigationController.isNavigationActive
// //                 ? _navigationController.stopNavigation
// //                 : _navigationController.startNavigation
// //                 : null,
// //             child: Icon(
// //               _navigationController.isNavigationActive
// //                   ? Icons.stop
// //                   : Icons.navigation,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// //
//
//
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:latlong2/latlong.dart';
// // import '../Components/searchWidget.dart';
// // import '../Controller/navigationController.dart';
// // import '../Methods/minutesToHours.dart';
// // import '../Package/tappablePolyline.dart';
// // import '../Repo/extraPoints.dart';
// // import '../Services/googlePlacesService.dart';
// // import '../Services/mapBoxDirectionService.dart';
// //
// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});
// //
// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }
// //
// // class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
// //   final MapController _mapController = MapController();
// //   final List<Marker> _markers = [];
// //   final List<LatLng> _polylinePoints = [];
// //   final List<List<LatLng>> _allRoutes = [];
// //   final List<Map<String, dynamic>> _routeDetails = [];
// //   final TextEditingController _searchController = TextEditingController();
// //   final GooglePlacesService _placesService;
// //   final MapBoxDirectionsService _directionsService;
// //   late LatLng _currentLocation;
// //   List<dynamic> _suggestions = [];
// //   bool _isRouteSelected = false;
// //   int _selectedRouteIndex = 0;
// //
// //   late NavigationController _navigationController;
// //
// //   final List<LatLng> _coveredRoutePoints = [];
// //   final List<LatLng> _plannedRoutePoints = [];
// //
// //
// //   _MapScreenState()
// //       : _placesService = GooglePlacesService(),
// //         _directionsService = MapBoxDirectionsService();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //     _navigationController = NavigationController(
// //       allRoutes: _allRoutes,
// //       directionsService: _directionsService,
// //     )
// //       ..updatePolylinePoints = _updatePolylinePoints
// //       ..updateCurrentLocation = _updateCurrentLocation
// //       ..clearNavigation = _clearNavigation
// //       ..updateTurnInstructions = _updateTurnInstructions;
// //
// //     _requestLocationPermission();
// //   }
// //
// //
// //   Future<void> _requestLocationPermission() async {
// //     bool serviceEnabled;
// //     LocationPermission permission;
// //
// //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       return Future.error('Location services are disabled.');
// //     }
// //
// //     permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return Future.error('Location permissions are denied');
// //       }
// //     }
// //
// //     if (permission == LocationPermission.deniedForever) {
// //       return Future.error(
// //           'Location permissions are permanently denied, we cannot request permissions.');
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //       _currentLocation = LatLng(position.latitude, position.longitude);
// //
// //       setState(() {
// //         _markers.add(
// //           Marker(
// //             width: 80.0,
// //             height: 80.0,
// //             point: _currentLocation,
// //             child: Container(
// //               child: const Icon(
// //                 Icons.location_on,
// //                 color: Colors.red,
// //                 size: 40.0,
// //               ),
// //             ),
// //           ),
// //         );
// //         _mapController.move(_currentLocation, 15.0);
// //       });
// //     } catch (e) {
// //       print(e);
// //     }
// //   }
// //
// //   void _onSearchChanged(String value) {
// //     _placesService.debounceSearch(value, _currentLocation, _updateSuggestions);
// //   }
// //
// //   void _updateSuggestions(List<dynamic> results) {
// //     setState(() {
// //       _suggestions = results;
// //     });
// //   }
// //
// //   Future<void> _onSuggestionSelected(dynamic suggestion) async {
// //     final placeDetails = await _placesService.getPlaceDetails(
// //       suggestion['place_id'],
// //       _currentLocation,
// //     );
// //     final lat = placeDetails['geometry']['location']['lat'];
// //     final lng = placeDetails['geometry']['location']['lng'];
// //     final selectedLocation = LatLng(lat, lng);
// //
// //     final avgLat = (_currentLocation.latitude + lat) / 2;
// //     final avgLng = (_currentLocation.longitude + lng) / 2;
// //     final midPoint = LatLng(avgLat, avgLng);
// //
// //     setState(() {
// //       _markers.add(
// //         Marker(
// //           width: 80.0,
// //           height: 80.0,
// //           point: selectedLocation,
// //           child: Container(
// //             child: const Icon(
// //               Icons.location_on,
// //               color: Colors.blue,
// //               size: 40.0,
// //             ),
// //           ),
// //         ),
// //       );
// //       _searchController.clear();
// //       _suggestions = [];
// //     });
// //
// //     final distance = const Distance()
// //         .as(LengthUnit.Kilometer, _currentLocation, selectedLocation);
// //
// //     double zoomLevel;
// //     if (distance < 1) {
// //       zoomLevel = 15;
// //     } else if (distance < 5) {
// //       zoomLevel = 14;
// //     } else if (distance < 10) {
// //       zoomLevel = 13;
// //     } else if (distance < 20) {
// //       zoomLevel = 12;
// //     } else if (distance < 50) {
// //       zoomLevel = 11;
// //     } else if (distance < 100) {
// //       zoomLevel = 10;
// //     } else if (distance < 200) {
// //       zoomLevel = 9;
// //     } else {
// //       zoomLevel = 7;
// //     }
// //
// //     _mapController.move(midPoint, zoomLevel);
// //
// //     await _getDirections(_currentLocation, selectedLocation);
// //     // setState(() {
// //     //   _isRouteSelected = true;
// //     // });
// //   }
// //
// //   Future<void> _getDirections(LatLng start, LatLng end) async {
// //     try {
// //       final directions = await _directionsService.getDirections(start, end);
// //       _allRoutes.clear();
// //       _routeDetails.clear();
// //       _plannedRoutePoints.clear();
// //       for (var route in directions) {
// //         final points = route['points'];
// //         final distance = route['distance'];
// //         final duration = route['duration'];
// //         _allRoutes.add(points);
// //         _routeDetails.add({
// //           'distance': distance,
// //           'duration': duration,
// //         });
// //       }
// //       _plannedRoutePoints.addAll(_allRoutes[0]);
// //       _selectRoute(0);
// //     } catch (e) {
// //       print(e);
// //     }
// //   }
// //
// //   void _updatePolylinePoints(List<LatLng> polylinePoints) {
// //     setState(() {
// //       _polylinePoints.clear();
// //       _polylinePoints.addAll(polylinePoints);
// //     });
// //   }
// //
// //   void _updateCurrentLocation(LatLng location) {
// //     setState(() {
// //       // Update the covered route
// //       if (_coveredRoutePoints.isEmpty) {
// //         _coveredRoutePoints.add(_currentLocation);
// //       }
// //       _coveredRoutePoints.add(location);
// //
// //       // Remove the old marker
// //       _markers.removeWhere((marker) => marker.point == _currentLocation);
// //
// //       // Update the current location
// //       _currentLocation = location;
// //
// //       // Add the new marker
// //       _markers.add(
// //         Marker(
// //           width: 80.0,
// //           height: 80.0,
// //           point: location,
// //           child: Container(
// //             child: const Icon(
// //               Icons.navigation,
// //               color: Colors.green,
// //               size: 40.0,
// //             ),
// //           ),
// //         ),
// //       );
// //
// //       // Update the polyline points to reflect the connection
// //       if (_plannedRoutePoints.isNotEmpty) {
// //         _plannedRoutePoints[0] = _currentLocation;
// //       }
// //     });
// //   }
// //
// //   void _clearNavigation() {
// //     setState(() {
// //       _markers.clear();
// //       _polylinePoints.clear();
// //       _coveredRoutePoints.clear();
// //       _plannedRoutePoints.clear();
// //       _allRoutes.clear();
// //       _routeDetails.clear();
// //       _isRouteSelected = false;
// //     });
// //   }
// //
// //   void _onPanToCurrentLocation() {
// //     _mapController.move(_currentLocation, 15.0);
// //   }
// //
// //   void _selectRoute(int index) {
// //     if (!_navigationController.isNavigationActive) {
// //       setState(() {
// //         _selectedRouteIndex = index;
// //         _polylinePoints.clear();
// //         _polylinePoints.addAll(_allRoutes[index]);
// //         _updatePlannedRoutePoints();
// //       });
// //     }
// //   }
// //   void _updatePlannedRoutePoints() {
// //     setState(() {
// //       _plannedRoutePoints.clear();
// //       if (_selectedRouteIndex >= 0 && _selectedRouteIndex < _allRoutes.length) {
// //         _plannedRoutePoints.addAll(_allRoutes[_selectedRouteIndex]);
// //       }
// //     });
// //   }
// //
// //   String _turnInstruction = '';
// //   String _turnIcon = '';
// //
// //   void _updateTurnInstructions(String instruction, String icon) {
// //     setState(() {
// //       _turnInstruction = instruction;
// //       _turnIcon = icon;
// //     });
// //   }
// //
// //   void _startNavigation() {
// //     setState(() {
// //       _isRouteSelected = true;
// //     });
// //     _navigationController.startNavigation();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Map Screen")),
// //       body: Stack(
// //         children: [
// //           FlutterMap(
// //             mapController: _mapController,
// //             options: MapOptions(
// //               initialCenter: LatLng(22, 74),
// //               initialZoom: 13.0,
// //               minZoom: 0,
// //               maxZoom: 20,
// //               // onTap: (_, __) {
// //               //   // if (_navigationController.isNavigationActive) {
// //               //   //   _selectRoute(0);
// //               //   // }
// //               // },
// //             ),
// //             children: [
// //               TileLayer(
// //                 urlTemplate: 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
// //               ),
// //               if (!_navigationController.isNavigationActive && _allRoutes.isNotEmpty)
// //                 if (!_navigationController.isNavigationActive && _allRoutes.isNotEmpty)
// //                   TappablePolylineLayer(
// //                     polylines: _allRoutes
// //                         .asMap()
// //                         .entries
// //                         .map((entry) {
// //                       int index = entry.key;
// //                       List<LatLng> route = entry.value;
// //                       return TaggedPolyline(
// //                         points: route,
// //                         strokeWidth: 4.0,
// //                         color: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
// //                         tag: 'route_$index',
// //                       );
// //                     }).toList(),
// //                     onTap: (String tag) {
// //                       if (!_navigationController.isNavigationActive) {
// //                         int tappedIndex = int.parse(tag.split('_')[1]);
// //                         _selectRoute(tappedIndex);
// //                       }
// //                     },
// //                   ),
// //               PolylineLayer(
// //                 polylines: [
// //                   Polyline(
// //                     points: _plannedRoutePoints,
// //                     strokeWidth: 4.0,
// //                     color: Colors.blue,
// //                   ),
// //                 ],
// //               ),
// //               MarkerLayer(
// //                 markers: _markers,
// //                 rotate: true,
// //               ),
// //             ],
// //           ),
// //           if (!_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               left: 16.0,
// //               right: 16.0,
// //               child: SearchWidget(
// //                 searchController: _searchController,
// //                 suggestions: _suggestions,
// //                 onSearchChanged: _onSearchChanged,
// //                 onSuggestionSelected: _onSuggestionSelected,
// //               ),
// //             ),
// //           if (_isRouteSelected && !_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               left: 16.0,
// //               right: 16.0,
// //               child: Container(
// //                 color: Colors.white,
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     Text(
// //                       'Distance: ${(_routeDetails[_selectedRouteIndex]['distance'] /
// //                           1000).toStringAsFixed(2)} km',
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                     Text(
// //                       'Duration: ${convertRemainingTimeHHMM(
// //                           (_routeDetails[_selectedRouteIndex]['duration'] / 60)
// //                               .toInt())}',
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                     const SizedBox(height: 8.0),
// //                     if (_allRoutes.length > 1)
// //                       ElevatedButton(
// //                         onPressed: () {
// //                           int nextRouteIndex = (_selectedRouteIndex + 1) %
// //                               _allRoutes.length;
// //                           _selectRoute(nextRouteIndex);
// //                         },
// //                         child: const Text('Select Alternate Route'),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           if (_navigationController.isNavigationActive)
// //             Positioned(
// //               top: 16.0,
// //               right: 16.0,
// //               child: Container(
// //                 color: Colors.white,
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Row(
// //                   children: [
// //                     if (_turnIcon.isNotEmpty)
// //                       Image.asset(
// //                         '$_turnIcon',
// //                         width: 32.0,
// //                         height: 32.0,
// //                       ),
// //                     const SizedBox(width: 8.0),
// //                     Text(
// //                       _turnInstruction,
// //                       style: const TextStyle(fontSize: 16.0),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //       floatingActionButton: Column(
// //         mainAxisAlignment: MainAxisAlignment.end,
// //         children: [
// //           FloatingActionButton(
// //             heroTag: 'zoom_in',
// //             onPressed: () =>
// //                 _mapController.move(
// //                     _mapController.camera.center, _mapController.camera.zoom + 1),
// //             child: const Icon(Icons.zoom_in),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'zoom_out',
// //             onPressed: () =>
// //                 _mapController.move(
// //                     _mapController.camera.center, _mapController.camera.zoom - 1),
// //             child: const Icon(Icons.zoom_out),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'current_location',
// //             onPressed: _onPanToCurrentLocation,
// //             child: const Icon(Icons.my_location),
// //           ),
// //           const SizedBox(height: 10),
// //           FloatingActionButton(
// //             heroTag: 'navigation',
// //             onPressed: _allRoutes.isNotEmpty
// //                 ? _navigationController.isNavigationActive
// //                 ? _navigationController.stopNavigation
// //                 : _startNavigation
// //                 : null,
// //             child: Icon(
// //               _navigationController.isNavigationActive
// //                   ? Icons.stop
// //                   : Icons.navigation,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// ///TODO: OG CODE
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

  late List<LatLng> _coveredRoutePoints = [];
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
        _plannedRoutePoints[0] = _currentLocation;
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
      appBar: AppBar(title: Text("Raptee Maps")),
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
                urlTemplate: 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
              ),
              if (!_navigationController.isNavigationActive && _allRoutes.isNotEmpty)
                TappablePolylineLayer(
                  polylines: _allRoutes
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    List<LatLng> route = entry.value;
                    return TaggedPolyline(
                      points: route,
                      strokeWidth: 4.0,
                      color: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
                      tag: 'route_$index',
                    );
                  }).toList(),
                  onTap: (String tag) {
                    if (!_navigationController.isNavigationActive) {
                      int tappedIndex = int.parse(tag.split('_')[1]);
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
                    strokeWidth: 4.0,
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
                          int nextRouteIndex = (_selectedRouteIndex + 1) %
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
                        '$_turnIcon',
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




// import 'dart:ui' as ui;
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart' as loc;
// import 'package:geocoding/geocoding.dart' as Geocoder;
//
// import '../Constants/colors.dart';
// import '../Constants/locationData.dart';
// import '../Constants/routeName.dart';
// import '../Constants/styles.dart';
// import '../Methods/hideKeyboard.dart';
// import '../Repo/direction.dart';
// import '../mapModule/component/bikeLocationModalSheetWidget.dart';
// import '../mapModule/component/locationSearchWidget.dart';
// import '../mapModule/component/onMapClickModalSheet.dart';
// import '../mapModule/nearbyChargingLocationMapScreen.dart';
// import '../mapModule/routeDirectionMapScreen.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   final MapController _mapController = MapController();
//   Color defaultPolyLineColor = Clr.mainGrey.withOpacity(0.5);
//   Color selectedPolylineColor = Clr.teal;
//
//   bool isShowMapLoading = false;
//
//   final LatLng _userLocation = LatLng(13.022420, 80.168120);
//
//   final LatLng _center = const LatLng(13.022420, 80.168120);
//
//   List<Marker> markers = [];
//   List<Polyline> polyLines = [];
//
//   Map<String, Polyline> mapOfPolylines = {};
//
//   LatLng? sourceAddressLatLng;
//
//   @override
//   void initState() {
//     super.initState();
//     isShowMapLoading = true;
//
//     // Commenting out permission check and location fetch as it is a desktop app
//     // checkLocationPermission();
//
//     // Setting current location directly
//     sourceAddressLatLng = _center;
//     LocationTempData.currentLocation = sourceAddressLatLng ?? LatLng(0, 0);
//
//     setState(() {
//       isShowMapLoading = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Clr.black,
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               center: _center,
//               zoom: 16.0,
//               onTap: (tapPosition, location) async {
//                 markers.clear();
//
//                 String _address = "",
//                     street = "",
//                     place = "",
//                     locality = "",
//                     administrative = "",
//                     postal = "",
//                     country = "",
//                     subLocality = "";
//
//                 placemarkFromCoordinates(location.latitude, location.longitude)
//                     .then((placeMarks) async {
//                   if (placeMarks.isNotEmpty) {
//                     street = placeMarks[0].subThoroughfare.toString();
//                     place = placeMarks[0].name.toString();
//                     subLocality = placeMarks[0].subLocality.toString();
//                     locality = placeMarks[0].locality.toString();
//                     administrative =
//                         placeMarks[0].administrativeArea.toString();
//                     postal = placeMarks[0].postalCode.toString();
//                     country = placeMarks[0].country.toString();
//
//                     _address =
//                     "$street$place, $subLocality, $locality, $administrative, $postal, $country";
//                     await onMapClickModalBottomSheet(
//                         parentScreenName: RouteName.homeBottomNavigationScreen,
//                         context,
//                         place,
//                         street,
//                         subLocality,
//                         _address,
//                         LatLng(location.latitude, location.longitude),
//                         LatLng(0, 0));
//                   }
//                 });
//
//                 markers.add(Marker(
//                   point: location,
//                   child: GestureDetector(
//                     onTap: () async {
//                       try {
//                         await onMapClickModalBottomSheet(
//                             parentScreenName:
//                             RouteName.homeBottomNavigationScreen,
//                             context,
//                             place,
//                             street,
//                             subLocality,
//                             _address,
//                             LatLng(location.latitude, location.longitude),
//                             LatLng(0, 0));
//                       } on Exception catch (e) {
//                         debugPrint(
//                             "Error on Showing modal Sheet: ${e.toString()}");
//                       }
//                     },
//                     child: const Icon(
//                       Icons.location_pin,
//                       color: Colors.red,
//                       size: 40,
//                     ),
//                   ),
//                 ));
//
//                 setState(() {});
//               },
//             ),
//             children: [
//               TileLayer(
//                 tileDisplay: const TileDisplay.fadeIn(),
//                 tileUpdateTransformer: TileUpdateTransformers.ignoreTapEvents,
//                 evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
//                 urlTemplate:
//                 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
//               ),
//               MarkerLayer(
//                 markers: markers,
//               ),
//               PolylineLayer(
//                 polylines: mapOfPolylines.values.toList(),
//               ),
//             ],
//           ),
//           if (isShowMapLoading &&
//               LocationTempData.currentLocation.latitude == 0 &&
//               LocationTempData.currentLocation.longitude == 0)
//             Center(
//                 child: SizedBox(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         color: Clr.teal,
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         "Fetching your current location..",
//                         textAlign: TextAlign.center,
//                         maxLines: 3,
//                         style: Style.conigenColorChangableRegularText(
//                             color: Clr.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14),
//                       )
//                     ],
//                   ),
//                 )),
//           Padding(
//             padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: LocationSearchWidget(
//                 location: "",
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Padding(
//                 padding: const EdgeInsets.only(bottom: 10, right: 20, top: 150),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     FloatingActionButton.small(
//                       heroTag: "zoom_in",
//                       backgroundColor: Colors.black,
//                       onPressed: () {
//                         double newZoom = _mapController.camera.zoom + 1;
//                         if (newZoom <= 20.5) {
//                           _mapController.move(
//                               _mapController.camera.center, newZoom);
//                         }
//                       },
//                       child: const Icon(Icons.add, color: Colors.white),
//                     ),
//                     const SizedBox(height: 5),
//                     FloatingActionButton.small(
//                       heroTag: "zoom_out",
//                       backgroundColor: Colors.black,
//                       onPressed: () {
//                         double newZoom = _mapController.camera.zoom - 1;
//                         if (newZoom >= 5) {
//                           _mapController.move(
//                               _mapController.camera.center, newZoom);
//                         }
//                       },
//                       child: const Icon(Icons.remove, color: Colors.white),
//                     ),
//                     const SizedBox(height: 5),
//                     FloatingActionButton.small(
//                       heroTag: "current_location",
//                       backgroundColor: Clr.black1,
//                       onPressed: isShowMapLoading
//                           ? null
//                           : () {
//                         setState(() {
//                           LocationTempData.currentLocation = _center;
//                         });
//                         _mapController.move(_center, 15.0);
//                       },
//                       child: Icon(Icons.my_location_outlined, color: Clr.white),
//                     ),
//                     const SizedBox(height: 5),
//                     FloatingActionButton.small(
//                       heroTag: "bike_location",
//                       backgroundColor: Clr.black1,
//                       onPressed: () async {
//                         await placemarkFromCoordinates(
//                             _userLocation.latitude, _userLocation.longitude)
//                             .then((placemarkList) {
//                           Placemark _placemark = placemarkList.last;
//
//                           String address =
//                               "${_placemark.name.toString()}${_placemark.street}${_placemark.subLocality},${_placemark.administrativeArea},${_placemark.subAdministrativeArea}+${_placemark.country}";
//
//                           bikeLocationModalBottomSheet(context, "Blaza Peralta",
//                               true, "TN 13 AB 3038", address, onModalClose: () {
//                                 printMsg("Hello CloseD");
//                               });
//                         });
//                       },
//                       child: Icon(Icons.directions_bike_outlined,
//                           color: Clr.white),
//                     ),
//                     const SizedBox(height: 5),
//                     FloatingActionButton.small(
//                       heroTag: "route_direction",
//                       backgroundColor: Clr.black1,
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 settings: const RouteSettings(
//                                     name: RouteName.sourceDestinationScreen),
//                                 builder: (context) => RouteDirectionMapScreen(
//                                   "",
//                                   "",
//                                   const LatLng(0, 0),
//                                   parentScreenName:
//                                   RouteName.sourceDestinationScreen,
//                                 )));
//                       },
//                       child: Icon(Icons.route_outlined, color: Clr.white),
//                     ),
//                     const SizedBox(height: 5),
//                     FloatingActionButton.small(
//                       heroTag: "nearby_ev",
//                       backgroundColor: Clr.black1,
//                       onPressed: isShowMapLoading
//                           ? null
//                           : () async {
//                         setState(() {
//                           isShowMapLoading = true;
//                         });
//                         try {
//                           var data = await DirectionsRepository()
//                               .searchNearbyEvChargingStations(_center);
//                           setState(() {
//                             isShowMapLoading = false;
//                           });
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   maintainState: true,
//                                   settings: const RouteSettings(
//                                       name:
//                                       RouteName.nearByChargingScreen),
//                                   builder: (context) =>
//                                       NearbyCharginStationMapScreen(
//                                           _center, data!)));
//                         } on Exception catch (e) {
//                           debugPrint(
//                               "Error on Near by Search Call: ${e.toString()}");
//                         }
//                       },
//                       child: Icon(Icons.ev_station_rounded, color: Clr.white),
//                     ),
//                   ],
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
// }