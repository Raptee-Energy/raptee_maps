// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
//
// import '../../../Constants/colors.dart';
// import '../../../Constants/routeName.dart';
// import '../../../Constants/styles.dart';
// import '../../../Constants/tempData.dart';
// import '../../../Models/locationHistoryDataModel.dart';
// import '../../../Models/nearbyChargingStationDataModel.dart';
// import '../../Methods/hideKeyboard.dart';
// import '../routeDirectionMapScreen.dart';
//
// Future<dynamic> nearbyChargingLocationModalBottomSheet(
//   BuildContext context,
//   List<NearbyChargingStationDataModel>? data,
// ) {
//   return showModalBottomSheet(
//       backgroundColor: Clr.black,
//       elevation: 0,
//       // barrierColor: Clr.w,
//
//       enableDrag: true,
//       useSafeArea: false,
//       isScrollControlled: true,
//       isDismissible: true,
//       showDragHandle: true,
//       scrollControlDisabledMaxHeightRatio: 3,
//       context: context,
//       builder: (context) {
//         bool isLocationSaved = false;
//
//         return StatefulBuilder(
//           builder: (context, state) => Wrap(
//             children: [
//               if (data != null && data.isNotEmpty)
//                 SizedBox(
//                   height: MediaQuery.sizeOf(context).height * 0.7,
//                   width: MediaQuery.sizeOf(context).width,
//                   child: Container(
//                     padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
//                     decoration: BoxDecoration(
//                         color: Clr.black,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ignore: prefer_interpolation_to_compose_strings
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       data[0].name ?? "",
//                                       textAlign: TextAlign.left,
//                                       maxLines: 3,
//                                       style: Style.conigenColorChangableRegularText(
//                                           color: Clr.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     if (data[0].isAvailable != null)
//                                       Text(
//                                         data[0].isAvailable! ? "Open" : "Close",
//                                         style: Style.conigenColorChangableRegularText(
//                                             color: data[0].isAvailable!
//                                                 ? Clr.green1
//                                                 : Clr.buttonRed1,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             data[0].address ?? "Not Available",
//                                             maxLines: 3,
//                                             textAlign: TextAlign.start,
//                                             style: Style.conigenColorChangableRegularText(
//                                                 color: Clr.white,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                           child: VerticalDivider(
//                                             color: Clr.white,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 20,
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(10.0),
//                                     child: IconButton(
//                                       icon: Icon(
//                                         isLocationSaved
//                                             ? Icons.bookmark_sharp
//                                             : Icons.bookmark_outline_sharp,
//                                         color: isLocationSaved
//                                             ? Clr.buttonRed1
//                                             : Clr.teal,
//                                       ),
//                                       style: IconButton.styleFrom(),
//                                       onPressed: () {
//                                         isLocationSaved = !isLocationSaved;
//                                         TempData.addLocationDataToFavourite(
//                                             LocationHistoryDataModel(
//                                                 locationTitle: data[0].name,
//                                                 locationDescription:
//                                                     data[0].address,
//                                                 latitude: data[0]
//                                                         .location
//                                                         ?.latitude ??
//                                                     0,
//                                                 longitude: data[0]
//                                                         .location
//                                                         ?.longitude ??
//                                                     0));
//
//                                         state(() {});
//                                       },
//                                     ),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//
//                           Row(
//                             children: [
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Clr.teal,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     )),
//                                 onPressed: () async {
//                                   LatLng destination =
//                                       data[0].location ?? LatLng(0, 0);
//                                   if (data[0].location != null) {
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 RouteDirectionMapScreen(
//                                                     parentScreenName: RouteName
//                                                         .nearByChargingScreen,
//                                                     "",
//                                                     "${data[0].name} ${data[0].address}",
//                                                     destination)));
//                                   } else {
//                                     printMsg(
//                                         "Nearby charger Sheet: Destination Latlng is Null");
//                                   }
//                                 },
//                                 child: Icon(
//                                   Icons.directions_outlined,
//                                   color: Clr.black,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     elevation: 0,
//                                     backgroundColor: Colors.transparent,
//                                     shape: RoundedRectangleBorder(
//                                       side:
//                                           BorderSide(color: Clr.teal, width: 1),
//                                       borderRadius: BorderRadius.circular(10),
//                                     )),
//                                 onPressed: () {},
//                                 child: Icon(
//                                   Icons.calendar_view_day,
//                                   color: Clr.teal,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(
//                                 15,
//                               ),
//                             ),
//                             child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "More Charging stations nearby",
//                                     style: Style.conigenColorChangableRegularText(
//                                         color: Clr.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   SizedBox(
//                                     height: 15,
//                                   ),
//                                   SizedBox(
//                                     width: MediaQuery.of(context).size.width,
//                                     child: SingleChildScrollView(
//                                       scrollDirection: Axis.horizontal,
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.tune_rounded,
//                                             color: Clr.white,
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           SizedBox(
//                                             height: 25,
//                                             child: ElevatedButton(
//                                                 style: ElevatedButton.styleFrom(
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         6)),
//                                                     backgroundColor: Clr.teal
//                                                         .withOpacity(0.1)),
//                                                 onPressed: () {},
//                                                 child: Text(
//                                                   "Distance",
//                                                   style: Style.conigenColorChangableRegularText(
//                                                       color: Clr.teal,
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold),
//                                                 )),
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           SizedBox(
//                                             height: 25,
//                                             child: ElevatedButton(
//                                                 style: ElevatedButton.styleFrom(
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         6)),
//                                                     backgroundColor: Clr.teal
//                                                         .withOpacity(0.1)),
//                                                 onPressed: () {},
//                                                 child: Text(
//                                                   "Open Now",
//                                                   style: Style.conigenColorChangableRegularText(
//                                                       color: Clr.teal,
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold),
//                                                 )),
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           SizedBox(
//                                             height: 25,
//                                             child: ElevatedButton(
//                                                 style: ElevatedButton.styleFrom(
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         6)),
//                                                     backgroundColor: Clr.teal
//                                                         .withOpacity(0.1)),
//                                                 onPressed: () {},
//                                                 child: Text(
//                                                   "Top-Rated",
//                                                   style: Style.conigenColorChangableRegularText(
//                                                       color: Clr.teal,
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold),
//                                                 )),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         0.5,
//                                     child: data.isNotEmpty
//                                         ? ListView.builder(
//                                             itemCount: data.length - 1,
//                                             itemBuilder: (context, index) {
//                                               String? chargerType =
//                                                   data[index + 1].chargerType;
//                                               String status = data[index + 1]
//                                                           .isAvailable ==
//                                                       null
//                                                   ? ""
//                                                   : data[index + 1]
//                                                               .isAvailable ==
//                                                           true
//                                                       ? "Open"
//                                                       : "Closed";
//                                               double? distance =
//                                                   data[index + 1].distance;
//
//                                               int? report =
//                                                   data[index + 1].reports;
//
//                                               int? chargingSlot =
//                                                   data[index + 1].availableSlot;
//
//                                               if (chargerType != null) {
//                                                 if (chargerType
//                                                         .contains("CCS") &&
//                                                     chargerType.contains("2")) {
//                                                   chargerType = "CCS2";
//                                                 }
//                                                 if (chargerType
//                                                     .contains("CCS")) {
//                                                   chargerType = "CCS";
//                                                 }
//                                               }
//
//                                               return Container(
//                                                 // height: 100,
//                                                 padding: EdgeInsets.only(
//                                                     top: 15,
//                                                     bottom: 15,
//                                                     right: 10),
//                                                 decoration: BoxDecoration(
//                                                     border: Border(
//                                                         bottom: BorderSide(
//                                                             color: Clr.mainGrey,
//                                                             width: 0.2))),
//                                                 child: Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                             data[index + 1]
//                                                                     .name ??
//                                                                 "",
//                                                             maxLines: 3,
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: Style
//                                                                 .conigenColorChangableRegularText(
//                                                                     color: Clr
//                                                                         .white,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     fontSize:
//                                                                         16),
//                                                           ),
//                                                           Text(
//                                                             data[index + 1]
//                                                                     .address ??
//                                                                 "",
//                                                             maxLines: 3,
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: Style
//                                                                 .conigenColorChangableRegularText(),
//                                                           ),
//                                                           SizedBox(
//                                                             height: 10,
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               if (distance !=
//                                                                   null)
//                                                                 Row(
//                                                                   children: [
//                                                                     Icon(
//                                                                       Icons
//                                                                           .location_pin,
//                                                                       size: 16,
//                                                                       color: Clr
//                                                                           .teal,
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 5,
//                                                                     ),
//                                                                     Text(
//                                                                       distance
//                                                                           .toInt()
//                                                                           .toString(),
//                                                                       style: Style.conigenColorChangableRegularText(
//                                                                           fontSize:
//                                                                               12),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                               SizedBox(
//                                                                 width: 5,
//                                                               ),
//                                                               if (status
//                                                                   .isNotEmpty)
//                                                                 Row(
//                                                                   children: [
//                                                                     Icon(
//                                                                       Icons
//                                                                           .flash_on_outlined,
//                                                                       size: 16,
//                                                                       color: status ==
//                                                                               "Open"
//                                                                           ? Clr
//                                                                               .green1
//                                                                           : Clr
//                                                                               .buttonRed1,
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 5,
//                                                                     ),
//                                                                     Text(
//                                                                       status ==
//                                                                               "Open"
//                                                                           ? "Open"
//                                                                           : "Closed",
//                                                                       style: Style.conigenColorChangableRegularText(
//                                                                           color: status == "Open"
//                                                                               ? Clr.green1
//                                                                               : Clr.buttonRed1,
//                                                                           fontSize: 12),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                               SizedBox(
//                                                                 width: 5,
//                                                               ),
//                                                               if (report !=
//                                                                   null)
//                                                                 Row(
//                                                                   children: [
//                                                                     Icon(
//                                                                       Icons
//                                                                           .security_outlined,
//                                                                       size: 16,
//                                                                       color: Clr
//                                                                           .buttonOrange,
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 5,
//                                                                     ),
//                                                                     Text(
//                                                                       "$report Reports",
//                                                                       style: Style.conigenColorChangableRegularText(
//                                                                           fontSize:
//                                                                               12),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                             ],
//                                                           ),
//                                                           SizedBox(
//                                                             height: 7,
//                                                           ),
//                                                           if ((chargerType !=
//                                                                       null &&
//                                                                   chargerType
//                                                                       .isNotEmpty) ||
//                                                               (chargingSlot !=
//                                                                       null &&
//                                                                   chargingSlot ==
//                                                                       0))
//                                                             Row(
//                                                               children: [
//                                                                 if (chargerType !=
//                                                                     null)
//                                                                   Text(
//                                                                     chargerType,
//                                                                     style: Style
//                                                                         .conigenColorChangableRegularText(
//                                                                             color:
//                                                                                 Clr.green1),
//                                                                   ),
//                                                                 SizedBox(
//                                                                   width: 30,
//                                                                 ),
//                                                                 if (chargingSlot !=
//                                                                     null)
//                                                                   Text(
//                                                                     "$chargingSlot Slot",
//                                                                     style: Style
//                                                                         .conigenColorChangableRegularText(
//                                                                             color:
//                                                                                 Clr.green1),
//                                                                   )
//                                                               ],
//                                                             )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding: EdgeInsets.only(
//                                                           left: 10),
//                                                       child: InkWell(
//                                                         onTap: () async {
//                                                           LatLng destination =
//                                                               data[index + 1]
//                                                                       .location ??
//                                                                   LatLng(0, 0);
//
//                                                           if (data[index + 1]
//                                                                   .location !=
//                                                               null) {
//                                                             Navigator.push(
//                                                                 context,
//                                                                 MaterialPageRoute(
//                                                                     builder: (context) => RouteDirectionMapScreen(
//                                                                         parentScreenName:
//                                                                             RouteName.nearByChargingScreen,
//                                                                         "",
//                                                                         "${data[index + 1].name} ${data[index + 1].address}",
//                                                                         destination)));
//                                                           } else {
//                                                             printMsg(
//                                                                 "Nearby charger Sheet: Destination Latlng is Null");
//                                                           }
//                                                         },
//                                                         child: Container(
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10),
//                                                               border:
//                                                                   Border.all(
//                                                                 color: Clr.teal,
//                                                               ),
//                                                               // color: Clr
//                                                               //     .white1
//                                                             ),
//                                                             height: 40,
//                                                             width: 40,
//                                                             child: Icon(
//                                                               Icons
//                                                                   .directions_outlined,
//                                                               color: Clr.teal,
//                                                             )),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                               );
//                                             })
//                                         : Container(
//                                             child: Text(
//                                               "ooh!!, It's look like there is no charching available",
//                                               style: Style.conigenColorChangableRegularText(),
//                                             ),
//                                           ),
//                                   )
//                                 ]),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               if (data == null || data.isEmpty)
//                 SizedBox(
//                   // height: 100,
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.only(
//                           left: 35, right: 35, bottom: 100, top: 20),
//                       child: Text(
//                         "Sorry, We couldn't find any charger near to you!",
//                         textAlign: TextAlign.center,
//                         maxLines: 3,
//                         style: Style.conigenColorChangableRegularText(
//                             fontSize: 24,
//                             color: Clr.white,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 )
//             ],
//           ),
//         );
//       });
// }
