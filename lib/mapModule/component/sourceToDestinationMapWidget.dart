// Widget to show source to destination search widget

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../Constants/appFont.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/routeName.dart';
import '../sourceToDestinationLocationPickerScreen.dart';

Widget sourceToDestinationWidget(
    BuildContext context,
    TextEditingController sourceController,
    TextEditingController destinationController,
    LatLng sourceLatLng,
    LatLng destinationlatLng,
    {required String parentScreenName}) {
  return Container(
    margin: const EdgeInsets.only(top: 50, left: 25, right: 25),
    width: double.infinity,
    decoration: const BoxDecoration(color: Colors.transparent),
    height: 110,
    child: Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.all(0),
                    backgroundColor: Clr.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Clr.white,
                )),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Clr.black, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Icon(
                Icons.location_searching,
                size: 30,
                color: Clr.teal,
              ),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0, backgroundColor: Clr.black),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(
                                  name: RouteName
                                      .sourceDestinationLocationSearchScreen),
                              builder: (context) =>
                                  SourceDestinationLocationPickerScreen(
                                      parentScreenName: parentScreenName,
                                      sourceLatLng,
                                      destinationlatLng,
                                      sourceController.text.isNotEmpty
                                          ? sourceController.text
                                              .split(",")
                                              .first
                                          : "",
                                      destinationController.text,
                                      true)));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        sourceController.text.isNotEmpty
                            ? sourceController.text
                            : "Current Location",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            fontFamily: AppFont.conigen,
                            color: Clr.white),
                      ),
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Clr.black, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Icon(
                Icons.location_pin,
                size: 30,
                color: Clr.buttonRed1,
              ),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0, backgroundColor: Clr.black),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(
                                  name: RouteName
                                      .sourceDestinationLocationSearchScreen),
                              builder: (context) =>
                                  SourceDestinationLocationPickerScreen(
                                      parentScreenName: parentScreenName,
                                      sourceLatLng,
                                      destinationlatLng,
                                      sourceController.text,
                                      destinationController.text
                                          .split(",")
                                          .first,
                                      false)));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        destinationController.text.isNotEmpty
                            ? destinationController.text
                            : "Destination Location",
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            fontFamily: AppFont.conigen,
                            color: Clr.white),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
