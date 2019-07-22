import 'package:flutter/material.dart';
import "map_ui.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text("Google Maps"),
            centerTitle: true,),
          backgroundColor: Colors.white,
          body: MapUiPage(),
          
        ));
  }
}
