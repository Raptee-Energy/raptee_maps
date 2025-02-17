// //Method to draw polyline for source to destination location with all the alternative route of it
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../../Constants/colors.dart';
// import '../../../Repo/direction.dart';
// import '../../../methods/hideKeyboard.dart';
// import 'onRightClickModalSheet.dart';
//
// Future<void> findRouteOnMap(
//     BuildContext context,
//     LatLng origin,
//     LatLng destination,
//     final MapController mapController,
//     List<Marker> markers,
//     Map<String, Polyline> MapOfpolylines,
//     {String sourceAddress = "",
//     String destinationAddress = "",
//     Function? onRouteFound,
//     Function? onRouteSelected}) async {
//   try {
//     if (((origin.latitude != 0 && origin.latitude != 0) ||
//             sourceAddress.isNotEmpty) &&
//         ((destination.latitude != 0 && destination.latitude != 0) ||
//             destinationAddress.isNotEmpty)) {
//       Map<String, dynamic>? routeData = await DirectionsRepository()
//           .getTheDirection(origin, destination, true, "driving",
//               sourceAddress: sourceAddress,
//               destinationAddress: destinationAddress);
//
//       printMsg("The no of routes========>");
//       printMsg(routeData!["routes"].length.toString());
//
//       if (routeData["routes"].length == 0) {
//         showToastError(context, title: "No route found");
//       }
//
//       int sortestRoute = 0;
//
//       int sortestRouteId = 0;
//
//       markers.add(Marker(
//           markerId: MarkerId("marker-destination"),
//           position: destination,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
//           infoWindow: InfoWindow(title: "Final Destination")));
//       markers.add(Marker(
//           markerId: MarkerId("marker-source"),
//           position: origin,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           infoWindow: InfoWindow(title: "Start Location")));
//
//       for (int i = 0; i < (routeData["routes"].length); i++) {
//         int distance = routeData["routes"][i]["legs"][0]["distance"]["value"];
//
//         if (sortestRoute == 0) {
//           sortestRoute = distance;
//
//           sortestRouteId = i;
//         } else {
//           if (sortestRoute > distance) {
//             sortestRoute = distance;
//
//             sortestRouteId = i;
//           }
//         }
//
//         final MapOfpolylinesPoints = PolylinePoints().decodePolyline(
//             routeData["routes"][i]["overview_polyline"]['points']);
//
//         String polyLinesId = "route$i";
//
//         MapOfpolylines["route$i"] = Polyline(
//             color: Clr.defaultPolyLineColor,
//             endCap: Cap.roundCap,
//             width: 7,
//             consumeTapEvents: true,
//             onTap: () async {
//               // Get Call back function from its parent
//               if (onRouteSelected != null) {
//                 onRouteSelected();
//               }
//               _onTapPolyline(polyLinesId, MapOfpolylines, onRouteSelected);
//               try {
//                 await onRouteClickModalBottomSheet(
//                     context,
//                     routeData["routes"][i]["legs"][0]["duration"]["text"],
//                     routeData["routes"][i]["legs"][0]["distance"]["text"],
//                     sourceAddress.isEmpty
//                         ? routeData["routes"][i]["legs"][0]["start_address"]
//                         : sourceAddress,
//                     destinationAddress.isEmpty
//                         ? routeData["routes"][i]["legs"][0]["end_address"]
//                         : destinationAddress,
//                     origin,
//                     destination);
//               } on Exception catch (e) {
//                 // TODO
//                 CommanToast().showErrorToastMsg(context, e.toString());
//               }
//             },
//             polylineId: PolylineId(polyLinesId),
//             points:
//                 MapOfpolylinesPoints.map((e) => LatLng(e.latitude, e.longitude))
//                     .toList());
//       }
//       // Add polyline for the best selected route
//       String sortestPolylineIdString = "route$sortestRouteId";
//       MapOfpolylines[sortestPolylineIdString] = Polyline(
//           color: Clr.selectedPolylineColor,
//           endCap: Cap.roundCap,
//           startCap: Cap.roundCap,
//           width: 7,
//           consumeTapEvents: true,
//           onTap: () async {
//             try {
//               _onTapPolyline(
//                   sortestPolylineIdString, MapOfpolylines, onRouteSelected);
//               await onRouteClickModalBottomSheet(
//                   context,
//                   routeData["routes"][0]["legs"][0]["duration"]["text"],
//                   routeData["routes"][0]["legs"][0]["distance"]["text"],
//                   sourceAddress.isEmpty
//                       ? routeData["routes"][0]["legs"][0]["start_address"]
//                       : sourceAddress,
//                   destinationAddress.isEmpty
//                       ? routeData["routes"][0]["legs"][0]["end_address"]
//                       : destinationAddress,
//                   origin,
//                   destination);
//             } on Exception catch (e) {
//               CommanToast().showErrorToastMsg(context, e.toString());
//               // TODO
//             }
//           },
//           polylineId: PolylineId(sortestPolylineIdString),
//           geodesic: true,
//           jointType: JointType.round,
//           zIndex: 5,
//           points: PolylinePoints()
//               .decodePolyline(routeData["routes"][sortestRouteId]
//                   ["overview_polyline"]['points'])
//               .map((e) => LatLng(e.latitude, e.longitude))
//               .toList());
//
//       // Animate the camera to route
//       mapController
//           .animateCamera(CameraUpdate.newLatLngBounds(
//               LatLngBounds(
//                   southwest: LatLng(
//                       routeData["routes"][0]["bounds"]["southwest"]["lat"],
//                       routeData["routes"][0]["bounds"]["southwest"]["lng"]),
//                   northeast: LatLng(
//                       routeData["routes"][0]["bounds"]["northeast"]["lat"],
//                       routeData["routes"][0]["bounds"]["northeast"]["lng"])),
//               100))
//           .then((value) async {
//         await onRouteClickModalBottomSheet(
//             context,
//             routeData["routes"][0]["legs"][0]["duration"]["text"],
//             routeData["routes"][0]["legs"][0]["distance"]["text"],
//             sourceAddress.isEmpty
//                 ? routeData["routes"][0]["legs"][0]["start_address"]
//                 : sourceAddress,
//             destinationAddress.isEmpty
//                 ? routeData["routes"][0]["legs"][0]["end_address"]
//                 : destinationAddress,
//             origin,
//             destination);
//       });
//     } else {
//       printMsg(" Source or Destination is null");
//     }
//   } on Exception catch (e) {
//     // TODO
//
//     CommanToast().showErrorToastMsg(context, e.toString());
//   }
// }
//
// //Handle on click of marker
// _onTapPolyline(String polylineId, Map<String, Polyline> MapOfpolylines,
//     Function? updateUI) {
//   printMsg(polylineId);
//
//   MapOfpolylines.forEach(
//     (key, value) {
//       Polyline newPolyline = MapOfpolylines[key]!.copyWith(
//           colorParam: key == polylineId ? Clr.tealLite : Clr.teal,
//           zIndexParam: key == polylineId
//               ? 10
//               : 0); // create a new polyline object which has a different color using the colorParam property
//       MapOfpolylines[key] =
//           newPolyline; // add that new polyline object to the list
//     },
//   );
//
//   if (updateUI != null) {
//     updateUI();
//   }
// }

