// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../Constants/colors.dart';
// import '../../Constants/locationData.dart';
// import '../../Constants/styles.dart';
// import '../../methods/hideKeyboard.dart';
// import 'component/findMyRouteCall.dart';
//
// // ignore: must_be_immutable
// class RouteDirectionMapScreen extends StatefulWidget {
//   final String sourceAddress;
//   final String destinationAddress;
//   final LatLng destinationLatLng;
//   final LatLng? sourecLatLng;
//   String parentScreenName;
//   RouteDirectionMapScreen(
//       this.sourceAddress, this.destinationAddress, this.destinationLatLng,
//       {this.sourecLatLng, required this.parentScreenName, super.key});
//
//   @override
//   State<RouteDirectionMapScreen> createState() =>
//       _RouteDirectionMapScreenState();
// }
//
// class _RouteDirectionMapScreenState extends State<RouteDirectionMapScreen> {
//   final mapController = MapController();
//   bool isShowMapLoading = false;
//   List<Marker> markers = [];
//   List<Polyline> polyLines = [];
//
//   Map<String, Polyline> maoOfPolylines = {};
//   LatLng destinationLatLng = LatLng(0, 0);
//   LatLng sourceLatLng = LatLng(0, 0);
//
//   TextEditingController sourceController = TextEditingController();
//   TextEditingController destinationController = TextEditingController();
//
//   @override
//   void initState() {
//     sourceController.text = widget.sourceAddress;
//     destinationController.text = widget.destinationAddress;
//     destinationLatLng = widget.destinationLatLng;
//     sourceLatLng = widget.sourecLatLng ?? LatLng(0, 0);
//
//     printMsg("Source Address: ${sourceController.text} ");
//     printMsg("Destination Address: ${destinationController.text} ");
//     printMsg(
//         "Source Latlng: ${sourceLatLng.latitude}  ${sourceLatLng.longitude} ");
//
//     isShowMapLoading = true;
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     printMsg("Parent Screen Name" + widget.parentScreenName);
//     return Scaffold(
//       backgroundColor: Clr.black,
//       body: Stack(children: [
//         GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LocationTempData.currentLocation,
//               zoom: 16.0,
//             ),
//             myLocationButtonEnabled: false,
//             mapToolbarEnabled: true,
//             mapType: MapType.normal,
//             zoomControlsEnabled: false,
//             fortyFiveDegreeImageryEnabled: true,
//             tiltGesturesEnabled: true,
//             myLocationEnabled: true,
//             markers: markers.toSet(), // markers
//             polylines: maoOfPolylines.values.toSet(),
//             onMapCreated: (controller) async {
//               mapController = controller;
//               // location.LocationData currentLocation =
//               try {
//                 await location.Location().getLocation().then((value) {
//                   LocationTempData.currentLocation =
//                       LatLng(value.latitude ?? 0, value.longitude ?? 0);
//                   try {
//                     findRouteOnMap(
//                         context,
//                         (sourceLatLng.latitude == 0 &&
//                             sourceLatLng.longitude == 0)
//                             ? LatLng(value.latitude ?? 0, value.longitude ?? 0)
//                             : sourceLatLng,
//                         destinationLatLng,
//                         mapController,
//                         markers,
//                         maoOfPolylines,
//                         sourceAddress: sourceController.text.isNotEmpty
//                             ? "${value.latitude} ${value.longitude}"
//                             : sourceController.text,
//                         destinationAddress: destinationController.text,
//                         onRouteSelected: () {
//                           setState(() {});
//                         }).whenComplete(() {
//                       setState(() {
//                         isShowMapLoading = false;
//                       });
//                     });
//                   } on Exception catch (e) {
//                     CommanToast().showErrorToastMsg(context, e.toString());
//                     // TODO
//                   }
//
//                   return value;
//                 });
//               } on Exception catch (e) {
//                 CommanToast().showErrorToastMsg(context, e.toString());
//                 // TODO
//               }
//             },
//             onTap: (location) async {}),
//         sourceToDirectionWidget(
//             context,
//             sourceController,
//             destinationController,
//             sourceLatLng.latitude == 0 && sourceLatLng.longitude == 0
//                 ? LocationTempData.currentLocation
//                 : sourceLatLng,
//             destinationLatLng,
//             parentScreenName: widget.parentScreenName),
//         if (isShowMapLoading && destinationController.text.isNotEmpty)
//           Center(
//               child: SizedBox(
//                 // height: 50,
//                 // width: 50,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       color: Clr.teal,
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       "Wait, Finding best route for you..",
//                       textAlign: TextAlign.center,
//                       maxLines: 3,
//                       style: Style.fadeTextStyle(
//                           color: Clr.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14),
//                     )
//                   ],
//                 ),
//               ))
//       ]),
//     );
//   }
// }

