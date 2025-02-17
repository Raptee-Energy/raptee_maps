import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

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
import '../../Methods/hideKeyboard.dart';
import '../Methods/hideKeyboard.dart';
import 'component/setFavouriteLocationHomeWork.dart';
import 'locationMarkerScreen.dart';

class FullScreenLocationSearchScreen extends StatefulWidget {
  final String? sourceLocation;
  final LatLng? sourceLatLng;
  const FullScreenLocationSearchScreen({
    Key? key,
    this.sourceLocation,
    this.sourceLatLng,
  }) : super(key: key);

  @override
  State<FullScreenLocationSearchScreen> createState() =>
      _FullScreenLocationSearchScreenState();
}

class _FullScreenLocationSearchScreenState
    extends State<FullScreenLocationSearchScreen> {
  String sourceAddress = "";
  LatLng? sourceLatLng;

  bool isShowNearByChargingStation = false;
  bool isShowFavouriteLocation = false;
  bool isThisSourceLocation = false;

  TextEditingController controller = TextEditingController();

  List<NearbyChargingStationDataModel> nearByChargingData = [];
  List<LocationHistoryDataModel> locationHistoryList = [];
  List<dynamic> suggestedPlaceList = [];
  int _currentCallId = 0;

  @override
  void initState() {
    locationHistoryList = TempData.locationHistoryList;

    controller.text = widget.sourceLocation ?? "";

    sourceLatLng = widget.sourceLatLng ?? LatLng(0, 0);
    sourceAddress = widget.sourceLocation ?? "";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await DirectionsRepository()
          .makeSuggestion(controller.text)
          .then((value) {
        suggestedPlaceList = value;
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
                          shadowColor: Clr.constBlack.withOpacity(0.1),
                          padding: const EdgeInsets.all(0),
                          backgroundColor: Clr.mainGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Clr.teal,
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
                          setState(() {
                            isShowNearByChargingStation = false;
                            isShowFavouriteLocation = false;
                          });
                        },
                        onChanged: (text) async {
                          final int callId =
                              ++_currentCallId; // Increment call ID
                          try {
                            if (text.isNotEmpty) {
                              await DirectionsRepository()
                                  .makeSuggestion(controller.text)
                                  .then((value) {
                                if (callId == _currentCallId) {
                                  if (value[0]["error_message"] != null) {
                                    printMsg(value[0]["error_message"]);
                                    // showToastError(context,
                                    //     title: value[0]["error_message"]);
                                    return;
                                  }
                                  suggestedPlaceList = value;

                                  setState(() {
                                    isShowFavouriteLocation = false;
                                    isShowNearByChargingStation = false;
                                  });
                                }
                              });
                            } else {
                              suggestedPlaceList.clear();
                              setState(() {});
                            }
                          } on Exception catch (e) {
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
                              double lat, lng;
                              final location = LocationTempData.homeLocation!;

                              lat = location.latitude ?? 0;
                              lng = location.longitude ?? 0;

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: RouteName.locationMarkerScreen),
                                      builder: (context) =>
                                          LocationMarkerScreen(
                                              locationLatLng: LatLng(lat, lng),
                                              locationAddress:
                                                  location.locationDescription,
                                              locationTitle:
                                                  location.locationTitle)),
                                  (route) =>
                                      route.settings.name ==
                                      RouteName.homeBottomNavigationScreen);
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
                                        style: Style
                                            .conigenColorChangableRegularText(
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
                            // try {
                            if (LocationTempData.officeLocation != null) {
                              double lat, lng;
                              final location = LocationTempData.officeLocation!;

                              lat = location.latitude ?? 0;
                              lng = location.longitude ?? 0;

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: RouteName.locationMarkerScreen),
                                      builder: (context) =>
                                          LocationMarkerScreen(
                                              locationLatLng: LatLng(lat, lng),
                                              locationAddress:
                                                  location.locationDescription,
                                              locationTitle:
                                                  location.locationTitle)),
                                  (route) =>
                                      route.settings.name ==
                                      RouteName.homeBottomNavigationScreen);
                            } else {
                              printMsg("Work location is null");
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
                                        style: Style
                                            .conigenColorChangableRegularText(
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
                                      LocationTempData.currentLocation)
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
                                  "Charging Station",
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
                        style: Style.conigenColorChangableRegularText(
                            color: Clr.teal),
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
                                        Style.conigenColorChangableRegularText(
                                            color: Clr.white),
                                  ),
                                  subtitle: Text(
                                    locationDescription,
                                    maxLines: 3,
                                    style: Style
                                        .conigenColorChangableRegularText(),
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

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            settings: const RouteSettings(
                                                name: RouteName
                                                    .locationMarkerScreen),
                                            builder: (context) =>
                                                LocationMarkerScreen(
                                                    locationLatLng:
                                                        LatLng(lat, lng),
                                                    locationAddress:
                                                        locationDescription,
                                                    locationTitle:
                                                        locationTitle)),
                                        (route) =>
                                            route.settings.name ==
                                            RouteName
                                                .homeBottomNavigationScreen);
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
                        style: Style.conigenColorChangableRegularText(
                            color: Clr.tealLite),
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

                            LatLng location =
                                nearByChargingData[index].location ??
                                    LatLng(0, 0);
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
                                        style: Style
                                            .conigenColorChangableRegularText(
                                                color: nearByChargingData[index]
                                                        .isAvailable!
                                                    ? Clr.green1
                                                    : Clr.buttonRed1),
                                      )
                                    : SizedBox(),
                                title: Text(
                                  locationTitle,
                                  maxLines: 3,
                                  style: Style.conigenColorChangableRegularText(
                                      color: Clr.white),
                                ),
                                subtitle: Text(
                                  locationDescription,
                                  maxLines: 3,
                                  style:
                                      Style.conigenColorChangableRegularText(),
                                ),
                                onTap: () async {
                                  double lat = location.latitude;
                                  double lng = location.longitude;

                                  TempData.addLocationDataToLocationHitory(
                                      LocationHistoryDataModel(
                                          locationTitle: locationTitle,
                                          locationDescription:
                                              locationDescription,
                                          latitude: lat,
                                          longitude: lng));

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          settings: RouteSettings(
                                              name: RouteName
                                                  .locationMarkerScreen),
                                          builder: (context) =>
                                              LocationMarkerScreen(
                                                  locationLatLng:
                                                      LatLng(lat, lng),
                                                  locationAddress:
                                                      locationDescription,
                                                  locationTitle:
                                                      locationTitle)),
                                      (route) =>
                                          route.settings.name ==
                                          RouteName.homeBottomNavigationScreen);
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
                        style: Style.conigenColorChangableRegularText(
                            color: Clr.teal),
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
                                style: Style.conigenColorChangableRegularText(
                                    color: Clr.white),
                              ),
                              subtitle: Text(
                                locationDescription,
                                maxLines: 2,
                                style: Style.conigenColorChangableRegularText(),
                              ),
                              onTap: () async {
                                try {
                                  // Log the location description
                                  printMsg(
                                      "Location description: $locationDescription");

                                  // Ensure we have a non-null, non-empty locationDescription
                                  if (locationDescription.isNotEmpty) {
                                    // Call locationFromAddress safely
                                    List<Location> locations =
                                        await locationFromAddress(
                                            locationDescription);

                                    // Log the locations result
                                    printMsg("Locations result: $locations");

                                    // Check if locations list is not empty
                                    if (locations.isNotEmpty) {
                                      Location location = locations.first;
                                      double lat = location.latitude;
                                      double lng = location.longitude;

                                      // Log the obtained latitude and longitude
                                      print("Latitude: $lat, Longitude: $lng");

                                      TempData.addLocationDataToLocationHitory(
                                        LocationHistoryDataModel(
                                          locationTitle: locationTitle,
                                          locationDescription:
                                              locationDescription,
                                          latitude: lat,
                                          longitude: lng,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: RouteName
                                                  .locationMarkerScreen),
                                          builder: (context) =>
                                              LocationMarkerScreen(
                                            locationLatLng: LatLng(lat, lng),
                                            locationAddress:
                                                locationDescription,
                                            locationTitle: locationTitle,
                                          ),
                                        ),
                                        (route) =>
                                            route.settings.name ==
                                            RouteName
                                                .homeBottomNavigationScreen,
                                      );
                                    } else {
                                      printMsg(
                                          "No locations found for the address.");
                                    }
                                  } else {
                                    printMsg(
                                        "Location description is null or empty.");
                                  }
                                } catch (e) {
                                  printMsg(
                                      "Error in OnTap Search Location: $e");
                                  // Optionally show a user-friendly error message
                                  // CommanToast().showErrorToastMsg(context, e.toString());
                                }
                              },
                            );
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Text(
                            "No Suggestion found",
                            style: Style.conigenColorChangableRegularText(),
                          ),
                        ),
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
                        style: Style.conigenColorChangableRegularText(
                            color: Clr.teal),
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
                              leading: const Icon(
                                Icons.history,
                                color: Clr.teal,
                              ),
                              title: Text(
                                locationTitle,
                                style: Style.conigenColorChangableRegularText(
                                    color: Clr.white),
                              ),
                              subtitle: Text(
                                locationDescription,
                                maxLines: 2,
                                style: Style.conigenColorChangableRegularText(),
                              ),
                              onTap: () async {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                            name:
                                                RouteName.locationMarkerScreen),
                                        builder: (context) =>
                                            LocationMarkerScreen(
                                                locationLatLng:
                                                    LatLng(lat, lng),
                                                locationAddress:
                                                    locationDescription,
                                                locationTitle: locationTitle)),
                                    (route) =>
                                        route.settings.name ==
                                        RouteName.homeBottomNavigationScreen);
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
