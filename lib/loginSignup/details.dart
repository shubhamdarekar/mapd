import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapd/Providers/AuthService.dart';
import 'package:mapd/loginSignup/PhoneAuth/otp_screen.dart';
import 'package:provider/provider.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Firestore _store = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseUser user;
  File _image;

  final TextEditingController _phoneNumberController = TextEditingController();

  bool isPhoneValid = false;

  Future<Null> validatePhone(StateSetter updateState) async {
    print("in validate : ${_phoneNumberController.text.length}");
    if (_phoneNumberController.text.length == 10) {
      updateState(() {
        isPhoneValid = true;
      });
    } else {
      updateState(() {
        isPhoneValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _get();
  }

  @override
  void dispose() {
    super.dispose();
    if (user.isEmailVerified && user.phoneNumber != null) {
      _store
          .collection('users')
          .document(user.uid)
          .updateData({"signup": false});
    }
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    if (image != null) {
      await uploadImage();
    }
  }

  Future uploadImage() async {
    StorageReference ref = _storage.ref().child("profilePics/" + user.uid);
    this.setState(() {
      this.isProfilePicUploading = true;
    });
    StorageUploadTask uploadTask = ref.putFile(_image);

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();

    UserUpdateInfo profile = new UserUpdateInfo();
    profile.photoUrl = dowurl;
    await user.updateProfile(profile);
    user.reload();
    await _store
        .collection("users")
        .document(user.uid)
        .updateData({"profile_picture": dowurl});
    await this._get();
    this.setState(() {
      this.isProfilePicUploading = false;
    });
  }

  _get() async {
    await _auth.currentUser().then((value) => this.setState(() {
          this.user = value;
        }));
  }

  bool isValid = false;
  bool isUpdating = false;
  bool isProfilePicUploading = false;

  Future<Null> validate() async {
    if (_displayNameController.text.length >= 2) {
      this.setState(() {
        isValid = true;
      });
    } else {
      this.setState(() {
        isValid = false;
      });
    }
  }

  final TextEditingController _displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          children: <Widget>[
            Material(
              elevation: 4.0,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: !this.isProfilePicUploading
                  ? Ink.image(
                      image: user != null && user.photoUrl != null
                          ? NetworkImage(user.photoUrl)
                          : AssetImage('assets/images/ProfilePicAlternate.png'),
                      fit: BoxFit.cover,
                      width: 120.0,
                      height: 120.0,
                      child: InkWell(
                        onTap: () async {
                          await getImage();
                        },
                      ),
                    )
                  : Container(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator()),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Colors.black,
              child: ExpansionTile(
                children: <Widget>[
                  Container(
                      color: Colors.white,
                      height: 75,
                      margin: EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _displayNameController,
                              autofocus: true,
                              onChanged: (text) {
                                validate();
                              },
                              decoration: InputDecoration(
                                labelText: "Enter Changed Name",
                              ),
                              autovalidate: true,
                              autocorrect: false,
                              maxLengthEnforced: true,
                              validator: (value) {
                                return !isValid
                                    ? 'Please atleaset 2 characters'
                                    : null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: RaisedButton(
                              color: !isValid
                                  ? Theme.of(context).primaryColor
                                  : Colors.green,
                              child: isUpdating
                                  ? Container(
                                      child: CircularProgressIndicator())
                                  : Text("Update"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                              onPressed: !isValid
                                  ? null
                                  : () async {
                                      this.setState(() {
                                        this.isUpdating = true;
                                      });
                                      UserUpdateInfo profile =
                                          new UserUpdateInfo();
                                      profile.displayName =
                                          _displayNameController.text;
                                      await user.updateProfile(profile);
                                      await user.reload();
                                      await _store
                                          .collection('users')
                                          .document(user.uid)
                                          .updateData({
                                        "name": _displayNameController.text
                                      });
                                      await _get();
                                      this.setState(() {
                                        this.isUpdating = false;
                                      });
                                    },
                            ),
                          )
                        ],
                      )),
                ],
                // onTap: () {
                //   //open edit profile
                // },
                title: Center(
                  child: Text(
                    user != null
                        ? user.displayName != null ? user.displayName : "Enter Name"
                        : "loading",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              title: Text(
                "Link Google Account(Mandatory)",
              ),
              subtitle: Text(
                user != null && user.email != null ? user.email : "",
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey.shade400,
              ),
              onTap: () async {
                await Provider.of<AuthService>(context, listen: false)
                    .linkGoogle(context);
                await user.reload();
                await this._get();
              },
              enabled: user != null ? !user.isEmailVerified : true,
            ),
            ListTile(
              title: Text(
                "Link Phone Number (Mandatory)",
              ),
              subtitle: Text(
                user != null && user.phoneNumber != null
                    ? user.phoneNumber
                    : "",
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey.shade400,
              ),
              onTap: () async {
                await openPhoneAuth();
              },
              enabled: user != null ? user.phoneNumber == null : true,
            ),
          ],
        ),
      ),
    );
  }

  void openPhoneAuth() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Link Your Phone Number',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _phoneNumberController,
                      autofocus: true,
                      onChanged: (text) {
                        validatePhone(state);
                      },
                      decoration: InputDecoration(
                        labelText: "10 digit mobile number",
                        prefix: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "+91",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      autovalidate: true,
                      autocorrect: false,
                      maxLengthEnforced: true,
                      validator: (value) {
                        return !isPhoneValid
                            ? 'Please provide a valid 10 digit phone number'
                            : null;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: RaisedButton(
                          color: !isPhoneValid
                              ? Theme.of(context).primaryColor
                              : Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0)),
                          child: Text(
                            !isPhoneValid ? "ENTER PHONE NUMBER" : "CONTINUE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (isPhoneValid) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OTPScreen(
                                        mobileNumber:
                                            _phoneNumberController.text,
                                        isLinking: true),
                                  ));
                            } else {
                              validatePhone(state);
                            }
                          },
                          padding: EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        }).whenComplete(() {
      user.reload();
      this._get();
    });
  }
}
