// // ignore_for_file: public_member_api_docs, sort_constructors_first
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../Constants/colors.dart';
// import 'component/locationSearchWidget.dart';
//
// class LocationMarkerScreen extends StatefulWidget {
//   LatLng locationLatLng;
//   String? locationTitle;
//   String? locationAddress;
//   LocationMarkerScreen({
//     Key? key,
//     required this.locationLatLng,
//     this.locationTitle,
//     this.locationAddress,
//   }) : super(key: key);
//
//   @override
//   State<LocationMarkerScreen> createState() => _LocationMarkerScreenState();
// }
//
// class _LocationMarkerScreenState extends State<LocationMarkerScreen> {
//   final mapController = MapController();
//   bool isShowMapLoading = false;
//   List<Marker> markers = [];
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Clr.black,
//       body: Stack(children: [
//         FlutterMap(
//           mapController: mapController,
//           options: MapOptions(
//             center: widget.locationLatLng,
//             zoom: 16.0,
//             onTap: (tapPosition, point) {
//               setState(() {
//                 markers.add(
//                   Marker(
//                     width: 40.0,
//                     height: 40.0,
//                     point: point,
//                     child: Icon(Icons.location_on, color: Colors.red),
//                   ),
//                 );
//               });
//             },
//           ),
//           children: [
//             TileLayer(
//               urlTemplate:
//                   'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
//             ),
//             MarkerLayer(markers: markers),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: SizedBox(
//                     width: 40,
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(0),
//                             backgroundColor: Clr.black,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10))),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Icon(
//                           Icons.arrow_back_ios_rounded,
//                           color: Clr.teal,
//                         )),
//                   ),
//                 ),
//                 LocationSearchWidget(location: widget.locationTitle ?? ""),
//               ],
//             ),
//           ),
//         ),
//         if (isShowMapLoading)
//           Center(
//               child: SizedBox(
//             height: 50,
//             width: 50,
//             child: CircularProgressIndicator(
//               color: Clr.teal,
//             ),
//           ))
//       ]),
//     );
//   }
// }