///All Polyline routes are teal
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../../Constants/colors.dart';
// import '../../../Repo/direction.dart';
// import '../../../methods/hideKeyboard.dart';
// import 'decodePolyLine.dart';
// import 'onRightClickModalSheet.dart';
//
// Future<void> findRouteOnMap(
//     BuildContext context,
//     LatLng origin,
//     LatLng destination,
//     final MapController mapController,
//     List<Marker> markers,
//     List<Polyline> polyLines,
//     {String sourceAddress = "",
//     String destinationAddress = "",
//     Function? onRouteFound,
//     Function? onRouteSelected}) async {
//   try {
//     if (((origin.latitude != 0 && origin.longitude != 0) ||
//             sourceAddress.isNotEmpty) &&
//         ((destination.latitude != 0 && destination.longitude != 0) ||
//             destinationAddress.isNotEmpty)) {
//       Map<String, dynamic>? routeData = await DirectionsRepository()
//           .getTheDirection(origin, destination, true, "driving",
//               sourceAddress: sourceAddress,
//               destinationAddress: destinationAddress);
//
//       printMsg("The no of routes========>");
//       printMsg(routeData!["routes"].length.toString());
//
//       if (routeData["routes"].length == 0) {
//         // showToastError(context, title: "No route found");
//         return;
//       }
//
//       int shortestRoute = 0;
//       int shortestRouteId = 0;
//
//       markers.add(Marker(
//         width: 80.0,
//         height: 80.0,
//         point: destination,
//         child: Icon(
//           Icons.location_on,
//           color: Clr.buttonRed1,
//           size: 40.0,
//         ),
//       ));
//
//       markers.add(Marker(
//         width: 80.0,
//         height: 80.0,
//         point: origin,
//         child: Container(
//           child: Icon(
//             Icons.location_on,
//             color: Clr.wifiBTBlue,
//             size: 40.0,
//           ),
//         ),
//       ));
//
//       for (int i = 0; i < (routeData["routes"].length); i++) {
//         int distance = routeData["routes"][i]["legs"][0]["distance"]["value"];
//
//         if (shortestRoute == 0) {
//           shortestRoute = distance;
//           shortestRouteId = i;
//         } else {
//           if (shortestRoute > distance) {
//             shortestRoute = distance;
//             shortestRouteId = i;
//           }
//         }
//
//         final polylinePoints = decodePolyline(
//             routeData["routes"][i]["overview_polyline"]['points']);
//
//         String polylineId = "route$i";
//
//         polyLines.add(Polyline(
//           points: polylinePoints
//               .map((e) => LatLng(e.latitude, e.longitude))
//               .toList(),
//           strokeWidth: 7.0,
//           color: Clr.teal2,
//         ));
//       }
//
//       // Add polyline for the best selected route
//       String shortestPolylineIdString = "route$shortestRouteId";
//       polyLines.add(Polyline(
//         points: decodePolyline(routeData["routes"][shortestRouteId]
//                 ["overview_polyline"]['points'])
//             .map((e) => LatLng(e.latitude, e.longitude))
//             .toList(),
//         strokeWidth: 7.0,
//         color: Clr.teal2,
//       ));
//
//       // Animate the camera to route
//       mapController.fitBounds(
//         LatLngBounds(
//           LatLng(routeData["routes"][0]["bounds"]["southwest"]["lat"],
//               routeData["routes"][0]["bounds"]["southwest"]["lng"]),
//           LatLng(routeData["routes"][0]["bounds"]["northeast"]["lat"],
//               routeData["routes"][0]["bounds"]["northeast"]["lng"]),
//         ),
//         options: FitBoundsOptions(padding: EdgeInsets.all(20)),
//       );
//
//       // Call the modal bottom sheet after fitting bounds
//       await onRouteClickModalBottomSheet(
//           context,
//           routeData["routes"][0]["legs"][0]["duration"]["text"],
//           routeData["routes"][0]["legs"][0]["distance"]["text"],
//           sourceAddress.isEmpty
//               ? routeData["routes"][0]["legs"][0]["start_address"]
//               : sourceAddress,
//           destinationAddress.isEmpty
//               ? routeData["routes"][0]["legs"][0]["end_address"]
//               : destinationAddress,
//           origin,
//           destination);
//     } else {
//       printMsg("Source or Destination is null");
//     }
//   } on Exception catch (e) {
//     // CommanToast().showErrorToastMsg(context, e.toString());
//   }
// }
//
// //Handle on click of marker
// _onTapPolyline(
//     String polylineId, List<Polyline> polyLines, Function? updateUI) {
//   printMsg(polylineId);
//
//   for (var polyline in polyLines) {
//     Polyline newPolyline = Polyline(
//       points: polyline.points,
//       strokeWidth: 7.0,
//       color: polyline.color == Clr.teal ? Clr.white : Clr.tealLite,
//     );
//     polyLines[polyLines.indexOf(polyline)] = newPolyline;
//   }
//
//   if (updateUI != null) {
//     updateUI();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../Constants/colors.dart';
import '../../../Repo/direction.dart';
import '../../Methods/hideKeyboard.dart';
import 'decodePolyLine.dart';
import 'onRightClickModalSheet.dart';

