// // import 'dart:async';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// //
// // import '../../Constants/colors.dart';
// // import '../../Models/nearbyChargingStationDataModel.dart';
// // import 'component/nearbyChargerLocationSheet.dart';
// //
// // // ignore: must_be_immutable
// // class NearbyCharginStationMapScreen extends StatefulWidget {
// //   LatLng location;
// //   List<NearbyChargingStationDataModel> nearbyChargerList;
// //   NearbyCharginStationMapScreen(this.location, this.nearbyChargerList,
// //       {super.key});
// //
// //   @override
// //   State<NearbyCharginStationMapScreen> createState() =>
// //       _NearbyCharginStationMapScreenState();
// // }
// //
// // class _NearbyCharginStationMapScreenState
// //     extends State<NearbyCharginStationMapScreen> {
// //   final mapController = MapController();
// //   List<Marker> markers = [];
// //   List<Polyline> polyLines = [];
// //   List<NearbyChargingStationDataModel> nearbyChargerList = [];
// //   Map<String, Polyline> maoOfPolylines = {};
// //   LatLng _center = const LatLng(0, 0);
// //
// //   @override
// //   void initState() {
// //     _center = widget.location;
// //     nearbyChargerList = widget.nearbyChargerList;
// //
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
// //       await nearbyChargingLocationModalBottomSheet(context, nearbyChargerList);
// //
// //       if (nearbyChargerList.isEmpty) {
// //         Timer((Duration(seconds: 2)), () {
// //           Navigator.pop(context);
// //         });
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Clr.black,
// //       body: Stack(children: [
// //         GoogleMap(
// //             initialCameraPosition: CameraPosition(
// //               target: _center,
// //               zoom: 16.0,
// //             ),
// //             // mapToolbarEnabled: true,
// //             // trafficEnabled: true,
// //
// //             myLocationButtonEnabled: false,
// //             mapToolbarEnabled: true,
// //             mapType: MapType.normal,
// //             // trafficEnabled: true,
// //             // buildingsEnabled: true,
// //
// //             zoomControlsEnabled: false,
// //             fortyFiveDegreeImageryEnabled: true,
// //             tiltGesturesEnabled: true,
// //             myLocationEnabled: true,
// //             markers: markers.toSet(), // markers
// //             polylines: maoOfPolylines.values.toSet(),
// //             onMapCreated: (controller) {
// //               mapController = controller;
// //               addAllNearByChargerMarkers(nearbyChargerList);
// //
// //               // setState(() {
// //               //   isShowMapLoading = false;
// //               // });
// //             },
// //             onTap: (location) async {}),
// //         Padding(
// //           padding: const EdgeInsets.only(top: 70, left: 30),
// //           child: Align(
// //             alignment: Alignment.topLeft,
// //             child: SizedBox(
// //               width: 40,
// //               child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                       padding: const EdgeInsets.all(0),
// //                       backgroundColor: Clr.black,
// //                       shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10))),
// //                   onPressed: () {
// //                     Navigator.pop(context);
// //                   },
// //                   child: Icon(
// //                     Icons.arrow_back,
// //                     color: Clr.white,
// //                   )),
// //             ),
// //           ),
// //         ),
// //       ]),
// //     );
// //   }
// //
// //   //Markers and animate to markers
// //   addAllNearByChargerMarkers(List<NearbyChargingStationDataModel> data) {
// //     for (NearbyChargingStationDataModel location in data) {
// //       //Chenge the status for the Show the Marker
// //
// //       markers.add(Marker(
// //           consumeTapEvents: true,
// //           position: LatLng(location.location?.latitude ?? 0,
// //               location.location?.longitude ?? 0),
// //           icon:
// //               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
// //           onTap: () async {
// //             await onMapClickModalBottomSheet(
// //                 parentScreenName: RouteName.nearByChargingScreen,
// //                 context,
// //                 location.name ?? "",
// //                 "",
// //                 "",
// //                 location.address ?? "",
// //                 LatLng(location.location?.latitude ?? 0,
// //                     location.location?.longitude ?? 0),
// //                 LatLng(0, 0));
// //           },
// //           infoWindow: InfoWindow(
// //               snippet: location.name ?? "", title: location.name ?? ""),
// //           markerId:
// //               MarkerId("Marker-${location.location?.longitude.toString()}")));
// //
// //       // printMsg("Hellow marker added");
// //     }
// //
// //     mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 11));
// //     setState(() {});
// //   }
// // }
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../Constants/colors.dart';
// import '../../Constants/routeName.dart';
// import '../../Models/nearbyChargingStationDataModel.dart';
// import 'component/nearbyChargerLocationSheet.dart';
// import 'component/onMapClickModalSheet.dart';
//
// // ignore: must_be_immutable
// class NearbyCharginStationMapScreen extends StatefulWidget {
//   LatLng location;
//   List<NearbyChargingStationDataModel> nearbyChargerList;
//
//   NearbyCharginStationMapScreen(this.location, this.nearbyChargerList,
//       {super.key});
//
//   @override
//   State<NearbyCharginStationMapScreen> createState() =>
//       _NearbyCharginStationMapScreenState();
// }
//
// class _NearbyCharginStationMapScreenState
//     extends State<NearbyCharginStationMapScreen> {
//   final mapController = MapController();
//   List<Marker> markers = [];
//   List<Polyline> polyLines = [];
//   List<NearbyChargingStationDataModel> nearbyChargerList = [];
//   LatLng _center = const LatLng(0, 0);
//
//   @override
//   void initState() {
//     _center = widget.location;
//     nearbyChargerList = widget.nearbyChargerList;
//
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       await nearbyChargingLocationModalBottomSheet(context, nearbyChargerList);
//
//       if (nearbyChargerList.isEmpty) {
//         Timer((Duration(seconds: 2)), () {
//           Navigator.pop(context);
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Clr.black,
//       body: Stack(children: [
//         FlutterMap(
//           mapController: mapController,
//           options: MapOptions(
//             center: _center,
//             zoom: 16.0,
//             onTap: (tapPosition, point) async {
//               // Handle tap on map
//             },
//           ),
//           children: [
//             TileLayer(
//               urlTemplate: 'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
//             ),
//             MarkerLayer(
//               markers: markers,
//             ),
//             PolylineLayer(
//               polylines: polyLines,
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 70, left: 30),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 40,
//               child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.all(0),
//                       backgroundColor: Clr.black,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Icon(
//                     Icons.arrow_back,
//                     color: Clr.white,
//                   )),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   // Markers and animate to markers
//   void addAllNearByChargerMarkers(List<NearbyChargingStationDataModel> data) {
//     for (NearbyChargingStationDataModel location in data) {
//       markers.add(Marker(
//         width: 80.0,
//         height: 80.0,
//         point: LatLng(location.location?.latitude ?? 0,
//             location.location?.longitude ?? 0),
//         child: Container(
//           child: IconButton(
//             icon: Icon(Icons.location_on, color: Clr.tealLite, size: 40.0),
//             onPressed: () async {
//               await onMapClickModalBottomSheet(
//                   parentScreenName: RouteName.nearByChargingScreen,
//                   context,
//                   location.name ?? "",
//                   "",
//                   "",
//                   location.address ?? "",
//                   LatLng(location.location?.latitude ?? 0,
//                       location.location?.longitude ?? 0),
//                   LatLng(0, 0));
//             },
//           ),
//         ),
//       ));
//     }
//
//     mapController.move(_center, 11);
//     setState(() {});
//   }
// }