///GOOGLE MAP TO FLUTTER MAP
// import 'package:dashboard/Screens/mapModule/component/sourceToDestinationMapWidget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../Constants/colors.dart';
// import '../../Constants/locationData.dart';
// import '../../Constants/styles.dart';
// import '../../methods/hideKeyboard.dart';
// import 'component/findMyRouteCall.dart';
//
// // ignore: must_be_immutable
// class RouteDirectionMapScreen extends StatefulWidget {
//   final String sourceAddress;
//   final String destinationAddress;
//   final LatLng destinationLatLng;
//   final LatLng? sourecLatLng;
//   String parentScreenName;
//   RouteDirectionMapScreen(
//       this.sourceAddress, this.destinationAddress, this.destinationLatLng,
//       {this.sourecLatLng, required this.parentScreenName, super.key});
//
//   @override
//   State<RouteDirectionMapScreen> createState() =>
//       _RouteDirectionMapScreenState();
// }
//
// class _RouteDirectionMapScreenState extends State<RouteDirectionMapScreen> {
//   final mapController = MapController();
//   bool isShowMapLoading = false;
//   List<Marker> markers = [];
//   List<Polyline> polyLines = [];
//
//   LatLng destinationLatLng = LatLng(0, 0);
//   LatLng sourceLatLng = LatLng(0, 0);
//
//   TextEditingController sourceController = TextEditingController();
//   TextEditingController destinationController = TextEditingController();
//
//   @override
//   void initState() {
//     sourceController.text = widget.sourceAddress;
//     destinationController.text = widget.destinationAddress;
//     destinationLatLng = widget.destinationLatLng;
//     sourceLatLng = widget.sourecLatLng ?? LatLng(0, 0);
//
//     printMsg("Source Address: ${sourceController.text} ");
//     printMsg("Destination Address: ${destinationController.text} ");
//     printMsg(
//         "Source Latlng: ${sourceLatLng.latitude}  ${sourceLatLng.longitude} ");
//
//     isShowMapLoading = true;
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       // Fetch the route and update the map
//       await _findRouteAndUpdateMap();
//     });
//   }
//
//   Future<void> _findRouteAndUpdateMap() async {
//     try {
//       await location.Location().getLocation().then((value) {
//         LocationTempData.currentLocation =
//             LatLng(value.latitude ?? 0, value.longitude ?? 0);
//         try {
//           findRouteOnMap(
//               context,
//               (sourceLatLng.latitude == 0 && sourceLatLng.longitude == 0)
//                   ? LatLng(value.latitude ?? 0, value.longitude ?? 0)
//                   : sourceLatLng,
//               destinationLatLng,
//               mapController,
//               markers,
//               polyLines,
//               sourceAddress: sourceController.text.isNotEmpty
//                   ? "${value.latitude} ${value.longitude}"
//                   : sourceController.text,
//               destinationAddress: destinationController.text,
//               onRouteSelected: () {
//             setState(() {});
//           }).whenComplete(() {
//             setState(() {
//               isShowMapLoading = false;
//             });
//           });
//         } on Exception catch (e) {
//           // CommanToast().showErrorToastMsg(context, e.toString());
//         }
//         return value;
//       });
//     } on Exception catch (e) {
//       // CommanToast().showErrorToastMsg(context, e.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     printMsg("Parent Screen Name" + widget.parentScreenName);
//     return Scaffold(
//       backgroundColor: Clr.black,
//       body: Stack(children: [
//         FlutterMap(
//           mapController: mapController,
//           options: MapOptions(
//             center: LocationTempData.currentLocation,
//             zoom: 16.0,
//           ),
//           children: [
//             TileLayer(
//               urlTemplate:
//                   'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png',
//               subdomains: ['a', 'b', 'c'],
//             ),
//             MarkerLayer(
//               markers: markers,
//             ),
//             PolylineLayer(
//               polylines: polyLines,
//             ),
//           ],
//         ),
//         sourceToDestinationWidget(
//             context,
//             sourceController,
//             destinationController,
//             sourceLatLng.latitude == 0 && sourceLatLng.longitude == 0
//                 ? LocationTempData.currentLocation
//                 : sourceLatLng,
//             destinationLatLng,
//             parentScreenName: widget.parentScreenName),
//         if (isShowMapLoading && destinationController.text.isNotEmpty)
//           Center(
//               child: SizedBox(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: Clr.teal,
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   "Wait, Finding best route for you..",
//                   textAlign: TextAlign.center,
//                   maxLines: 3,
//                   style: Style.fadeTextStyle(
//                       color: Clr.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14),
//                 )
//               ],
//             ),
//           ))
//       ]),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "back",
//         backgroundColor: Colors.black,
//         onPressed: () {
//           Navigator.pop(context);
//         },
//         child: const Icon(Icons.arrow_back, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../Constants/colors.dart';
import '../../Constants/locationData.dart';
import '../../Constants/styles.dart';
import '../../methods/hideKeyboard.dart';
import 'component/findMyRouteCall.dart';
import 'component/sourceToDestinationMapWidget.dart';

