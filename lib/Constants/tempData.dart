import '../Models/locationHistoryDataModel.dart';

class TempData {
  static List<LocationHistoryDataModel> pinnedLocationList = [];
  static List<LocationHistoryDataModel> favouriteLocationList = [];
  LocationHistoryDataModel? homeLocation;
  LocationHistoryDataModel? officeLocation;
  static List<LocationHistoryDataModel> locationHistoryList = [];

  static List<LocationHistoryDataModel> addLocationDataToLocationHitory(
      LocationHistoryDataModel data) {
    locationHistoryList.add(data);

    locationHistoryList = removeDuplicatesByLocationTitle(locationHistoryList);

    return locationHistoryList;
  }

  static List<LocationHistoryDataModel> addLocationDataToFavourite(
      LocationHistoryDataModel data) {
    favouriteLocationList.add(data);

    favouriteLocationList =
        removeDuplicatesByLocationTitle(favouriteLocationList);

    return favouriteLocationList;
  }

//Method to remove the duplicate element from the list based on the title
  static List<LocationHistoryDataModel> removeDuplicatesByLocationTitle(
      List<LocationHistoryDataModel> locationHistoryList) {
    Set<String> uniqueLocationTitles = {};

    // Create a list to store unique LocationHistoryDataModel objects
    List<LocationHistoryDataModel> uniqueLocationHistory = [];

    // Iterate through the locationHistoryList
    for (LocationHistoryDataModel location in locationHistoryList) {
      // Check if the locationTitle is already present in the set
      if (!uniqueLocationTitles.contains(location.locationTitle)) {
        // If not present, add it to the set and the unique list
        uniqueLocationTitles.add(location.locationTitle!);
        uniqueLocationHistory.add(location);
      }
    }

    // Return the unique list
    return uniqueLocationHistory;
  }

  // //Avatar Data
  // static String ProfileAvatar = Dir.rapteeLogoBlack;
  //
  // //Profile Background Image
  // //Avatar Data
  // static String ProfileCoverImage = Dir.profileBack;
}
