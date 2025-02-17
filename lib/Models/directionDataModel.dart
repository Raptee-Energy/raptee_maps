// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:latlong2/latlong.dart';
//
// class LatLngModel {
//   double lat = 0;
//   double lng = 0;
//   LatLngModel({
//     required this.lat,
//     required this.lng,
//   });
//
//   LatLngModel copyWith({
//     double? lat,
//     double? lng,
//   }) {
//     return LatLngModel(
//       lat: lat ?? this.lat,
//       lng: lng ?? this.lng,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'lat': lat,
//       'lng': lng,
//     };
//   }
//
//   factory LatLngModel.fromMap(Map<String, dynamic> map) {
//     return LatLngModel(
//       lat: map['lat'] as double,
//       lng: map['lng'] as double,
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory LatLngModel.fromJson(String source) =>
//       LatLngModel.fromMap(json.decode(source) as Map<String, dynamic>);
//
//   @override
//   String toString() => 'LatLngModel(lat: $lat, lng: $lng)';
//
//   @override
//   bool operator ==(covariant LatLngModel other) {
//     if (identical(this, other)) return true;
//
//     return other.lat == lat && other.lng == lng;
//   }
//
//   @override
//   int get hashCode => lat.hashCode ^ lng.hashCode;
// }
//
// class LocationBoundModel {
//   LatLng? northest;
//   LatLng? southest;
//   LocationBoundModel({
//     this.northest,
//     this.southest,
//   });
//
//   LocationBoundModel copyWith({
//     LatLng? northest,
//     LatLng? southest,
//   }) {
//     return LocationBoundModel(
//       northest: northest ?? this.northest,
//       southest: southest ?? this.southest,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'northest': {
//         "lat": northest?.latitude,
//         "lng": northest?.longitude,
//       },
//       'southest': {
//         "lat": southest?.latitude,
//         "lng": southest?.longitude,
//       },
//     };
//   }
//
//   factory LocationBoundModel.fromMap(Map<String, dynamic> map) {
//     return LocationBoundModel(
//       northest: map['northest'] != null
//           ? LatLng(map['northest']["lat"], map['northest']["lng"])
//           : null,
//       southest: map['southest'] != null
//           ? LatLng(map['southest']["lat"], map['southest']["lng"])
//           : null,
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory LocationBoundModel.fromJson(String source) =>
//       LocationBoundModel.fromMap(json.decode(source) as Map<String, dynamic>);
//
//   @override
//   String toString() =>
//       'LocationBoundModel(northest: $northest, southest: $southest)';
//
//   @override
//   bool operator ==(covariant LocationBoundModel other) {
//     if (identical(this, other)) return true;
//
//     return other.northest == northest && other.southest == southest;
//   }
//
//   @override
//   int get hashCode => northest.hashCode ^ southest.hashCode;
// }
//
// class DirectionRouteModel {
//   LocationBoundModel? bounds;
//   String points = "";
//   DirectionRouteModel({
//     this.bounds,
//     required this.points,
//   });
//
//   DirectionRouteModel copyWith({
//     LocationBoundModel? bounds,
//     String? points,
//   }) {
//     return DirectionRouteModel(
//       bounds: bounds ?? this.bounds,
//       points: points ?? this.points,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'bounds': bounds?.toMap(),
//       'points': points,
//     };
//   }
//
//   factory DirectionRouteModel.fromMap(Map<String, dynamic> map) {
//     return DirectionRouteModel(
//       bounds: map['bounds'] != null
//           ? LocationBoundModel.fromMap(map['bounds'] as Map<String, dynamic>)
//           : null,
//       points: map['overview_polyline']['points'] as String,
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory DirectionRouteModel.fromJson(String source) =>
//       DirectionRouteModel.fromMap(json.decode(source) as Map<String, dynamic>);
//
//   @override
//   String toString() => 'DirectionRouteModel(bounds: $bounds, points: $points)';
//
//   @override
//   bool operator ==(covariant DirectionRouteModel other) {
//     if (identical(this, other)) return true;
//
//     return other.bounds == bounds && other.points == points;
//   }
//
//   @override
//   int get hashCode => bounds.hashCode ^ points.hashCode;
// }
//
// class RouteDataMode {
//   List<DirectionRouteModel> routes = [];
//   RouteDataMode({
//     required this.routes,
//   });
//
//   RouteDataMode copyWith({
//     List<DirectionRouteModel>? routes,
//   }) {
//     return RouteDataMode(
//       routes: routes ?? this.routes,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'routes': routes.map((x) => x.toMap()).toList(),
//     };
//   }
//
//   factory RouteDataMode.fromMap(Map<String, dynamic> map) {
//     return RouteDataMode(
//       routes: List<DirectionRouteModel>.from(
//         (map['routes'] as List<int>).map<DirectionRouteModel>(
//           (x) => DirectionRouteModel.fromMap(x as Map<String, dynamic>),
//         ),
//       ),
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory RouteDataMode.fromJson(String source) =>
//       RouteDataMode.fromMap(json.decode(source) as Map<String, dynamic>);
//
//   @override
//   String toString() => 'RouteDataMode(routes: $routes)';
//
//   @override
//   bool operator ==(covariant RouteDataMode other) {
//     if (identical(this, other)) return true;
//
//     return listEquals(other.routes, routes);
//   }
//
//   @override
//   int get hashCode => routes.hashCode;
// }
