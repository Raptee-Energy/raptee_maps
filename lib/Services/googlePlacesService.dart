import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GooglePlacesService {
  Timer? _debounce;

  GooglePlacesService();

  Future<Map<String, dynamic>> getPlaceDetails(String placeId, LatLng currentLocation) async {
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;
    final url =
        'https://raptee-places-dot-raptee-engine.el.r.appspot.com/place/placeDetails?place_id=$placeId&currentLatitude=$lat&currentLongitude$lng';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print("API CALL MADE TO: $url");
      print("$placeId");
      print("${jsonDecode(response.body)['data']['result']} ");
          return jsonDecode(response.body)['data']['result'];
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<List<dynamic>> _fetchPlaceSuggestions(String input, LatLng currentLocation) async {
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;
    final String url = 'https://raptee-places-dot-raptee-engine.el.r.appspot.com/place/suggestPlace?input=$input&currentLatitude=$lat&currentLongitude=$lng';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print("API CALL MADE TO: $url");
      print("$input");
      final json = jsonDecode(response.body);
      print("${json['data']['predictions']} ");

      return json['data']['predictions'];

    } else {
      throw Exception('Failed to fetch place suggestions');
    }
  }

  void debounceSearch(String query, LatLng currentLocation, void Function(List<dynamic>) updateSuggestions) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await _fetchPlaceSuggestions(query, currentLocation);
      updateSuggestions(results);
    });
  }
}
