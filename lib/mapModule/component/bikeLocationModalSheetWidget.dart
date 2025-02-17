// Model sheet to show the current location of the bike
import 'package:flutter/material.dart';

import '../../../Constants/colors.dart';
import '../../../Constants/styles.dart';
import '../../Methods/hideKeyboard.dart';

Future<dynamic> bikeLocationModalBottomSheet(BuildContext context,
    String bikename, bool isOnline, String bikeNumber, String address,
    {Function? onModalClose}) {
  return showModalBottomSheet(
    backgroundColor: Clr.black,
    elevation: 0,
    // barrierColor: Clr.w,

    enableDrag: true,
    useSafeArea: false,
    isDismissible: true,
    showDragHandle: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, state) => Wrap(
          children: [
            SizedBox(
              // height: 200,
              width: MediaQuery.sizeOf(context).width,
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                decoration: BoxDecoration(
                    color: Clr.black, borderRadius: BorderRadius.circular(10)),
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
                                bikename,
                                style: Style.conigenColorChangableRegularText(
                                    color: Clr.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    bikeNumber,
                                    style: Style.conigenColorChangableRegularText(
                                        color: Clr.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                    child: VerticalDivider(
                                      color: Clr.white,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 30),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      isOnline ? Clr.green1 : Clr.buttonRed1),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            isOnline ? "Online" : "Offline",
                            style: Style.conigenColorChangableRegularText(
                                color: isOnline ? Clr.green1 : Clr.buttonRed1,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      address,
                      maxLines: 3,
                      style: Style.conigenColorChangableRegularText(fontSize: 14),
                    ),
                    SizedBox(
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
                          onPressed: () {
                            printMsg("Hello Direction Call");
                            Navigator.pop(context);
                          },
                          label: Text(
                            "Find Me",
                            style: Style.conigenColorChangableRegularText(
                                // fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Clr.black),
                          ),
                          icon: Icon(
                            Icons.navigation_outlined,
                            color: Clr.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Clr.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side:
                                        BorderSide(color: Clr.teal, width: 1))),
                            onPressed: () {},
                            label: Text(
                              "Share to Location",
                              style: Style.conigenColorChangableRegularText(
                                  // fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Clr.teal),
                            ),
                            icon: Icon(
                              Icons.share,
                              color: Clr.teal,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                          border:
                              Border.all(color: Clr.buttonRed1, width: 0.3)),
                      child: Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Clr.buttonRed1,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lost Mode",
                                  style: Style.conigenColorChangableRegularText(
                                      color: Clr.buttonRed1, fontSize: 18),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: Text(
                                    softWrap: false,
                                    maxLines: 5,
                                    textWidthBasis: TextWidthBasis.longestLine,
                                    overflow: TextOverflow.ellipsis,
                                    "Activate Lost mode and call customer care for further help",
                                    style: Style.conigenColorChangableRegularText(fontSize: 14),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: Clr.buttonRed1,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.wifi_calling_3_outlined,
                              color: Clr.white,
                              size: 15,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Report to Customer Care",
                              style: Style.conigenColorChangableRegularText(
                                  color: Clr.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ]),
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
    },
  ).whenComplete(() {
    if (onModalClose != null) {
      onModalClose();
    }
  });
}
