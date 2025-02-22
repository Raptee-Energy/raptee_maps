import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../Components/searchWidget.dart';
import '../Controller/mapController.dart';
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
  final GooglePlacesService _placesService = GooglePlacesService();
  final MapBoxDirectionsService _directionsService = MapBoxDirectionsService();
  LatLng? _currentLocation;
  List<dynamic> _suggestions = [];
  bool _isRouteSelected = false;
  int _selectedRouteIndex = 0;
  bool _isLoadingLocation = true;

  late NavigationController _navigationController;
  late MapAnimationController _mapAnimationController;

  late List<LatLng> _coveredRoutePoints = [];
  final List<LatLng> _plannedRoutePoints = [];
  List<LatLng> _remainingRoutePoints = [];

  String _turnInstruction = '';
  String _turnIcon = '';
  String _turnDistance = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _requestLocationPermission();
    _initializeNavigationController();
    _initializeMapAnimationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onPanToCurrentLocation();
    });
  }

  void _initializeNavigationController() {
    _navigationController = NavigationController(
      allRoutes: _allRoutes,
      directionsService: _directionsService,
    )
      ..updatePolylinePoints = _updatePolylinePoints
      ..updateCurrentLocation = _updateCurrentLocation
      ..clearNavigation = _clearNavigation
      ..updateTurnInstructions = _updateTurnInstructions
      ..updateCoveredPolyline = _updateCoveredPolyline
      ..onNavigationStart = _onNavigationStart
      ..onNavigationStop = _onNavigationStop;
  }

  void _initializeMapAnimationController() {
    _mapAnimationController = MapAnimationController(
      mapController: _mapController,
      tickerProvider: this,
    );
  }

  void _onNavigationStart() {
    _mapAnimationController.startContinuousPan();
  }

  void _onNavigationStop() {
    _mapAnimationController.stopContinuousPan();
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
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.removeWhere((marker) =>
            marker.child is Icon && (marker.child as Icon).color == Colors.red);
        _markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: _currentLocation!,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
        _mapAnimationController.updateMapCenter(_currentLocation!, 15.0,
            animated: true);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('Error getting location: $e');
    }
  }

  void _onSearchChanged(String value) {
    _placesService.debounceSearch(value, _currentLocation!, _updateSuggestions);
  }

  void _updateSuggestions(List<dynamic> results) {
    setState(() {
      _suggestions = results;
    });
  }

  Future<void> _onSuggestionSelected(dynamic suggestion) async {
    final placeDetails = await _placesService.getPlaceDetails(
      suggestion['place_id'],
      _currentLocation!,
    );
    final lat = placeDetails['geometry']['location']['lat'];
    final lng = placeDetails['geometry']['location']['lng'];
    final selectedLocation = LatLng(lat, lng);

    final avgLat = (_currentLocation!.latitude + lat) / 2;
    final avgLng = (_currentLocation!.longitude + lng) / 2;
    final midPoint = LatLng(avgLat, avgLng);

    setState(() {
      _markers.removeWhere((marker) =>
          marker.child is Icon && (marker.child as Icon).color == Colors.blue);
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
        .as(LengthUnit.Kilometer, _currentLocation!, selectedLocation);

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

    _mapAnimationController.updateMapCenter(midPoint, zoomLevel,
        animated: true);

    await _getDirections(_currentLocation!, selectedLocation);
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    try {
      final directions = await _directionsService.getDirections(start, end);
      _allRoutes.clear();
      _routeDetails.clear();
      _plannedRoutePoints.clear();
      _remainingRoutePoints.clear();
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
      _remainingRoutePoints.addAll(_allRoutes[0]);
      _selectRoute(0);
      setState(() {
        _isRouteSelected = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void _updatePolylinePoints(List<LatLng> polylinePoints) {
    setState(() {
      _polylinePoints.clear();
      _polylinePoints.addAll(polylinePoints);
      _remainingRoutePoints.clear();
      _remainingRoutePoints.addAll(polylinePoints);
    });
  }

  void _updateCurrentLocation(LatLng location, double? bearing) {
    setState(() {
      _markers.removeWhere((marker) =>
          marker.child is Icon && (marker.child as Icon).color == Colors.green);
      _currentLocation = location;
      _markers.add(
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
      _mapAnimationController.updateMapCenter(location, bearing,
          animated: true);

      if (_plannedRoutePoints.isNotEmpty) {
        _plannedRoutePoints[0] = _currentLocation!;
        _remainingRoutePoints[0] = _currentLocation!;
      }
    });
  }

  void _clearNavigation() {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentLocation ?? const LatLng(0, 0),
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
      _polylinePoints.clear();
      _coveredRoutePoints.clear();
      _plannedRoutePoints.clear();
      _remainingRoutePoints.clear();
      _allRoutes.clear();
      _routeDetails.clear();
      _isRouteSelected = false;
      _turnInstruction = '';
      _turnIcon = '';
      _turnDistance = '';
    });
  }

  void _onPanToCurrentLocation() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }
    _mapAnimationController.updateMapCenter(_currentLocation!, 8.0,
        animated: true);
    _mapAnimationController.updateZoom(8.0, animated: true);
  }

  void _selectRoute(int index) {
    if (!_navigationController.isNavigationActive) {
      setState(() {
        _selectedRouteIndex = index;
        _polylinePoints.clear();
        _polylinePoints.addAll(_allRoutes[index]);
        _remainingRoutePoints.clear();
        _remainingRoutePoints.addAll(_allRoutes[index]);
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
    Map<String, String> turnDetails = _navigationController.getTurnInstruction(
        _allRoutes[_selectedRouteIndex],
        _navigationController.currentSegmentIndex);
    setState(() {
      _turnInstruction = turnDetails['instruction'] ?? '';
      _turnIcon = turnDetails['icon'] ?? '';
      _turnDistance = turnDetails['distance'] ?? '';
    });
  }

  void _startNavigation() {
    setState(() {
      _isRouteSelected = true;
      _markers.removeWhere((marker) =>
          marker.child is Icon && (marker.child as Icon).color == Colors.blue);
    });
    _navigationController.startNavigation();
  }

  void _stopNavigation() {
    _navigationController.stopNavigation();
  }

  void _updateCoveredPolyline(List<LatLng> coveredPoints) {
    setState(() {
      _coveredRoutePoints = coveredPoints;
      if (_plannedRoutePoints.isNotEmpty && _coveredRoutePoints.isNotEmpty) {
        int coveredPointsCount = _coveredRoutePoints.length;
        if (coveredPointsCount <= _plannedRoutePoints.length) {
          _remainingRoutePoints =
              _plannedRoutePoints.sublist(coveredPointsCount - 1);
        } else {
          _remainingRoutePoints = [];
        }
      } else {
        _remainingRoutePoints = [];
      }
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
            options: const MapOptions(
              initialCenter: LatLng(22, 74),
              initialZoom: 13.0,
              minZoom: 0,
              maxZoom: 20,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://maps.raptee.com/styles/test-style/{z}/{x}/{y}.png',
              ),
              if (!_navigationController.isNavigationActive &&
                  _allRoutes.isNotEmpty)
                TappablePolylineLayer(
                  polylines: _allRoutes.asMap().entries.map((entry) {
                    int index = entry.key;
                    List<LatLng> route = entry.value;
                    return TaggedPolyline(
                      points: route,
                      strokeWidth: 4.0,
                      color: index == _selectedRouteIndex
                          ? Colors.blue
                          : Colors.grey,
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
                    points: _remainingRoutePoints,
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
          if (_isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(),
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Route ${_selectedRouteIndex + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Distance: ${(_routeDetails[_selectedRouteIndex]['distance'] / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Duration: ${convertRemainingTimeHHMM((_routeDetails[_selectedRouteIndex]['duration'] / 60).toInt())}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    if (_allRoutes.length > 1)
                      ElevatedButton(
                        onPressed: () {
                          int nextRouteIndex =
                              (_selectedRouteIndex + 1) % _allRoutes.length;
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
              left: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_turnIcon.isNotEmpty)
                      Image.asset(
                        '$_turnIcon',
                        width: 40.0,
                        height: 40.0,
                      ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _turnInstruction,
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _turnDistance.isNotEmpty ? 'in $_turnDistance' : '',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.grey),
                          ),
                        ],
                      ),
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
            onPressed: () => _mapAnimationController.updateZoom(
                _mapController.camera.zoom + 1,
                animated: true), // Animated zoom
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () => _mapAnimationController.updateZoom(
                _mapController.camera.zoom - 1,
                animated: true), // Animated zoom
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _onPanToCurrentLocation,
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'navigation',
            onPressed: _allRoutes.isNotEmpty
                ? _navigationController.isNavigationActive
                    ? _stopNavigation
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
