import 'package:flutter/material.dart';



class HomePageApp extends StatefulWidget{
  HomePageApp({Key key}) : super(key : key);
  @override
  _HomePageAppState createState() => _HomePageAppState();
}

class _HomePageAppState extends State<HomePageApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 1000,
      child: Center(
        child: Image(
          image: AssetImage('assets/images/FloorMapOutline.png'),
        ),
      ),
    );
  }
}
