import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../Constants/colors.dart';
import '../../../Constants/styles.dart';
import '../../../Constants/tempData.dart';
import '../../../Models/locationHistoryDataModel.dart';
import '../../Methods/hideKeyboard.dart';

Future<dynamic> onRouteClickModalBottomSheet(
    BuildContext context,
    String time,
    String distance,
    String sourceAddress,
    String destinationAddress,
    LatLng sourceLatlng,
    LatLng destinationLatlng,
    {bool isLocationSaved = false}) {
  return showModalBottomSheet(
      backgroundColor: Clr.black,
      elevation: 0,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        bool isLocationSaved = false;
        for (LocationHistoryDataModel locationData
            in TempData.favouriteLocationList) {
          if (destinationAddress.split(",").first ==
              locationData.locationTitle) {
            isLocationSaved = true;
          }
        }
        return StatefulBuilder(
          builder: (context, state) => Wrap(
            children: [
              SizedBox(
                // height: 200,
                width: MediaQuery.sizeOf(context).width,
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Clr.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ignore: prefer_interpolation_to_compose_strings
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destinationAddress,
                                  maxLines: 3,
                                  style: Style.conigenColorChangableRegularText(
                                      color: Clr.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      distance,
                                      style: Style.conigenColorChangableRegularText(
                                          color: Clr.green1,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      time,
                                      style: Style.conigenColorChangableRegularText(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (!isLocationSaved) {
                                  var list =
                                      TempData.addLocationDataToFavourite(
                                          LocationHistoryDataModel(
                                              latitude:
                                                  destinationLatlng.latitude,
                                              longitude:
                                                  destinationLatlng.longitude,
                                              locationTitle: destinationAddress
                                                  .split(",")
                                                  .first,
                                              locationDescription:
                                                  destinationAddress.substring(
                                                destinationAddress
                                                            .split(",")
                                                            .first
                                                            .length *
                                                        2 +
                                                    2,
                                              )));
                                  TempData.pinnedLocationList.add(
                                      LocationHistoryDataModel(
                                          latitude: destinationLatlng.latitude,
                                          longitude:
                                              destinationLatlng.longitude,
                                          locationTitle: destinationAddress
                                              .split(",")
                                              .first,
                                          locationDescription:
                                              destinationAddress.substring(
                                            destinationAddress
                                                        .split(",")
                                                        .first
                                                        .length *
                                                    2 +
                                                2,
                                          )));

                                  printMsg(
                                      "The lenth of favourite Location ${list.length}");
                                  printMsg(
                                      "The lenth of favourite Location ${TempData.pinnedLocationList.length}");
                                } else {
                                  TempData.favouriteLocationList.removeWhere(
                                      (element) =>
                                          element.locationTitle ==
                                          destinationAddress.split(",").first);
                                }

                                state(() {
                                  isLocationSaved = !isLocationSaved;
                                });
                              },
                              icon: Icon(
                                isLocationSaved
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color:
                                    isLocationSaved ? Clr.buttonRed1 : Clr.teal,
                              ))
                        ],
                      ),
                      //  SizedBox(
                      //   height: 20,
                      // ),
                      // Text(
                      //   "From :",
                      //   style: Style.fadeTextStyle(color: Clr.white1),
                      // ),
                      // Text(
                      //   sourceAddress,
                      //   maxLines: 3,
                      //   style: Style.fadeTextStyle(fontSize: 14),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Clr.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: Clr.teal, width: 1))),
                              onPressed: () {},
                              label: Text(
                                "Share to Buddy",
                                style: Style.conigenColorChangableRegularText(
                                    // fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Clr.teal),
                              ),
                              icon: Icon(
                                Icons.send_outlined,
                                color: Clr.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