Future<void> findRouteOnMap(
    BuildContext context,
    LatLng origin,
    LatLng destination,
    final MapController mapController,
    List<Marker> markers,
    List<Polyline> polyLines,
    {String sourceAddress = "",
    String destinationAddress = "",
    Function? onRouteFound,
    Function? onRouteSelected}) async {
  try {
    if (((origin.latitude != 0 && origin.longitude != 0) ||
            sourceAddress.isNotEmpty) &&
        ((destination.latitude != 0 && destination.longitude != 0) ||
            destinationAddress.isNotEmpty)) {
      Map<String, dynamic>? routeData = await DirectionsRepository()
          .getTheDirection(origin, destination, true, "driving",
              sourceAddress: sourceAddress,
              destinationAddress: destinationAddress);

      printMsg("The no of routes========>");
      printMsg(routeData!["routes"].length.toString());

      if (routeData["routes"].length == 0) {
        // showToastError(context, title: "No route found");
        return;
      }

      int shortestRoute = 0;
      int shortestRouteId = 0;

      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: destination,
        child: Icon(
          Icons.location_on,
          color: Clr.buttonRed1,
          size: 40.0,
        ),
      ));

      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: origin,
        child: Container(
          child: Icon(
            Icons.location_on,
            color: Clr.wifiBTBlue,
            size: 40.0,
          ),
        ),
      ));

      for (int i = 0; i < (routeData["routes"].length); i++) {
        int distance = routeData["routes"][i]["legs"][0]["distance"]["value"];

        if (shortestRoute == 0) {
          shortestRoute = distance;
          shortestRouteId = i;
        } else {
          if (shortestRoute > distance) {
            shortestRoute = distance;
            shortestRouteId = i;
          }
        }

        final polylinePoints = decodePolyline(
            routeData["routes"][i]["overview_polyline"]['points']);

        String polylineId = "route$i";

        polyLines.add(Polyline(
          points: polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
          strokeWidth: 7.0,
          color: i == shortestRouteId ? Clr.teal2 : Clr.mainGrey,
        ));
      }

      // Add polyline for the best selected route
      String shortestPolylineIdString = "route$shortestRouteId";
      polyLines.add(Polyline(
        points: decodePolyline(routeData["routes"][shortestRouteId]
                ["overview_polyline"]['points'])
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
        strokeWidth: 7.0,
        color: Clr.teal2,
      ));

      // Animate the camera to route
      mapController.fitBounds(
        LatLngBounds(
          LatLng(routeData["routes"][0]["bounds"]["southwest"]["lat"],
              routeData["routes"][0]["bounds"]["southwest"]["lng"]),
          LatLng(routeData["routes"][0]["bounds"]["northeast"]["lat"],
              routeData["routes"][0]["bounds"]["northeast"]["lng"]),
        ),
        options: FitBoundsOptions(padding: EdgeInsets.all(20)),
      );

      // Call the modal bottom sheet after fitting bounds
      await onRouteClickModalBottomSheet(
          context,
          routeData["routes"][0]["legs"][0]["duration"]["text"],
          routeData["routes"][0]["legs"][0]["distance"]["text"],
          sourceAddress.isEmpty
              ? routeData["routes"][0]["legs"][0]["start_address"]
              : sourceAddress,
          destinationAddress.isEmpty
              ? routeData["routes"][0]["legs"][0]["end_address"]
              : destinationAddress,
          origin,
          destination);
    } else {
      printMsg("Source or Destination is null");
    }
  } on Exception catch (e) {
    // CommanToast().showErrorToastMsg(context, e.toString());
  }
}

// Handle on click of marker
_onTapPolyline(
    String polylineId, List<Polyline> polyLines, Function? updateUI) {
  printMsg(polylineId);

  for (var polyline in polyLines) {
    Polyline newPolyline = Polyline(
      points: polyline.points,
      strokeWidth: 7.0,
      color: polyline.color == Clr.teal ? Clr.white : Clr.tealLite,
    );
    polyLines[polyLines.indexOf(polyline)] = newPolyline;
  }

  if (updateUI != null) {
    updateUI();
  }
}