// ignore: must_be_immutable
class RouteDirectionMapScreen extends StatefulWidget {
  final String sourceAddress;
  final String destinationAddress;
  final LatLng destinationLatLng;
  final LatLng? sourecLatLng;
  String parentScreenName;

  RouteDirectionMapScreen(
    this.sourceAddress,
    this.destinationAddress,
    this.destinationLatLng, {
    this.sourecLatLng,
    required this.parentScreenName,
    super.key,
  });

  @override
  State<RouteDirectionMapScreen> createState() =>
      _RouteDirectionMapScreenState();
}

class _RouteDirectionMapScreenState extends State<RouteDirectionMapScreen> {
  final mapController = MapController();
  bool isShowMapLoading = false;
  List<Marker> markers = [];
  List<Polyline> polyLines = [];

  LatLng destinationLatLng = LatLng(0, 0);
  LatLng sourceLatLng = LatLng(0, 0);

  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    sourceController.text = widget.sourceAddress;
    destinationController.text = widget.destinationAddress;
    destinationLatLng = widget.destinationLatLng;
    sourceLatLng = widget.sourecLatLng ?? const LatLng(13.022420, 80.168120);

    printMsg("Source Address: ${sourceController.text} ");
    printMsg("Destination Address: ${destinationController.text} ");
    printMsg(
      "Source Latlng: ${sourceLatLng.latitude}  ${sourceLatLng.longitude} ",
    );

    isShowMapLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _findRouteAndUpdateMap();
    });
  }

  Future<void> _findRouteAndUpdateMap() async {
    try {
      LatLng staticLocation = const LatLng(13.022420, 80.168120);
      LocationTempData.currentLocation = staticLocation;

      try {
        findRouteOnMap(
          context,
          (sourceLatLng.latitude == 0 && sourceLatLng.longitude == 0)
              ? staticLocation
              : sourceLatLng,
          destinationLatLng,
          mapController,
          markers,
          polyLines,
          sourceAddress: sourceController.text.isNotEmpty
              ? "${staticLocation.latitude} ${staticLocation.longitude}"
              : sourceController.text,
          destinationAddress: destinationController.text,
          onRouteSelected: () {
            setState(() {});
          },
        ).whenComplete(() {
          setState(() {
            isShowMapLoading = false;
          });
        });
      } on Exception catch (e) {
        // CommanToast().showErrorToastMsg(context, e.toString());
      }
    } on Exception catch (e) {
      // CommanToast().showErrorToastMsg(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    printMsg("Parent Screen Name" + widget.parentScreenName);
    return Scaffold(
      backgroundColor: Clr.black,
      body: Stack(children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LocationTempData.currentLocation,
            zoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'http://34.93.16.227:8080/styles/test-style/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: markers,
            ),
            PolylineLayer(
              polylines: polyLines,
            ),
          ],
        ),
        sourceToDestinationWidget(
          context,
          sourceController,
          destinationController,
          sourceLatLng.latitude == 0 && sourceLatLng.longitude == 0
              ? LocationTempData.currentLocation
              : sourceLatLng,
          destinationLatLng,
          parentScreenName: widget.parentScreenName,
        ),
        if (isShowMapLoading && destinationController.text.isNotEmpty)
          Center(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Clr.teal,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Wait, Finding best route for you..",
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: Style.conigenColorChangableRegularText(
                      color: Clr.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ]),
      floatingActionButton: FloatingActionButton(
        heroTag: "back",
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}
