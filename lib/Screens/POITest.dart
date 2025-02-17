import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceSearchMap extends StatefulWidget {
  @override
  _PlaceSearchMapState createState() => _PlaceSearchMapState();
}

class _PlaceSearchMapState extends State<PlaceSearchMap> {
  final MapController mapController = MapController();
  LatLng? currentLocation;
  List<Marker> markers = [];
  Map<String, dynamic>? selectedPlace;

  final String apiKey = 'RK3bPi3l7Bt5pznTMnvB0MXR3JP6WAk0JQJEjZHbpS4';
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hotels', 'color': Colors.blue},
    {'name': 'Restaurants', 'color': Colors.red},
    {'name': 'Hospitals', 'color': Colors.green},
    {'name': 'Schools', 'color': Colors.orange},
    {'name': 'Banks', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        updateCurrentLocationMarker();
      });
      mapController.move(currentLocation!, 15);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void updateCurrentLocationMarker() {
    if (currentLocation != null) {
      markers = [
        Marker(
          width: 40.0,
          height: 40.0,
          point: currentLocation!,
          child:  Container(
            child: Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 30,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        ...markers,
      ];
    }
  }

  Future<void> searchPlaces(String category, Color markerColor) async {
    if (currentLocation == null) return;

    final url = Uri.parse(
      'https://discover.search.hereapi.com/v1/discover?in=circle:${currentLocation!.latitude},${currentLocation!.longitude};r=1000&q=$category&apiKey=$apiKey',
    );

    try {
      print("Attempting to call API: $url");
      final response = await http.get(url);
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("API CALL MADE TO $url");
        final data = json.decode(response.body);
        setState(() {
          markers = (data['items'] as List).map((item) {
            try {
              final position = LatLng(
                item['position']['lat'],
                item['position']['lng'],
              );
              return Marker(
                width: 80.0,
                height: 80.0,
                point: position,
                child:  GestureDetector(
                  onTap: () => showDetails(item),
                  child: Icon(Icons.location_on, color: markerColor),
                ),
              );
            } catch (e) {
              print("Error creating marker: $e");
              return null;
            }
          }).whereType<Marker>().toList();
          updateCurrentLocationMarker();
          print("Number of markers: ${markers.length}");
        });
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {});
        });
      } else {
        print('Failed to load places. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error searching places: $e');
    }
  }

  void showDetails(Map<String, dynamic> place) {
    setState(() {
      selectedPlace = place;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place Search Map')),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentLocation ?? LatLng(0, 0),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces(category['name'], category['color']),
                    child: Text(category['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: category['color'],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: selectedPlace != null
                  ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedPlace!['title'], style: Theme.of(context).textTheme.displayMedium),
                    SizedBox(height: 8),
                    Text(selectedPlace!['address']['label']),
                    SizedBox(height: 8),
                    Text('Categories: ${(selectedPlace!['categories'] as List).map((cat) => cat['name']).join(', ')}'),
                    SizedBox(height: 8),
                    Text('Phone: ${selectedPlace!['contacts']?[0]?['phone']?[0]?['value'] ?? 'N/A'}'),
                    SizedBox(height: 8),
                    Text('Website: ${selectedPlace!['contacts']?[0]?['www']?[0]?['value'] ?? 'N/A'}'),
                  ],
                ),
              )
                  : Center(child: Text('Select a place to see details')),
            ),
          ),
        ],
      ),
    );
  }
}