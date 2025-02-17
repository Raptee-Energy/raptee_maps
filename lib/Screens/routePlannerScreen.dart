// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../Services/googlePlacesService.dart';
//
// class RoutePlannerScreen extends StatefulWidget {
//   @override
//   _RoutePlannerScreenState createState() => _RoutePlannerScreenState();
// }
//
// class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
//   final MapController mapController = MapController();
//   LatLng? currentLocation;
//   List<Marker> markers = [];
//   List<Polyline> routes = [];
//   TextEditingController _searchController = TextEditingController();
//   List<dynamic> _placeSuggestions = [];
//   LatLng? destination;
//
//   final String googleApiKey = 'AIzaSyC_tOwI6MLem1uy6pZbDUrV1MDfxoRwU3Q';
//   final String hereApiKey = 'RK3bPi3l7Bt5pznTMnvB0MXR3JP6WAk0JQJEjZHbpS4';
//
//   GooglePlacesService? _placesService;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//     _placesService = GooglePlacesService();
//   }
//
//   Future<void> getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//         updateCurrentLocationMarker();
//       });
//       mapController.move(currentLocation!, 15);
//       print('Current location: $currentLocation');
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }
//
//   void updateCurrentLocationMarker() {
//     if (currentLocation != null) {
//       markers = [
//         Marker(
//           width: 40.0,
//           height: 40.0,
//           point: currentLocation!,
//           child: Container(
//             child: Icon(
//               Icons.my_location,
//               color: Colors.blue,
//               size: 30,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ];
//     }
//     print('Markers updated: $markers'); // Debug print
//   }
//
//   void searchPlaces(String query) {
//     if (currentLocation != null) {
//       _placesService!.debounceSearch(query, currentLocation!, (suggestions) {
//         setState(() {
//           _placeSuggestions = suggestions;
//         });
//         print('Place suggestions: $_placeSuggestions');
//       });
//     }
//   }
//
//   Future<void> selectPlace(dynamic place) async {
//     final details = await _placesService!.getPlaceDetails(place['place_id'], currentLocation!);
//     setState(() {
//       destination = LatLng(
//         details['geometry']['location']['lat'],
//         details['geometry']['location']['lng'],
//       );
//       markers.add(
//         Marker(
//           width: 40.0,
//           height: 40.0,
//           point: destination!,
//           child: Icon(Icons.location_on, color: Colors.red, size: 40),
//         ),
//       );
//       _placeSuggestions = [];
//       _searchController.text = place['description'];
//     });
//     print('Destination selected: $destination'); // Debug print
//     calculateRoute();
//   }
//
//   Future<void> calculateRoute() async {
//     if (currentLocation != null && destination != null) {
//       final url = Uri.parse(
//         'https://router.hereapi.com/v8/routes?transportMode=car&origin=${currentLocation!.latitude},${currentLocation!.longitude}&destination=${destination!.latitude},${destination!.longitude}&return=polyline&apikey=$hereApiKey',
//       );
//
//       try {
//         final response = await http.get(url);
//         print('API Response status code: ${response.statusCode}'); // Debug print
//         if (response.statusCode == 200) {
//           print("API Call made to: $url");
//           final data = json.decode(response.body);
//           print('API Response data: $data'); // Debug print
//
//           final List<LatLng> routePoints = [];
//
//           if (data['routes'] != null && data['routes'].isNotEmpty) {
//             final String polyline = data['routes'][0]['sections'][0]['polyline'];
//             final List<dynamic> decodedPolyline = _decodePolyline(polyline);
//             print('Decoded polyline: $decodedPolyline'); // Debug print
//
//             for (int i = 0; i < decodedPolyline.length; i += 2) {
//               routePoints.add(LatLng(decodedPolyline[i], decodedPolyline[i + 1]));
//             }
//
//             setState(() {
//               routes = [
//                 Polyline(
//                   points: routePoints,
//                   strokeWidth: 4,
//                   color: Colors.blue,
//                 ),
//               ];
//             });
//             print('Routes updated: $routes'); // Debug print
//
//             // Fit the map to show the entire route
//             mapController.fitBounds(
//               LatLngBounds.fromPoints(routePoints),
//               options: FitBoundsOptions(padding: EdgeInsets.all(50)),
//             );
//           }
//         } else {
//           print('Failed to calculate route. Status code: ${response.statusCode}');
//         }
//       } catch (e) {
//         print('Error calculating route: $e');
//       }
//     }
//   }
//
//   List<dynamic> _decodePolyline(String encoded) {
//     List<dynamic> points = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       points.add(lat / 1E5);
//       points.add(lng / 1E5);
//     }
//     return points;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Route Planner')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for a destination',
//                 suffixIcon: Icon(Icons.search),
//               ),
//               onChanged: searchPlaces,
//             ),
//           ),
//           if (_placeSuggestions.isNotEmpty)
//             Container(
//               height: 200,
//               child: ListView.builder(
//                 itemCount: _placeSuggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_placeSuggestions[index]['description']),
//                     onTap: () => selectPlace(_placeSuggestions[index]),
//                   );
//                 },
//               ),
//             ),
//           Expanded(
//             child: FlutterMap(
//               mapController: mapController,
//               options: MapOptions(
//                 center: currentLocation ?? LatLng(0, 0),
//                 zoom: 15.0,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                   'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
//                 ),
//                 MarkerLayer(markers: markers),
//                 PolylineLayer(polylines: routes),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
