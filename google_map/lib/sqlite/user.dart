import 'package:google_maps_flutter/google_maps_flutter.dart';

class User{
  int id;
  DateTime time;
  LatLng location;
  User(id, time, location);
  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'time': time,
      'location': location,
    };
    return map;
  }
  User.fromMap(Map<String, dynamic> map){
    id = map['id'];
    time = map['time'];
    location = map['location'];
  }
}