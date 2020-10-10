import 'dart:async';
import 'dart:convert';
import 'package:first_app/config.dart';
import 'package:first_app/models.dart';
import 'package:first_app/punch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print("INSIDE SCANNER" + barcodeScanRes);
      fetchToken(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<Login> fetchToken(String _scanBarcode) async {
    String uniqueId = _scanBarcode;
    Map data = {"unique_id": uniqueId};
    String body = json.encode(data);
    print("BODY " + body);
    print("HEELLO from fetch token " + _scanBarcode + " " + uniqueId);
    ConfigClass config = ConfigClass();
    print("URL " + config.getBaseUrl() + "/api/v1/account/login");
    final response = await http.post(
      config.getBaseUrl() + "/api/v1/account/login",
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print('TOKEN get??' + response.body);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      //return Login.fromJson(jsonDecode(response.body));
      var jsonResponse = json.decode(response.body);
      sharedPreferences.setString("token", jsonResponse['token']);
      sharedPreferences.setString("unique_id", jsonResponse['unique_id']);
      print('TOKEN get??' +
          jsonResponse['token'] +
          " " +
          jsonResponse['unique_id']);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Punch()),
          (Route<dynamic> route) => false);
    } else {
      print('TOKEN no');
      throw Exception('Failed to login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Login')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            autofocus: true,
                            color: Color.alphaBlend(
                                Colors.white10, Colors.black12),
                            onPressed: () => scanQR(),
                            child:
                                Text("Login", style: TextStyle(fontSize: 20)),
                            padding: new EdgeInsets.fromLTRB(30, 20, 30, 20),
                            elevation: 10),
                        //Text('Scan result : $_scanBarcode\n',
                        // style: TextStyle(fontSize: 20))
                      ]));
            })));
  }
}
