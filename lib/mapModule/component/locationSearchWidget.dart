// ignore_for_file: public_member_api_docs, sort_constructors_first
//Widget for the search location on the top
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../Constants/colors.dart';
import '../../../Constants/routeName.dart';
import '../../../Constants/styles.dart';
import '../locationSearchScreen.dart';

// ignore: must_be_immutable
class LocationSearchWidget extends StatelessWidget {
  String location;
  LocationSearchWidget({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  settings: RouteSettings(name: RouteName.locationSearchScreen),
                  builder: (context) => FullScreenLocationSearchScreen(
                        sourceLocation: location,
                        sourceLatLng: LatLng(0, 0),
                      )));
        });
      },
      child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
              color: Clr.mainGrey, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Clr.teal,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                location.isEmpty ? "Search Location" : location,
                style: Style.conigenColorChangableRegularText(
                    fontWeight: FontWeight.bold, color: Clr.white),
              ),
            ],
          )),
    );
  }
}

Container locationSearchWidget(String location, BuildContext context) {
  TextEditingController controller = TextEditingController();
  controller.text = location;
  return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            blurRadius: 1,
            spreadRadius: 1,
            color: Clr.constBlack.withOpacity(0.1))
      ], color: Clr.mainGrey, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        style: Style.conigenColorChangableRegularText(
            fontWeight: FontWeight.bold, color: Clr.white),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              color: Clr.teal,
            ),
            border: InputBorder.none,
            hintText: "Search Location",
            hintStyle: Style.conigenColorChangableRegularText(
              fontWeight: FontWeight.bold,
            ),
            fillColor: Colors.black),
        maxLines: 1,
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyPage()));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullScreenLocationSearchScreen(
                          sourceLocation: controller.text,
                          sourceLatLng: LatLng(0, 0),
                        )));
          });
        },
        onChanged: (text) {
          // makeSuggestion(locationSearchBarController.text);
        },
      ));
}
