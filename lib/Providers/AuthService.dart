import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  Future logout() async {
    await googleSignIn.signOut();
    var result = await FirebaseAuth.instance.signOut();
    await getUser();
    notifyListeners();
    return result;
  }

  Future<FirebaseUser> loginUser(
      {String verificationId, String pin, BuildContext context}) async {
    AuthResult authResult;
    if (verificationId != '') {
      AuthCredential _authCredential = PhoneAuthProvider.getCredential(
          verificationId: verificationId, smsCode: pin);

      await _auth
          .signInWithCredential(_authCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          authResult = value;
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);

          if (authResult.additionalUserInfo.isNewUser) {
            _store.collection('users').document(authResult.user.uid).setData({
              "phone": authResult.user.phoneNumber,
              "gmail": authResult.user.email,
              "profile_picture": authResult.user.photoUrl,
              "signup": true,
              "role": 0,
              "created_at": new DateTime.now().millisecondsSinceEpoch
            });

            _store
                .collection('users')
                .document(authResult.user.uid)
                .collection('recentMessages')
                .document('sort')
                .setData({"myArr": []});
          } else {
            _store.collection('users').document(authResult.user.uid).updateData(
                {"last_logged_in": new DateTime.now().millisecondsSinceEpoch});
          }
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((e) {
        showToast(e.message, Colors.red);
      });
    } else {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      authResult = await _auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      if (authResult.additionalUserInfo.isNewUser) {
        _store.collection('users').document(authResult.user.uid).setData({
          "gmail": authResult.user.email,
          "profile_picture": authResult.additionalUserInfo.profile['picture'],
          "locale": authResult.additionalUserInfo.profile['locale'],
          "first_name": authResult.additionalUserInfo.profile['given_name'],
          "family_name": authResult.additionalUserInfo.profile['family_name'],
          "signup": true,
          "role": 0,
          "created_at": new DateTime.now().millisecondsSinceEpoch
        });

        _store
            .collection('users')
            .document(authResult.user.uid)
            .collection('recentMessages')
            .document('sort')
            .setData({"myArr": []});
      } else {
        _store.collection('users').document(authResult.user.uid).updateData(
            {"last_logged_in": new DateTime.now().millisecondsSinceEpoch});
      }
    }
    notifyListeners();

    print(authResult);
    return _auth.currentUser();
  }

  Future<bool> getFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTime') ?? true;
  }

  Future<bool> setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
    await getFirstTime();
    notifyListeners();
    return false;
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<FirebaseUser> linkGoogle(BuildContext context) async {
    AuthResult authResult;
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final FirebaseUser user = await _auth.currentUser();

    authResult = await user.linkWithCredential(credential);

    print(authResult.additionalUserInfo);

    UserUpdateInfo profile = new UserUpdateInfo();
    profile.photoUrl = authResult.additionalUserInfo.profile["picture"];
    profile.displayName = authResult.additionalUserInfo.profile["name"];
    await user.updateProfile(profile);
    await user.reload();

    _store.collection('users').document(authResult.user.uid).updateData({
      "gmail": authResult.additionalUserInfo.profile["email"],
      "name": authResult.additionalUserInfo.profile["name"],
      "profile_picture": authResult.additionalUserInfo.profile["picture"],
    });

    await user.reload();
    return user;
  }

  Future<FirebaseUser> linkPhone(
      {String verificationId, String pin, BuildContext context}) async {
    AuthResult authResult;

    final FirebaseUser user = await _auth.currentUser();

    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: pin);

    authResult = await user.linkWithCredential(_authCredential);
    print(authResult.toString());

    _store.collection('users').document(authResult.user.uid).updateData({
      "phone":authResult.user.phoneNumber
    });
    await user.reload();
    Navigator.pop(context);
    Navigator.maybePop(context);
    return user;
  }
}
