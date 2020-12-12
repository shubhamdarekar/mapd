
import 'package:flutter/material.dart';
import 'package:mapd/Providers/AuthService.dart';
import 'package:mapd/loginSignup/PhoneAuth/phone_auth.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => new _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.3), BlendMode.dstATop),
          image: AssetImage('assets/images/mountains.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 125.0),
            child: Center(
              child: ImageIcon(
                AssetImage("assets/images/1.png"),
                color: Colors.blue,
                size: 80.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Zentors",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                )
              ],
            ),
          ),
          new Container(
              width: MediaQuery.of(context).size.width,
              margin:
                  const EdgeInsets.only(left: 30.0, right: 30.0, top: 150.0),
              alignment: Alignment.center,
              child: PhoneLogin()),
          new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
            alignment: Alignment.center,
            child: new Container(
              margin: EdgeInsets.only(left: 8.0),
              alignment: Alignment.center,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Color(0Xffffffff),
                      onPressed: () => {},
                      child: new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: new FlatButton(
                                onPressed: () async {
                                  await Provider.of<AuthService>(context,
                                          listen: false)
                                      .loginUser(
                                          pin: "",
                                          verificationId: "",
                                          context: context);
                                },
                                padding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 20.0,
                                ),
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(const IconData(0x47)),
                                    Text(
                                      "GOOGLE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
