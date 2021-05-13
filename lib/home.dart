import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapd/TakePicture.dart';
import 'package:mapd/mainHome.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Providers/AuthService.dart';
import 'loginSignup/auth.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  HomePage({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
    availableCameras().then((value) => fcamera = value.first);

// Get a specific camera from the list of available cameras.
//     fcamera = cameras.first;
  }

  final Firestore _store = Firestore.instance;

  FirebaseAuth _auth = FirebaseAuth.instance;
  CameraDescription fcamera;

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);

  GoogleMapController _controller;

  Location _location = Location();

  Future<bool> _getSignup() async {
    bool signup;
    await _store
        .collection('users')
        .document(widget.user.uid)
        .get()
        .then((value) {
      signup = value.data['signup'];
    });
    return signup;
  }

  @override
  Widget build(BuildContext context) {
    // _getSignup().then((value) {
    //   if (value) {
    //     showModalBottomSheet(
    //         context: context,
    //         isScrollControlled: true,
    //         builder: (context) => StatefulBuilder(
    //                 builder: (BuildContext context, StateSetter state) {
    //               return Container(
    //                 padding: EdgeInsets.all(16),
    //                 height: MediaQuery.of(context).size.height * 0.9,
    //                 child: Details(),
    //               );
    //             }));
    //   }
    // });
    // return Appointments();

    return Scaffold(
      //   bottomNavigationBar:new BottomNavigationBar(items: [ BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      //   Icons.audiotrack,
      //   color: Colors.green,
      //   size: 30.0,
      //   )),
      //     BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      //   Icons.golf_course,
      //   color: Colors.red,
      //   size: 30.0,
      // ))]),
      drawer: new Drawer(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Text(_auth.currentUser().toString()),
              RaisedButton(
                child: Text("Sign out"),
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false)
                      .logout();
                  // _firebaseAuth.currentUser().then((value) => print(value));
                },
              ),
            ],
          ),
        ),
      ),
      body: HomePageApp(),
      // Container(
      //   height: MediaQuery.of(context).size.height,
      //   width: MediaQuery.of(context).size.width,
      //   child: Stack(
      //     children: [
      //       GoogleMap(
      //         initialCameraPosition:
      //             CameraPosition(target: _initialcameraposition),
      //         mapType: MapType.hybrid,
      //         onMapCreated: _onMapCreated,
      //         myLocationEnabled: true,
      //         buildingsEnabled: true,
      //         zoomControlsEnabled: false,
      //         indoorViewEnabled: true,
      //         // compassEnabled: true,
      //         myLocationButtonEnabled: true,
      //         // trafficEnabled: true,
      //         onLongPress: _longPress,
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TakePictureScreen(camera: fcamera)))
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _longPress(LatLng l) {}

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
        ),
      );
    });
  }
}
