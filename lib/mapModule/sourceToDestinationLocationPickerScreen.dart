/*
// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:navtesttwo/mapModule/routeDirectionMapScreen.dart';
import 'package:geocoding/geocoding.dart' as Geocoder;

import '../../BLoC/mapBLoC/setHomeLocation.dart';
import '../../BLoC/mapBLoC/setOfficeLocation.dart';
import '../../Constants/appFont.dart';
import '../../Constants/colors.dart';
import '../../Constants/locationData.dart';
import '../../Constants/routeName.dart';
import '../../Constants/styles.dart';
import '../../Constants/tempData.dart';
import '../../Models/locationHistoryDataModel.dart';
import '../../Models/nearbyChargingStationDataModel.dart';
import '../../Repo/direction.dart';
import '../../methods/hideKeyboard.dart';
import 'component/setFavouriteLocationHomeWork.dart';

class SourceDestinationLocationPickerScreen extends StatefulWidget {
  final String? sourceLocation;
  final String? destinationLocation;
  final LatLng? sourceLatLng;
  final LatLng? destinationLatLng;
  final bool isThisSourceLocation;
  String parentScreenName;
  SourceDestinationLocationPickerScreen(
      this.sourceLatLng,
      this.destinationLatLng,
      this.sourceLocation,
      this.destinationLocation,
      this.isThisSourceLocation,
      {required this.parentScreenName,
      super.key});

  @override
  State<SourceDestinationLocationPickerScreen> createState() =>
      _SourceDestinationLocationPickerScreenState();
}

class _SourceDestinationLocationPickerScreenState
    extends State<SourceDestinationLocationPickerScreen> {
  LatLng currentLocationLatLng = LatLng(0, 0);
  LatLng destinationLatLng = LatLng(0, 0);
  String sourceAdress = "";
  String destinationAdress = "";

  bool isShowNearByChargingStation = false;
  bool isShowFavouriteLocation = false;
  bool isThisSourceLocation = false;

  TextEditingController controller = TextEditingController();

  List<NearbyChargingStationDataModel> nearByChargingData = [];
  List<LocationHistoryDataModel> locationHistoryList = [];
  List<dynamic> suggestedPlaceList = [];

  @override
  void initState() {
    // TODO: implement initState
    locationHistoryList = TempData.locationHistoryList;

    if (widget.isThisSourceLocation) {
      isThisSourceLocation = true;
      controller.text = widget.sourceLocation ?? "";
    } else {
      controller.text = widget.destinationLocation ?? "";
    }
    currentLocationLatLng = widget.sourceLatLng ?? LatLng(0, 0);
    destinationLatLng = widget.destinationLatLng ?? LatLng(0, 0);
    sourceAdress = widget.sourceLocation ?? "";
    destinationAdress = widget.destinationLocation ?? "";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await DirectionsRepository()
          .makeSuggestion(controller.text)
          .then((value) {
        suggestedPlaceList = value;
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(25, 40, 15, 0),
          decoration: BoxDecoration(
            color: Clr.black,
          ),
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
                          backgroundColor: Clr.mainGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Clr.white,
                      )),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 10, 0),
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      decoration: BoxDecoration(
                          color: Clr.mainGrey,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 1,
                                color: Clr.constBlack.withOpacity(0.1))
                          ],
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        style: Style.conigenColorChangableRegularText(
                            fontWeight: FontWeight.bold, color: Clr.white),
                        controller: controller,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
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
                          setState(() {
                            isShowFavouriteLocation = false;
                            isShowNearByChargingStation = false;
                          });
                        },
                        onChanged: (text) async {
                          try {
                            await DirectionsRepository()
                                .makeSuggestion(controller.text)
                                .then((value) {
                              suggestedPlaceList = value;

                              setState(() {
                                isShowFavouriteLocation = false;
                                isShowNearByChargingStation = false;
                              });
                            });
                          } on Exception catch (e) {
                            // TODO

                            printMsg(
                                "Error in Suggestion Call: ${e.toString()}");
                          }
                        },
                      ))),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (LocationTempData.homeLocation != null) {
                              final location = LocationTempData.homeLocation!;
                              double lat, lng;

                              lat = location.latitude ?? 0;
                              lng = location.longitude ?? 0;

                              if (!isThisSourceLocation) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(
                                            name:
                                                RouteName.routeDirectionScreen),
                                        builder: (context) =>
                                            RouteDirectionMapScreen(
                                              parentScreenName:
                                                  widget.parentScreenName,
                                              sourceAdress,
                                              location.locationTitle ??
                                                  "" +
                                                      "," +
                                                      location
                                                          .locationDescription!,
                                              LatLng(lat, lng),
                                              sourecLatLng:
                                                  currentLocationLatLng,
                                            )),
                                    (route) =>
                                        route.settings.name ==
                                        widget.parentScreenName);
                              } else {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(
                                            name:
                                                RouteName.routeDirectionScreen),
                                        builder: (context) =>
                                            RouteDirectionMapScreen(
                                              parentScreenName:
                                                  widget.parentScreenName,
                                              location.locationTitle ??
                                                  "" +
                                                      "," +
                                                      location
                                                          .locationDescription!,
                                              destinationAdress,
                                              destinationLatLng,
                                              sourecLatLng: LatLng(lat, lng),
                                            )),
                                    (route) =>
                                        route.settings.name ==
                                        widget.parentScreenName);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 15),
                            margin: const EdgeInsets.only(
                                top: 15, bottom: 15, right: 10),
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Clr.mainGrey, width: 1))),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: Clr.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Home",
                                        style: Style.conigenColorChangableRegularText(
                                            color: Clr.white, fontSize: 12),
                                      ),
                                      BlocConsumer<SetHomeLocationBloc,
                                          SetHomeLocationState>(
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          LocationHistoryDataModel location =
                                              LocationHistoryDataModel();
                                          if (state is SetHomeLocationInitial) {
                                            location =
                                                LocationHistoryDataModel();
                                          }
                                          if (state is SetHomeLocationChange) {
                                            location = state.location;
                                          }
                                          return Text(
                                              location.locationTitle ??
                                                  "Set Location",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: AppFont.conigen,
                                                  color: Clr.mainGrey));
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (LocationTempData.officeLocation != null) {
                              final location = LocationTempData.officeLocation!;
                              double lat, lng;

                              lat = location.latitude ?? 0;
                              lng = location.longitude ?? 0;

                              if (!isThisSourceLocation) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(
                                            name:
                                                RouteName.routeDirectionScreen),
                                        builder: (context) =>
                                            RouteDirectionMapScreen(
                                              parentScreenName:
                                                  widget.parentScreenName,
                                              sourceAdress,
                                              location.locationTitle ??
                                                  "" +
                                                      "," +
                                                      location
                                                          .locationDescription!,
                                              LatLng(lat, lng),
                                              sourecLatLng:
                                                  currentLocationLatLng,
                                            )),
                                    (route) =>
                                        route.settings.name ==
                                        widget.parentScreenName);
                              } else {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(
                                            name:
                                                RouteName.routeDirectionScreen),
                                        builder: (context) =>
                                            RouteDirectionMapScreen(
                                              parentScreenName:
                                                  widget.parentScreenName,
                                              location.locationTitle ??
                                                  "" +
                                                      "," +
                                                      location
                                                          .locationDescription!,
                                              destinationAdress,
                                              destinationLatLng,
                                              sourecLatLng: LatLng(lat, lng),
                                            )),
                                    (route) =>
                                        route.settings.name ==
                                        widget.parentScreenName);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 15),
                            margin: const EdgeInsets.only(
                                top: 15, bottom: 15, right: 10),
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Clr.mainGrey, width: 1))),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  color: Clr.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Work",
                                        style: Style.conigenColorChangableRegularText(
                                            color: Clr.white, fontSize: 12),
                                      ),
                                      BlocConsumer<SetOfficeLocationBloc,
                                          SetOfficeLocationState>(
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          LocationHistoryDataModel location =
                                              LocationHistoryDataModel();
                                          if (state is SetHomeLocationInitial) {
                                            location =
                                                LocationHistoryDataModel();
                                          }
                                          if (state
                                              is SetOfficeLocationChanged) {
                                            location = state.location;
                                          }
                                          return Text(
                                              location.locationTitle ??
                                                  "Set Location",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: AppFont.conigen,
                                                  color: Clr.mainGrey));
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            isShowNearByChargingStation =
                                !isShowNearByChargingStation;

                            isShowFavouriteLocation = false;

                            try {
                              DirectionsRepository()
                                  .searchNearbyEvChargingStations(
                                      currentLocationLatLng)
                                  .then((data) {
                                if (data != null) {
                                  nearByChargingData = data;
                                  setState(() {});
                                }
                              });
                            } on Exception catch (e) {
                              debugPrint(e.toString());
                            }
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 15),
                            margin: const EdgeInsets.only(
                                top: 15, bottom: 15, right: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.ev_station_outlined,
                                  color: isShowNearByChargingStation
                                      ? Clr.teal
                                      : Clr.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Chargin Station",
                                  style: Style.conigenColorChangableRegularText(
                                      color: isShowNearByChargingStation
                                          ? Clr.teal
                                          : Clr.white,
                                      fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            isShowFavouriteLocation = !isShowFavouriteLocation;
                            isShowNearByChargingStation = false;

                            printMsg(
                                "Saved Location List ${TempData.favouriteLocationList}");

                            printMsg(
                                "Show favourite location: $isShowFavouriteLocation");

                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 15),
                            margin: const EdgeInsets.only(
                                top: 15, bottom: 15, right: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark_outline_rounded,
                                  color: isShowFavouriteLocation
                                      ? Clr.teal
                                      : Clr.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Saved Location",
                                  style: Style.conigenColorChangableRegularText(
                                      color: isShowFavouriteLocation
                                          ? Clr.teal
                                          : Clr.white,
                                      fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        )
                      ]),
                ),
              ),
              if (isShowFavouriteLocation)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Favourite Location",
                        style: Style.conigenColorChangableRegularText(color: Clr.teal),
                      ),
                    )),
              if (isShowFavouriteLocation)
                Expanded(
                  child: TempData.favouriteLocationList.isNotEmpty
                      ? ListView.builder(
                          itemCount: TempData.favouriteLocationList.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            String locationTitle = TempData
                                    .favouriteLocationList[index]
                                    .locationTitle ??
                                "";
                            String locationDescription = TempData
                                    .favouriteLocationList[index]
                                    .locationDescription ??
                                "";
                            ;
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Clr.mainGrey, width: 0.2))),
                              child: InkWell(
                                onLongPress: () {
                                  printMsg("Long pressed");

                                  SetLocAsHomeWorkDialog(context,
                                      TempData.favouriteLocationList[index]);
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  focusColor: Clr.white,
                                  title: Text(
                                    maxLines: 3,
                                    locationTitle,
                                    style:
                                        Style.conigenColorChangableRegularText(color: Clr.white),
                                  ),
                                  subtitle: Text(
                                    locationDescription,
                                    maxLines: 3,
                                    style: Style.conigenColorChangableRegularText(),
                                  ),
                                  onTap: () async {
                                    // try {
                                    double lat, lng;

                                    lat = TempData.favouriteLocationList[index]
                                            .latitude ??
                                        0;
                                    lng = TempData.favouriteLocationList[index]
                                            .longitude ??
                                        0;

                                    if (!isThisSourceLocation) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: RouteName
                                                      .routeDirectionScreen),
                                              builder: (context) =>
                                                  RouteDirectionMapScreen(
                                                    parentScreenName:
                                                        widget.parentScreenName,
                                                    sourceAdress,
                                                    locationTitle +
                                                        "," +
                                                        locationDescription,
                                                    LatLng(lat, lng),
                                                    sourecLatLng:
                                                        currentLocationLatLng,
                                                  )),
                                          (route) =>
                                              route.settings.name ==
                                              widget.parentScreenName);
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: RouteName
                                                      .routeDirectionScreen),
                                              builder: (context) =>
                                                  RouteDirectionMapScreen(
                                                    parentScreenName:
                                                        widget.parentScreenName,
                                                    locationTitle +
                                                        "," +
                                                        locationDescription,
                                                    destinationAdress,
                                                    destinationLatLng,
                                                    sourecLatLng:
                                                        LatLng(lat, lng),
                                                  )),
                                          (route) =>
                                              route.settings.name ==
                                              widget.parentScreenName);
                                    }
                                  },
                                ),
                              ),
                            );
                          })
                      : Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: Text(
                            "No Saved Location Found",
                            style: Style.conigenColorChangableRegularText(),
                          ),
                        ),
                ),
              if (isShowNearByChargingStation)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Nearby Charging Station",
                        style: Style.conigenColorChangableRegularText(color: Clr.teal),
                      ),
                    )),
              if (isShowNearByChargingStation)
                Expanded(
                  child: nearByChargingData.isNotEmpty
                      ? ListView.builder(
                          itemCount: nearByChargingData.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            String locationTitle =
                                nearByChargingData[index].name ?? "";
                            String locationDescription =
                                nearByChargingData[index].address ?? "";

                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Clr.mainGrey, width: 0.2))),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                focusColor: Clr.white,
                                leading: nearByChargingData[index]
                                            .isAvailable !=
                                        null
                                    ? Text(
                                        nearByChargingData[index].isAvailable!
                                            ? "Open"
                                            : "Closed",
                                        style: Style.conigenColorChangableRegularText(
                                            color: nearByChargingData[index]
                                                    .isAvailable!
                                                ? Clr.green1
                                                : Clr.buttonRed1),
                                      )
                                    : SizedBox(),
                                title: Text(
                                  locationTitle,
                                  maxLines: 3,
                                  style: Style.conigenColorChangableRegularText(color: Clr.white),
                                ),
                                subtitle: Text(
                                  locationDescription,
                                  maxLines: 3,
                                  style: Style.conigenColorChangableRegularText(),
                                ),
                                onTap: () async {
                                  try {
                                    double lat, lng;
                                    // List<Geocoder.Location> locations =
                                    await Geocoder.locationFromAddress(
                                            locationDescription)
                                        .then((location) {
                                      lat = location.last.latitude;
                                      lng = location.last.longitude;

                                      TempData.addLocationDataToLocationHitory(
                                          LocationHistoryDataModel(
                                              locationTitle: locationTitle,
                                              locationDescription:
                                                  locationDescription,
                                              latitude: lat,
                                              longitude: lng));

                                      Navigator.pop(context);

                                      if (!isThisSourceLocation) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                settings: RouteSettings(
                                                    name: RouteName
                                                        .routeDirectionScreen),
                                                builder: (context) =>
                                                    RouteDirectionMapScreen(
                                                      parentScreenName: widget
                                                          .parentScreenName,
                                                      sourceAdress,
                                                      locationTitle +
                                                          "," +
                                                          locationDescription,
                                                      LatLng(lat, lng),
                                                      sourecLatLng:
                                                          currentLocationLatLng,
                                                    )),
                                            (route) =>
                                                route.settings.name ==
                                                widget.parentScreenName);
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                settings: RouteSettings(
                                                    name: RouteName
                                                        .routeDirectionScreen),
                                                builder: (context) =>
                                                    RouteDirectionMapScreen(
                                                      parentScreenName: widget
                                                          .parentScreenName,
                                                      locationTitle +
                                                          "," +
                                                          locationDescription,
                                                      destinationAdress,
                                                      destinationLatLng,
                                                      sourecLatLng:
                                                          LatLng(lat, lng),
                                                    )),
                                            (route) =>
                                                route.settings.name ==
                                                widget.parentScreenName);
                                      }

                                      return location;
                                    });
                                  } on Exception catch (e) {
                                    printMsg(
                                        "Error in OnTap Search Location: $e");
                                  }
                                },
                              ),
                            );
                          })
                      : Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: Text(
                            "No charging Station found",
                            style: Style.conigenColorChangableRegularText(),
                          ),
                        ),
                ),
              if (suggestedPlaceList.isNotEmpty &&
                  !isShowNearByChargingStation &&
                  !isShowFavouriteLocation)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Suggested loction",
                        style: Style.conigenColorChangableRegularText(color: Clr.teal),
                      ),
                    )),
              if (suggestedPlaceList.isNotEmpty &&
                  !isShowNearByChargingStation &&
                  !isShowFavouriteLocation)
                Expanded(
                  child: suggestedPlaceList.isNotEmpty
                      ? ListView.builder(
                          itemCount: suggestedPlaceList.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            String locationTitle = suggestedPlaceList[index]
                                ["structured_formatting"]["main_text"];
                            String locationDescription =
                                suggestedPlaceList[index]["description"];
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              focusColor: Clr.white,
                              title: Text(
                                locationTitle,
                                style: Style.conigenColorChangableRegularText(color: Clr.white),
                              ),
                              subtitle: Text(
                                locationDescription,
                                maxLines: 2,
                                style: Style.conigenColorChangableRegularText(),
                              ),
                              onTap: () async {
                                try {
                                  double lat, lng;
                                  // List<Geocoder.Location> locations =
                                  await Geocoder.locationFromAddress(
                                          locationDescription)
                                      .then((location) {
                                    lat = location.last.latitude;
                                    lng = location.last.longitude;

                                    TempData.addLocationDataToLocationHitory(
                                        LocationHistoryDataModel(
                                            locationTitle: locationTitle,
                                            locationDescription:
                                                locationDescription,
                                            latitude: lat,
                                            longitude: lng));

                                    Navigator.pop(context);

                                    if (!isThisSourceLocation) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: RouteName
                                                      .routeDirectionScreen),
                                              builder: (context) =>
                                                  RouteDirectionMapScreen(
                                                    parentScreenName:
                                                        widget.parentScreenName,
                                                    sourceAdress,
                                                    locationTitle +
                                                        "," +
                                                        locationDescription,
                                                    LatLng(lat, lng),
                                                    sourecLatLng:
                                                        currentLocationLatLng,
                                                  )),
                                          (route) =>
                                              route.settings.name ==
                                              widget.parentScreenName);
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: RouteName
                                                      .routeDirectionScreen),
                                              builder: (context) =>
                                                  RouteDirectionMapScreen(
                                                    parentScreenName:
                                                        widget.parentScreenName,
                                                    locationTitle +
                                                        "," +
                                                        locationDescription,
                                                    destinationAdress,
                                                    destinationLatLng,
                                                    sourecLatLng:
                                                        LatLng(lat, lng),
                                                  )),
                                          (route) =>
                                              route.settings.name ==
                                              widget.parentScreenName);
                                    }

                                    return location;
                                  });
                                } on Exception catch (e) {
                                  printMsg(
                                      "Error in OnTap Search Location: $e");
                                }
                              },
                            );
                          })
                      : Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Text(
                            "No Suggestion found",
                            style: Style.conigenColorChangableRegularText(),
                          )),
                ),
              if (suggestedPlaceList.isEmpty &&
                  !isShowNearByChargingStation &&
                  !isShowFavouriteLocation)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Recent searches",
                        style: Style.conigenColorChangableRegularText(color: Clr.teal),
                      ),
                    )),
              if (suggestedPlaceList.isEmpty &&
                  !isShowNearByChargingStation &&
                  !isShowFavouriteLocation)
                Expanded(
                  child: locationHistoryList.isNotEmpty
                      ? ListView.builder(
                          itemCount: locationHistoryList.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            String locationTitle =
                                locationHistoryList[index].locationTitle ?? "";
                            String locationDescription =
                                locationHistoryList[index]
                                        .locationDescription ??
                                    "";
                            double lat =
                                locationHistoryList[index].latitude ?? 0;
                            double lng =
                                locationHistoryList[index].longitude ?? 0;

                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              focusColor: Clr.white,
                              leading: Icon(
                                Icons.history,
                                color: Clr.teal,
                              ),
                              title: Text(
                                locationTitle,
                                style: Style.conigenColorChangableRegularText(color: Clr.white),
                              ),
                              subtitle: Text(
                                locationDescription,
                                maxLines: 2,
                                style: Style.conigenColorChangableRegularText(),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                if (!isThisSourceLocation) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          settings: RouteSettings(
                                              name: RouteName
                                                  .routeDirectionScreen),
                                          builder: (context) =>
                                              RouteDirectionMapScreen(
                                                parentScreenName:
                                                    widget.parentScreenName,
                                                sourceAdress,
                                                locationTitle +
                                                    "," +
                                                    locationDescription,
                                                LatLng(lat, lng),
                                                sourecLatLng:
                                                    currentLocationLatLng,
                                              )),
                                      (route) =>
                                          route.settings.name ==
                                          widget.parentScreenName);
                                } else {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          settings: RouteSettings(
                                              name: RouteName
                                                  .routeDirectionScreen),
                                          builder: (context) =>
                                              RouteDirectionMapScreen(
                                                parentScreenName:
                                                    widget.parentScreenName,
                                                locationTitle +
                                                    "," +
                                                    locationDescription,
                                                destinationAdress,
                                                destinationLatLng,
                                                sourecLatLng: LatLng(lat, lng),
                                              )),
                                      (route) =>
                                          route.settings.name ==
                                          widget.parentScreenName);
                                }
                              },
                            );
                          })
                      : Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Text(
                            "No History Found.",
                            style: Style.conigenColorChangableRegularText(),
                          ),
                        ),
                ),
            ],
          )),
    );
  }
}
*/
