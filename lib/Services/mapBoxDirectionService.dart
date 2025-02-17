import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapBoxDirectionsService {
  MapBoxDirectionsService();
  Future<List<Map<String, dynamic>>> getDirections(
      LatLng start, LatLng end) async {
    final String url =
        'https://raptee-navigation-dot-raptee-engine.el.r.appspot.com/maps/getRoute?points=${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    print("$url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print("Direction API call made to: $url");

      final data = json.decode(response.body);
      print("Data: $data");

      return (data['data']['routes'] as List).map((route) {
        final coordinates = route['geometry']['coordinates'] as List;
        final polylinePoints =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        return {
          'points': polylinePoints,
          'distance': route['distance'],
          'duration': route['duration'],
          'summary': route['legs'][0]['summary'],
          'weight_typical': route['weight_typical'],
          'duration_typical': route['duration_typical'],
          'weight_name': route['weight_name'],
          'weight': route['weight'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
