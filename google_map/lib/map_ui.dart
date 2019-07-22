import "package:flutter/material.dart";
import 'package:google_map/sqlite/db_helper.dart';
import 'package:google_map/sqlite/user.dart';
import 'package:google_map/user_location.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import "dart:math";
import 'package:google_map/sqlite/db_helper.dart';
class MapUiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapUiPageState();
  }
}

class MapUiPageState extends State<MapUiPage> {
  //__________________________DATABASE
  Future<List<User>> users;
  TextEditingController controller = TextEditingController();
  int currentUserID;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
  //_______________________VARIABLE_______________________
  GoogleMapController mapController;
  List<UserLocation> allUser = [];
  Map<int, Marker> allMarker = Map();
  Map<PolylineId, Polyline> listPolyline = Map();
  PolylineId selectedPolyline;
  int selectedMarker;
  int polylineIdCounter = 1;
  LatLng presentTap;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
  }
  refreshList(){
    setState(() {
      users = dbHelper.getUsers();
    });
    
  }
  //_______________________METHOD___________________________
  onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  createUser(LatLng pos) {
    var now = new DateTime.now(); //time from now
    allUser.add(UserLocation(now, pos)); //add a user to the list
    createMarker(10); //create marker after add a user
    if (allUser.length >= 2) {
      //only create when we have 2 markers(users)
      createPolyline();
    }
  }

  createMarker(int limit) {
    int index = allUser.length;
    LatLng currentPosition = allUser[index - 1].position;
    debugPrint("Length: $index");
    debugPrint("Position: $currentPosition");
    if (index == limit) {
      return;
    }
    final markerIdVal = "Place $index";

    final MarkerId markerId = MarkerId(markerIdVal); //create Id for marker

    final Marker marker = Marker(
        markerId: markerId,
        position: currentPosition, //position from user
        infoWindow: InfoWindow(title: markerIdVal, snippet: "*"),
        onTap: () {
          selectedMarker = index;
          debugPrint("Selected Marker: $selectedMarker");
        });
    setState(() {
      allMarker[index] = marker; //after create marker add it to the list
    });
  }

  removeMarker() {
    setState(() {
      debugPrint("deleted");
      allMarker.remove(selectedMarker); //delete marker
      //allUser.removeAt(selectedMarker - 1);//also delete that user
      LatLng pos = allUser[selectedMarker].position;
      debugPrint("User[$selectedMarker]: $pos");
    });
  }

  colorByVelocity(double velocity) {
    if (velocity > 10 && velocity < 50) {
      return Colors.redAccent;
    } else if (velocity > 50 && velocity < 100) {
      return Colors.yellowAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  createPolyline() {
    int index = allUser.length;
    if (index > 10 || listPolyline.length == 9) {
      return; //stop creating polyline
    } else {
      UserLocation us1 = allUser[index - 1];
      UserLocation us2 = allUser[index - 2];
      final int polylineCount = index - 1;

      final String polylineIdVal = "Line $polylineCount";

      final PolylineId polylineId = PolylineId(polylineIdVal); //key

      final List<LatLng> points = <LatLng>[]; //create point

      points.add(us1.position); //add 1st point

      points.add(us2.position); //add 2nd point

      double velocity = calculateVelocity(us1, us2);

      final Polyline polyline = Polyline(
          //create a polyline
          polylineId: polylineId,
          consumeTapEvents: true,
          width: 5,
          points: points,
          color: colorByVelocity(velocity),
          onTap: () {
            setState(() {
              // selectedPolyline = polylineId;
              debugPrint("Velocity: $velocity");
            });
          });

      listPolyline[polylineId] =
          polyline; //add polyline to the list of polyline
      //points.clear();
    }
  }

  removePolyline() {
    // setState(() {
    //  debugPrint("deleted polyline");
    //  if(listPolyline.containsKey(selectedPolyline))
    //     listPolyline.remove(selectedPolyline);
    // });
    // var selectedPosition = allMarker[selectedMarker].position;
    // listPolyline.values.forEach((element) {
    //     element.points
    // } );
  }

  convertDeg2Rad(double value) {
    var pi = 3.141592653589793;
    return value * pi / 180;
  }

  calculateDistance(LatLng p1, LatLng p2) {
    var R = 6371; // Radius of the earth in km
    var dLat = convertDeg2Rad(p2.latitude - p1.latitude); // deg2rad below
    var dLon = convertDeg2Rad(p2.longitude - p1.longitude);
    var a = pow(sin(dLat / 2), 2.0) +
        cos(convertDeg2Rad(p1.latitude)) *
            cos(convertDeg2Rad(p2.latitude) * pow(sin(dLon / 2), 2.0));
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  calculateTime(UserLocation us1, UserLocation us2) {
    return (us2.time.millisecond - us1.time.millisecond);
  }

  calculateVelocity(UserLocation us1, UserLocation us2) {
    double distance = calculateDistance(us1.position, us2.position);
    int time = calculateTime(us1, us2);
    return (distance / time).abs();
  }

  fullMap() {
    return GoogleMap(
      onMapCreated: onMapCreated, //create map
      initialCameraPosition: CameraPosition(
        //set camera position
        target: LatLng(10.863731, 106.779495), //random Latlng
        zoom: 11.0,
      ),
      onTap: (LatLng pos) {
        setState(() {
          createUser(pos); //implement when user tap to the map
        });
      },
      myLocationEnabled: true,
      mapType: MapType.hybrid,
      compassEnabled: true,
      markers: Set<Marker>.of(allMarker.values),
      polylines: Set<Polyline>.of(listPolyline.values),
    );
  }

  displayMap() {
    return Container(
      child: fullMap(),
      width: 400.0,
      height: 500.0,
    );
  }

  findLocation() {}

  removeButton() {
    return RaisedButton(
      padding: EdgeInsets.all(10.0),
      color: Colors.green, //background color
      textColor: Colors.black, //color of the text
      splashColor: Colors.red, //color when press
      child: Text(
        "Remove",
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 20.0),
      ),
      onPressed: removeMarker, //action when press the button
    );
  }

  findLocationButton() {
    return RaisedButton(
      padding: EdgeInsets.all(10.0),
      color: Colors.green, //background color
      textColor: Colors.black, //color of the text
      splashColor: Colors.red, //color when press
      child: Text(
        "Find Place",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),
      ),
      onPressed: findLocation, //action when press the button
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        displayMap(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            removeButton(),
            findLocationButton(),
          ],
        ),
        //Container(),
      ],
    );
  }
}
