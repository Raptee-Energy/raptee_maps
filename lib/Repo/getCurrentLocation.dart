// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:nmea/nmea.dart' as nmea;
//
// // Dummy NMEA sentences for demonstration. In a real scenario, you would read these from a serial port or file.
// Stream<String> nmeaStream() async* {
//   await Future.delayed(Duration(seconds: 1)); // Simulate delay
//   yield "\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47"; // Sample NMEA sentence
// }
//
// Future<LatLng> getCurrentLocation() async {
//   // Create a stream of NMEA sentences
//   final stream = nmeaStream().transform(nmea.NmeaDecoder(onlyAllowValid: true)
//     ..registerTalkerSentence(GgaSentence.id, (line) => GgaSentence(raw: line)));
//
//   // Listen to the stream and extract location data
//   await for (final sentence in stream) {
//     if (sentence is GgaSentence) {
//       final lat = sentence.latitude;
//       final lng = sentence.longitude;
//       final latLng = LatLng(lat, lng);
//
//       debugPrint("Current Location: $lat,$lng");
//       return latLng;
//     }
//   }
//
//   // Fallback in case no location data is found
//   return LatLng(0, 0);
// }
//
// // Custom GGA sentence class to extract latitude and longitude
// class GgaSentence extends nmea.TalkerSentence {
//   static const String id = "GGA";
//
//   GgaSentence({required super.raw});
//
//   double get latitude {
//     final rawLat = fields[1];
//     final latHemisphere = fields[2];
//     final degrees = double.parse(rawLat.substring(0, 2));
//     final minutes = double.parse(rawLat.substring(2));
//     var lat = degrees + minutes / 60.0;
//     if (latHemisphere == 'S') lat = -lat;
//     return lat;
//   }
//
//   double get longitude {
//     final rawLng = fields[3];
//     final lngHemisphere = fields[4];
//     final degrees = double.parse(rawLng.substring(0, 3));
//     final minutes = double.parse(rawLng.substring(3));
//     var lng = degrees + minutes / 60.0;
//     if (lngHemisphere == 'W') lng = -lng;
//     return lng;
//   }
// }
