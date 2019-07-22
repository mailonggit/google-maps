import 'package:google_maps_flutter/google_maps_flutter.dart';

//time and location
class UserLocation
{
  UserLocation(this.time, this.position);  
  DateTime time;
  LatLng position;
}