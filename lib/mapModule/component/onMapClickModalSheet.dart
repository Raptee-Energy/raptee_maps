// A model sheet to show the details of the marked location
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../Constants/colors.dart';
import '../../../Constants/routeName.dart';
import '../../../Constants/styles.dart';
import '../../../Constants/tempData.dart';
import '../../../Models/locationHistoryDataModel.dart';
import '../../Methods/hideKeyboard.dart';
import '../routeDirectionMapScreen.dart';

Future<dynamic> onMapClickModalBottomSheet(
    BuildContext context,
    String place,
    String street,
    String subLocality,
    String address,
    LatLng locationLatLng,
    LatLng currentLatLng,
    {Function? onRouteFound,
    Function? onRouteSelected,
    required String parentScreenName}) {
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
          if (place == locationData.locationTitle) {
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
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
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
                                  "$place $street, $subLocality",
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  style: Style.conigenColorChangableRegularText(
                                      color: Clr.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Row(
                                //   children: [
                                //     Text(
                                //       "12 kms, 15 mins",
                                //       style: Style.fadeTextStyle(
                                //           color: Clr.green,
                                //           fontWeight: FontWeight.bold),
                                //     )
                                //   ],
                                // )
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (!isLocationSaved) {
                                  var list = TempData.addLocationDataToFavourite(
                                      LocationHistoryDataModel(
                                          latitude: locationLatLng.latitude,
                                          longitude: locationLatLng.longitude,
                                          locationTitle: place,
                                          locationDescription:
                                              "$place $street, $subLocality"));
                                  TempData.pinnedLocationList.add(
                                      LocationHistoryDataModel(
                                          latitude: locationLatLng.latitude,
                                          longitude: locationLatLng.longitude,
                                          locationTitle: place,
                                          locationDescription:
                                              "$place $street, $subLocality"));

                                  printMsg(
                                      "The lenth of favourite Location ${list.length}");
                                  printMsg(
                                      "The lenth of favourite Location ${TempData.pinnedLocationList.length}");
                                } else {
                                  TempData.favouriteLocationList.removeWhere(
                                      (element) =>
                                          element.locationTitle == place);
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
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        address,
                        maxLines: 3,
                        style: Style.conigenColorChangableRegularText(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Clr.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: RouteSettings(
                                          name: RouteName.routeDirectionScreen),
                                      builder: (context) => RouteDirectionMapScreen(
                                          parentScreenName: parentScreenName,
                                          "",
                                          "$place $street, $subLocality $address",
                                          locationLatLng)));
                            },
                            label: Text(
                              "Directions",
                              style: Style.conigenColorChangableRegularText(
                                  // fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Clr.black),
                            ),
                            icon: Icon(
                              Icons.directions,
                              color: Clr.black,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
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
                      const SizedBox(
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
