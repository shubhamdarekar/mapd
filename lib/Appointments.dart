
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapd/Providers/AuthService.dart';
import 'package:mapd/loginSignup/auth.dart';
import 'package:provider/provider.dart';

class Appointments extends StatefulWidget {
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar:new BottomNavigationBar(items: [ BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      Icons.audiotrack,
      color: Colors.green,
      size: 30.0,
    )),BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      Icons.golf_course,
      color: Colors.red,
      size: 30.0,
    ))]),
      drawer: new Drawer(),
      body: Center(
              child: Column(
          children: <Widget>[
            SizedBox(height: 100,),
            RaisedButton(
              child: Text("Sign out"),
              onPressed: () async  {
                await Provider.of<AuthService>(context,listen: false).logout();
                // _firebaseAuth.currentUser().then((value) => print(value));
              },
            ),
            Center(
              child: Text(_auth.currentUser().toString()),
            ),
            RaisedButton(
              child: Text("Test"),
              onPressed: () async  {
                print(Navigator.push(context, CupertinoPageRoute(builder: (context) => AuthScreen(),)));
              },
            ),
          ],
        ),
      ),
    );
  }
}