

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapd/IntroSlider/introSlider.dart';
import 'package:mapd/Providers/AuthService.dart';
import 'package:mapd/home.dart';
import 'package:mapd/loginSignup/auth.dart';
import 'package:provider/provider.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            return snapshot.hasData
                ? HomePage(user: snapshot.data)
                : FutureBuilder(
                future: Provider.of<AuthService>(context).getFirstTime(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // log error to console
                    if (snapshot.error != null) {
                      print("error");
                      return Text(snapshot.error.toString());
                    }
                    return snapshot.data ? IntroScreen() : AuthScreen();
                  } else {
                    // show loading indicator
                    return LoadingCircle();
                  }
                });
          } else {
            // show loading indicator
            return LoadingCircle();
          }
        });
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 500,
        width: 500,
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}