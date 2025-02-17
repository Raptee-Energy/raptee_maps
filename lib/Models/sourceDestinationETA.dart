// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:latlong2/latlong.dart';

class SourceDestinationEtdDataModel {
  String? time;
  String? distance;
  String? sourceAddress;
  String? destinationAddress;
  LatLng? sourceLatlng;
  LatLng? destinationLatlng;
  SourceDestinationEtdDataModel({
    this.time,
    this.distance,
    this.sourceAddress,
    this.destinationAddress,
    this.sourceLatlng,
    this.destinationLatlng,
  });
}
