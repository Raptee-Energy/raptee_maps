import 'package:latlong2/latlong.dart';

import '../Models/locationHistoryDataModel.dart';

class LocationTempData {
  static LatLng currentLocation = (LatLng(0, 0));

  static LocationHistoryDataModel? homeLocation;
  static LocationHistoryDataModel? officeLocation;
}
