import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import './login.dart';
import './config.dart';

class Punch extends StatefulWidget {
  final String currentUser;
  Punch({Key key, this.currentUser}) : super(key: key);
  @override
  _PunchState createState() => _PunchState(user: currentUser);
}

class _PunchState extends State<Punch> {
  String user = "";
  _PunchState({this.user});
  int _punchCount = 0;
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  int Punch() {
    setState(() {
      print(_punchCount);
      _punchCount += 1;
      print("PUNCH!");
      print(_punchCount);
      punchRequest();
    });

    return _punchCount;
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> punchRequest() async {
    ConfigClass config = ConfigClass();
    print("URL " + config.getBaseUrl() + "/api/v1/controller/punch");
    print("IN PUNCH! " +
        sharedPreferences.getString("token") +
        " " +
        sharedPreferences.getString("unique_id"));
    Map data = {"unique_id": sharedPreferences.getString("unique_id")};
    String body = json.encode(data);
    print(body);
    try {
      final response = await http.post(
        config.getBaseUrl() + "/api/v1/controller/punch",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token " + sharedPreferences.getString("token")
        },
        body: body,
      );
      print("STATUS CODE");
      print(response.statusCode);
      if (response.statusCode == 201) {
        print("PUNCH DONE?");
      } else {
        throw Exception('Failed to punch');
      }
    } catch (a, e) {
      print("Exception $a");
      print("Stacktrace $e");
    }
  }

  Future<void> logout() async {
    ConfigClass config = ConfigClass();
    print("URL " + config.getBaseUrl() + "/api/v1/account/login");
    print("IN LOGOUT! " +
        sharedPreferences.getString("token") +
        " " +
        sharedPreferences.getString("unique_id"));
    Map data = {"unique_id": sharedPreferences.getString("unique_id")};
    String body = json.encode(data);
    try {
      final response = await http.post(
        config.getBaseUrl() + "/api/v1/account/logout",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token " + sharedPreferences.getString("token")
        },
        body: body,
      );
      print("STATUS CODE");
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("LOGOUT DONE?");
      } else {
        throw Exception('Failed to logout');
      }
    } catch (a, e) {
      print("Exception $a");
      print("Stacktrace $e");
    }
    // print("STATUS CODE");
    // print(response.statusCode);
    // if (response.statusCode == 200) {
    //   print("LOGOUT DONE?");
    // } else {
    //   throw Exception('Failed to logout');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('User : $user'),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    logout();
                    sharedPreferences.clear();
                    sharedPreferences.commit();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen()),
                        (Route<dynamic> route) => false);
                  },
                  color: Color.alphaBlend(Colors.red, Colors.white),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                )
              ],
            ),
            backgroundColor: Colors.deepOrangeAccent,
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Counter : $_punchCount\n',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        RawMaterialButton(
                          onPressed: () => Punch(),
                          constraints: BoxConstraints(),
                          elevation: 4.0,
                          fillColor: Colors.white,
                          child: Icon(
                            Icons.add,
                            size: 50.0,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      ]));
            })));
  }
}
