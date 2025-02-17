// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LocationHistoryDataModel {
  String? locationTitle;
  String? locationDescription;
  double? latitude;
  double? longitude;
  LocationHistoryDataModel({
    this.locationTitle,
    this.locationDescription,
    this.latitude,
    this.longitude,
  });

  LocationHistoryDataModel copyWith({
    String? locationTitle,
    String? locationDescription,
    double? latitude,
    double? longitude,
  }) {
    return LocationHistoryDataModel(
      locationTitle: locationTitle ?? this.locationTitle,
      locationDescription: locationDescription ?? this.locationDescription,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'locationTitle': locationTitle,
      'locationDescription': locationDescription,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationHistoryDataModel.fromMap(Map<String, dynamic> map) {
    return LocationHistoryDataModel(
      locationTitle:
          map['locationTitle'] != null ? map['locationTitle'] as String : null,
      locationDescription: map['locationDescription'] != null
          ? map['locationDescription'] as String
          : null,
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationHistoryDataModel.fromJson(String source) =>
      LocationHistoryDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LocationHistoryDataModel(locationTitle: $locationTitle, locationDescription: $locationDescription, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(covariant LocationHistoryDataModel other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode;
  }
}
