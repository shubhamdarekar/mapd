
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapd/Appointments.dart';
import 'package:mapd/loginSignup/details.dart';

class HomePage extends StatelessWidget {
  final FirebaseUser user;
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;

  Future<bool> _getSignup() async {
    bool signup;
    await _store.collection('users').document(user.uid).get().then((value) {
      signup = value.data['signup'];
    });
    return signup;
  }

  HomePage({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _getSignup().then((value) {
      if (value) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter state) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Details(),
                  );
                }));
      }
    });
    return Appointments();
  }
}
