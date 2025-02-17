// // import 'package:latlong2/latlong.dart';
// //
// // class ExtraPointsService {
// //   final double intervalMeters = 2.0;
// //   final double segmentDistanceThreshold = 10.0;
// //
// //   List<LatLng> addExtraPoints(List<LatLng> originalPoints) {
// //     List<LatLng> allPoints = [];
// //
// //     for (int i = 0; i < originalPoints.length - 1; i++) {
// //       LatLng start = originalPoints[i];
// //       LatLng end = originalPoints[i + 1];
// //       allPoints.add(start);
// //
// //       double distance = const Distance().as(LengthUnit.Meter, start, end);
// //
// //       if (distance > segmentDistanceThreshold) {
// //         int numExtraPoints = (distance / intervalMeters).floor();
// //
// //         for (int j = 1; j <= numExtraPoints; j++) {
// //           double fraction = j * intervalMeters / distance;
// //           double lat = start.latitude + fraction * (end.latitude - start.latitude);
// //           double lng = start.longitude + fraction * (end.longitude - start.longitude);
// //           allPoints.add(LatLng(lat, lng));
// //         }
// //       } else {
// //         allPoints.add(end);
// //       }
// //     }
// //
// //     return allPoints;
// //   }
// // }
//
// import 'package:latlong2/latlong.dart';
//
// ///DYNAMIC EXTRA POINTS UPDATE
// // import 'package:latlong2/latlong.dart';
// //
// // class ExtraPointsService {
// //   final double intervalMeters = 1500.0;
// //   final double segmentDistanceThreshold = 10.0;
// //   final double updateThreshold = 500.0;
// //
// //   List<LatLng> addExtraPoints(List<LatLng> originalPoints, LatLng currentLocation) {
// //     List<LatLng> allPoints = [];
// //     double totalDistance = 0;
// //     int lastPlottedIndex = 0;
// //
// //     for (int i = 0; i < originalPoints.length - 1; i++) {
// //       LatLng start = originalPoints[i];
// //       LatLng end = originalPoints[i + 1];
// //       double segmentDistance = const Distance().as(LengthUnit.Meter, start, end);
// //       totalDistance += segmentDistance;
// //
// //       if (totalDistance > intervalMeters || i == originalPoints.length - 2) {
// //         List<LatLng> segmentPoints = _plotSegment(originalPoints.sublist(lastPlottedIndex, i + 2), currentLocation);
// //         allPoints.addAll(segmentPoints);
// //         lastPlottedIndex = i + 1;
// //         totalDistance = 0;
// //       }
// //     }
// //
// //     return allPoints;
// //   }
// //
// //   List<LatLng> _plotSegment(List<LatLng> segmentPoints, LatLng currentLocation) {
// //     List<LatLng> plotted = [];
// //     double remainingDistance = const Distance().as(LengthUnit.Meter, currentLocation, segmentPoints.last);
// //
// //     for (int i = 0; i < segmentPoints.length - 1; i++) {
// //       LatLng start = segmentPoints[i];
// //       LatLng end = segmentPoints[i + 1];
// //       double distance = const Distance().as(LengthUnit.Meter, start, end);
// //
// //       if (distance > segmentDistanceThreshold) {
// //         int numExtraPoints = (distance / segmentDistanceThreshold).floor();
// //         for (int j = 0; j <= numExtraPoints; j++) {
// //           double fraction = j / numExtraPoints;
// //           double lat = start.latitude + fraction * (end.latitude - start.latitude);
// //           double lng = start.longitude + fraction * (end.longitude - start.longitude);
// //           plotted.add(LatLng(lat, lng));
// //         }
// //       } else {
// //         plotted.add(start);
// //       }
// //
// //       remainingDistance -= distance;
// //       if (remainingDistance <= 0) break;
// //     }
// //
// //     return plotted;
// //   }
// // }
//
// ///NEW AND IMPROVED
// // import 'package:latlong2/latlong.dart';
// //
// // class ExtraPointsService {
// //   final double intervalMeters = 1500.0;
// //   final double segmentDistanceThreshold = 10.0;
// //   final double updateThreshold = 500.0;
// //
// //   List<LatLng> addExtraPoints(
// //       List<LatLng> originalPoints, LatLng currentLocation) {
// //     List<LatLng> allPoints = [];
// //     double totalDistance = 0;
// //     int lastPlottedIndex = 0;
// //
// //     for (int i = 0; i < originalPoints.length - 1; i++) {
// //       LatLng start = originalPoints[i];
// //       LatLng end = originalPoints[i + 1];
// //       double segmentDistance =
// //           const Distance().as(LengthUnit.Meter, start, end);
// //       totalDistance += segmentDistance;
// //
// //       if (totalDistance > intervalMeters || i == originalPoints.length - 2) {
// //         List<LatLng> segmentPoints = _plotSegment(
// //             originalPoints.sublist(lastPlottedIndex, i + 2), currentLocation);
// //         allPoints.addAll(segmentPoints);
// //         lastPlottedIndex = i + 1;
// //         totalDistance = 0;
// //       }
// //     }
// //
// //     // Ensure the last point is added
// //     if (originalPoints.isNotEmpty && originalPoints.last != allPoints.last) {
// //       allPoints.add(originalPoints.last);
// //     }
// //
// //     return allPoints;
// //   }
// //
// //   List<LatLng> _plotSegment(
// //       List<LatLng> segmentPoints, LatLng currentLocation) {
// //     List<LatLng> plotted = [];
// //     double remainingDistance = const Distance()
// //         .as(LengthUnit.Meter, currentLocation, segmentPoints.last);
// //
// //     for (int i = 0; i < segmentPoints.length - 1; i++) {
// //       LatLng start = segmentPoints[i];
// //       LatLng end = segmentPoints[i + 1];
// //       double distance = const Distance().as(LengthUnit.Meter, start, end);
// //
// //       if (distance > segmentDistanceThreshold) {
// //         int numExtraPoints = (distance / segmentDistanceThreshold).floor();
// //         for (int j = 0; j <= numExtraPoints; j++) {
// //           double fraction = j / numExtraPoints;
// //           double lat =
// //               start.latitude + fraction * (end.latitude - start.latitude);
// //           double lng =
// //               start.longitude + fraction * (end.longitude - start.longitude);
// //           plotted.add(LatLng(lat, lng));
// //         }
// //       } else {
// //         plotted.add(start);
// //       }
// //
// //       remainingDistance -= distance;
// //       if (remainingDistance <= 0) break;
// //     }
// //
// //     // Ensure the end point of the segment is added
// //     if (segmentPoints.isNotEmpty && segmentPoints.last != plotted.last) {
// //       plotted.add(segmentPoints.last);
// //     }
// //
// //     return plotted;
// //   }
// // }
//
//
// class ExtraPointsService {
//   final double intervalMeters = 1500.0;
//   final double segmentDistanceThreshold = 10.0;
//   final double updateThreshold = 500.0;
//
//   List<LatLng> addExtraPoints(
//       List<LatLng> originalPoints, LatLng currentLocation) {
//     List<LatLng> allPoints = [];
//     double totalDistance = 0;
//     int lastPlottedIndex = 0;
//
//     for (int i = 0; i < originalPoints.length - 1; i++) {
//       LatLng start = originalPoints[i];
//       LatLng end = originalPoints[i + 1];
//       double segmentDistance =
//       const Distance().as(LengthUnit.Meter, start, end);
//       totalDistance += segmentDistance;
//
//       if (totalDistance > intervalMeters || i == originalPoints.length - 2) {
//         List<LatLng> segmentPoints = _plotSegment(
//             originalPoints.sublist(lastPlottedIndex, i + 2), currentLocation);
//         allPoints.addAll(segmentPoints);
//         lastPlottedIndex = i + 1;
//         totalDistance = 0;
//       }
//     }
//
//     // Ensure the last point is added
//     if (originalPoints.isNotEmpty && originalPoints.last != allPoints.last) {
//       allPoints.add(originalPoints.last);
//     }
//
//     return allPoints;
//   }
//
//   List<LatLng> _plotSegment(
//       List<LatLng> segmentPoints, LatLng currentLocation) {
//     List<LatLng> plotted = [];
//     double remainingDistance = const Distance()
//         .as(LengthUnit.Meter, currentLocation, segmentPoints.last);
//
//     for (int i = 0; i < segmentPoints.length - 1; i++) {
//       LatLng start = segmentPoints[i];
//       LatLng end = segmentPoints[i + 1];
//       double distance = const Distance().as(LengthUnit.Meter, start, end);
//
//       if (distance > segmentDistanceThreshold) {
//         int numExtraPoints = (distance / segmentDistanceThreshold).floor();
//         for (int j = 0; j <= numExtraPoints; j++) {
//           double fraction = j / numExtraPoints;
//           double lat =
//               start.latitude + fraction * (end.latitude - start.latitude);
//           double lng =
//               start.longitude + fraction * (end.longitude - start.longitude);
//           plotted.add(LatLng(lat, lng));
//         }
//       } else {
//         plotted.add(start);
//       }
//
//       remainingDistance -= distance;
//       if (remainingDistance <= 0) break;
//     }
//
//     // Ensure the end point of the segment is added
//     if (segmentPoints.isNotEmpty && segmentPoints.last != plotted.last) {
//       plotted.add(segmentPoints.last);
//     }
//
//     return plotted;
//   }
// }
