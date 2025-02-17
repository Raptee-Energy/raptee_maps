import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../Constants/locationData.dart';
import '../Models/nearbyChargingStationDataModel.dart';
import '../Models/sourceDestinationETA.dart';
import '../methods/hideKeyboard.dart';
import '../secret/.env.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  Future<Map<String, dynamic>?> getTheDirection(
      LatLng origin, LatLng destination, bool alternative, String mode,
      {String sourceAddress = "", String destinationAddress = ""}) async {
    try {
      final Dio dio = Dio();
      final response = await dio.get(_baseUrl, queryParameters: {
        'origin': origin.latitude != 0 && origin.longitude != 0
            ? '${origin.latitude},${origin.longitude}'
            : sourceAddress,
        'destination': destination.latitude != 0 && destination.longitude != 0
            ? '${destination.latitude},${destination.longitude}'
            : destinationAddress,
        'mode': mode,
        'alternatives': alternative,
        'key': googleAPIKey,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        print("response" + data.toString());

        return data;
      }
    } on Exception catch (e) {
      debugPrint("Error in Route API Call: ${e.toString()}");
    }
    return null;
  }

  Future<List<NearbyChargingStationDataModel>?> searchNearbyEvChargingStations(
      LatLng latLng,
      {double radius = 10000}) async {
    var url = 'https://places.googleapis.com/v1/places:searchNearby';
    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': googleAPIKey,
      "rankby": "distance",
      'X-Goog-FieldMask':
          'places.displayName,places.formattedAddress,places.evChargeOptions,places.businessStatus,places.location,places.currentOpeningHours,places.currentSecondaryOpeningHours,places.primaryType,places.primaryTypeDisplayName,places.types'
    };

    var body = json.encode({
      "includedTypes": ["electric_vehicle_charging_station"],
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": latLng.latitude,
            "longitude": latLng.longitude
          },
          "radius": radius
        }
      }
    });

    try {
      var response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (kDebugMode) {
          print(data.toString());
        }
        List<dynamic> list = data["places"];

        List<NearbyChargingStationDataModel> nearLocationList = [];
        list.map((place) {
          String chargerType = "";
          bool? isAvailable;
          int? chargingSlot;
          String power = "";
          if (place["evChargeOptions"] != null &&
              place["evChargeOptions"]["connectorAggregation"] != null &&
              place["evChargeOptions"]["connectorAggregation"][0]["type"] !=
                  null) {
            chargerType =
                place["evChargeOptions"]["connectorAggregation"][0]["type"];
          }
          if (place["evChargeOptions"] != null &&
              place["evChargeOptions"]["connectorAggregation"] != null &&
              place["evChargeOptions"]["connectorAggregation"][0]
                      ["maxChargeRateKw"] !=
                  null) {
            power = place["evChargeOptions"]["connectorAggregation"][0]
                    ["maxChargeRateKw"]
                .toString();
          }
          if (place["evChargeOptions"] != null &&
              place["evChargeOptions"]["connectorCount"] != null) {
            chargingSlot = place["evChargeOptions"]["connectorCount"];
          }
          if (place["currentOpeningHours"] != null &&
              place["currentOpeningHours"]["openNow"] != null) {
            isAvailable = place["currentOpeningHours"]["openNow"];
          }

          nearLocationList.add(NearbyChargingStationDataModel(
            name: place["displayName"]["text"],
            address: place["formattedAddress"],
            isAvailable: isAvailable,
            availableSlot: chargingSlot,
            chargerType: chargerType,
            distance: null,
            location: LatLng(
                place["location"]["latitude"], place["location"]["longitude"]),
            power: power,
            rating: null,
            reports: null,
            workingHour: 24,
          ));
        }).toList();

        return nearLocationList;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error in NearByCharging API Call: ${e.toString()}");
    }
    return [];
  }

  Future<SourceDestinationEtdDataModel?> getEstimatedTimeDistanceApiCall(
      LatLng? source,
      LatLng? destination,
      String? sourceAdress,
      String? destinationAddress) async {
    final String googleMapsKey = googleAPIKey;

    if (source == null && destination == null) {
      if (sourceAdress != null && destinationAddress != null) {}
    } else {}

    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$source&destinations=$destination&key=$googleMapsKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data.toString());
        var elements = data['rows'][0]['elements'][0];

        print('Distance: ${elements['distance']['text']}');
        print('Duration: ${elements['duration']['text']}');
        return SourceDestinationEtdDataModel(
            destinationAddress: data['destination_addresses'][0],
            sourceAddress: data['origin_addresses'][0],
            distance: elements['distance']['text'],
            time: elements['duration']['text']);
      } else {
        print('Failed to load distance and time');
      }
    } on Exception catch (e) {
      debugPrint(" Error in Distance Calculation API call : ${e.toString()}");
    }
    return null;
  }

  Future<List<dynamic>> makeSuggestion(String input) async {
    final apiKey = googleAPIKey;

    if (input.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=${LocationTempData.currentLocation.latitude},${LocationTempData.currentLocation.longitude}&radius=5000&key=$apiKey',
          ),
        );

        if (response.statusCode == 200) {
          printMsg("We got the response");
          printMsg(jsonDecode(response.body).toString());

          return jsonDecode(response.body)["predictions"];
        } else {
          printMsg(
              "Error fetching autocomplete predictions. Status code: ${response.statusCode}");
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          printMsg("Error in AutoSuggest API Call: $e");
        }
      }
    }

    return [];
  }
}
