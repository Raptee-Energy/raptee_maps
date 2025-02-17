// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:latlong2/latlong.dart';

class NearbyChargingStationDataModel {
  String? name = "";
  String? address = "";
  LatLng? location;
  bool? isAvailable = false;
  String? power;
  int? reports;
  double? distance;
  String? chargerType;
  double? rating;
  int? availableSlot;
  int? workingHour;
  NearbyChargingStationDataModel({
    this.name,
    this.address,
    this.location,
    this.isAvailable,
    this.power,
    this.reports,
    this.distance,
    this.chargerType,
    this.rating,
    this.availableSlot,
    this.workingHour,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'address': address,
      'location': {
        "lat": location?.latitude ?? 0,
        "lng": location?.latitude ?? 0
      },
      'isAvailable': isAvailable,
      'power': power,
      'reports': reports,
      'distance': distance,
      'chargerType': chargerType,
      'rating': rating,
      'availableSlot': availableSlot,
      'workingHour': workingHour,
    };
  }

  factory NearbyChargingStationDataModel.fromMap(Map<String, dynamic> map) {
    return NearbyChargingStationDataModel(
      name: map['name'] as String,
      address: map['address'] as String,
      location: map['location'] != null
          ? LatLng(map['location']["lat"], map['location']["lng"])
          : null,
      isAvailable: map['isAvailable'] as bool,
      power: map['power'] != null ? map['power'] as String : null,
      reports: map['reports'] != null ? map['reports'] as int : null,
      distance: map['distance'] != null ? map['distance'] as double : null,
      chargerType:
          map['chargerType'] != null ? map['chargerType'] as String : null,
      rating: map['rating'] != null ? map['rating'] as double : null,
      availableSlot:
          map['availableSlot'] != null ? map['availableSlot'] as int : null,
      workingHour:
          map['workingHour'] != null ? map['workingHour'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NearbyChargingStationDataModel.fromJson(String source) =>
      NearbyChargingStationDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
