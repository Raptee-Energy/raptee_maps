import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Components/currentLocationButton.dart';
import '../Components/mapWidget.dart';
import '../Components/navigationButton.dart';
import '../Components/routeDetailsPanel.dart';
import '../Components/searchWidget.dart';
import '../Components/turnInstructionWidget.dart';
import '../Components/zoomControls.dart';
import '../Constants/styles.dart';
import '../Controller/mapController.dart';
import '../Controller/navigationController.dart';
import '../Services/googlePlacesService.dart';
import '../Services/locationService.dart';
import '../Services/mapBoxDirectionService.dart';
import '../Package/tappablePolyline.dart';
import '../utils/mapConfig.dart';
import '../utils/markerManager.dart';
import '../utils/routeDataManager.dart';

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
  final List<LatLng> _coveredRoutePoints = [];
  final List<LatLng> _plannedRoutePoints = [];
  final List<LatLng> _remainingRoutePoints = [];

  final TextEditingController _searchController = TextEditingController();
  final GooglePlacesService _placesService = GooglePlacesService();
  final MapBoxDirectionsService _directionsService = MapBoxDirectionsService();
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  List<dynamic> _suggestions = [];
  bool _isRouteSelected = false;
  int _selectedRouteIndex = 0;
  bool _isLoadingLocation = true;

  late NavigationController _navigationController;
  late MapAnimationController _mapAnimationController;
  late MarkerManager _markerManager;
  late RouteDataManager _routeDataManager;

  String _turnInstruction = '';
  String _turnIcon = '';
  String _turnDistance = '';

  @override
  void initState() {
    super.initState();
    _initServicesAndControllers();
    _initManagers(); // Initialize managers
    _fetchInitialData();
  }

  void _initServicesAndControllers() {
    _initializeNavigationController();
    _initializeMapAnimationController();
  }

  void _initManagers() {
    _markerManager = MarkerManager(markers: _markers, setState: setState);
    _routeDataManager = RouteDataManager(
      markers: _markers,
      polylinePoints: _polylinePoints,
      allRoutes: _allRoutes,
      routeDetails: _routeDetails,
      coveredRoutePoints: _coveredRoutePoints,
      plannedRoutePoints: _plannedRoutePoints,
      remainingRoutePoints: _remainingRoutePoints,
      isRouteSelected: _isRouteSelected,
      selectedRouteIndex: _selectedRouteIndex,
      setState: setState,
      directionsService: _directionsService,
      navigationController: _navigationController,
    );
  }

  void _fetchInitialData() {
    _getCurrentLocation();
    _requestLocationPermission();
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
    try {
      await _locationService.requestLocationPermission();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    _currentLocation = await _locationService.getCurrentLocation();

    setState(() {
      _isLoadingLocation = false;
      if (_currentLocation != null) {
        _markerManager.updateCurrentLocationMarker(_currentLocation!);
        _onPanToCurrentLocation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location.')),
        );
      }
    });
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

    final midPoint = LatLng((_currentLocation!.latitude + lat) / 2,
        (_currentLocation!.longitude + lng) / 2);

    setState(() {
      _markerManager.removeBlueMarkers();
      _markerManager.removeRedMarkers();
      _markerManager.addBlueMarker(selectedLocation);
      _searchController.clear();
      _suggestions = [];
    });

    final distance = const Distance()
        .as(LengthUnit.Kilometer, _currentLocation!, selectedLocation);

    LatLngBounds bounds = LatLngBounds(_currentLocation!, selectedLocation);
    bounds.extend(_currentLocation!);
    bounds.extend(selectedLocation);
    LatLng center = bounds.center;
    double zoomLevel = MapConfig.getZoomLevelForDistance(distance);

    _mapAnimationController.updateMapCenter(midPoint, zoomLevel,
        animated: true);
    await _routeDataManager.getDirections(_currentLocation!, selectedLocation);
  }

  void _updatePolylinePoints(List<LatLng> polylinePoints) {
    _routeDataManager.updatePolylinePoints(polylinePoints);
  }

  void _updateCurrentLocation(LatLng location, double? bearing) {
    setState(() {
      _markerManager.removeGreenMarkers();
      _currentLocation = location;
      _markerManager.addGreenNavigationMarker(location);
      _mapAnimationController.updateMapCenter(location, bearing,
          animated: true);

      if (_plannedRoutePoints.isNotEmpty) {
        _plannedRoutePoints[0] = _currentLocation!;
        _remainingRoutePoints[0] = _currentLocation!;
      }
    });
  }

  void _clearNavigation() {
    _routeDataManager.clearNavigation(_currentLocation ?? const LatLng(0, 0));
  }

  void _onPanToCurrentLocation() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }
    _mapAnimationController.updateMapCenter(_currentLocation!, 0.0,
        zoomLevel: 15.0, animated: true);
  }

  void _selectRoute(int index) {
    _routeDataManager.selectRoute(index);
  }

  void _updateTurnInstructions(String instruction, String icon) {
    Map<String, String> turnDetails = _navigationController.getTurnInstruction(
        _allRoutes[_routeDataManager.selectedRouteIndex],
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
      _markerManager.removeRedMarkers();
      _markerManager
          .removeRedMarkers(); // removing twice is redundant, kept for original logic.
      _routeDataManager.isRouteSelected =
          true; //update RouteDataManager's state
    });
    _navigationController.startNavigation();
  }

  void _stopNavigation() {
    _navigationController.stopNavigation();
  }

  void _updateCoveredPolyline(List<LatLng> coveredPoints) {
    _routeDataManager.updateCoveredPolyline(coveredPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Raptee Maps",
        style: Style.conigenColorChangableRegularText(color: Colors.black),
      )),
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            markers: _markers,
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
            tappablePolylineLayer: (!_navigationController.isNavigationActive &&
                    _allRoutes.isNotEmpty)
                ? TappablePolylineLayer(
                    polylines: _allRoutes.asMap().entries.map((entry) {
                      int index = entry.key;
                      List<LatLng> route = entry.value;
                      return TaggedPolyline(
                        points: route,
                        strokeWidth: 4.0,
                        color: index == _routeDataManager.selectedRouteIndex
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
                  )
                : null,
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
          if (_routeDataManager.isRouteSelected &&
              !_navigationController.isNavigationActive)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: RouteDetailsWidget(
                selectedRouteIndex: _routeDataManager.selectedRouteIndex,
                routeDetails: _routeDetails,
                routeCount: _allRoutes.length,
                onSelectNextRoute: () {
                  int nextRouteIndex =
                      (_routeDataManager.selectedRouteIndex + 1) %
                          _allRoutes.length;
                  _selectRoute(nextRouteIndex);
                },
              ),
            ),
          if (_navigationController.isNavigationActive)
            Positioned(
              top: 16.0,
              right: 16.0,
              left: 16.0,
              child: TurnInstructionsWidget(
                turnInstruction: _turnInstruction,
                turnIcon: _turnIcon,
                turnDistance: _turnDistance,
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ZoomControls(mapAnimationController: _mapAnimationController),
          const SizedBox(height: 10),
          CurrentLocationButton(
            mapAnimationController: _mapAnimationController,
            isLoadingLocation: _isLoadingLocation,
            onPanToCurrentLocation: _getCurrentLocation,
          ),
          const SizedBox(height: 10),
          NavigationButton(
            navigationController: _navigationController,
            hasRoutes: _allRoutes.isNotEmpty,
            onStartNavigation: _startNavigation,
            onStopNavigation: _stopNavigation,
          ),
        ],
      ),
    );
  }
}
