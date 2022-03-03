

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/pages/second.dart';

class NoConnection extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _NoConnectionState();
  }

}

class _NoConnectionState extends State<NoConnection>{

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        theme: ThemeData(
//          primaryColor: Color.fromRGBO(200, 100, 0, 1),
          primaryColor: Color.fromRGBO(200, 100, 0, 1),
          primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
          primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
          primarySwatch: Colors.orange,
          textTheme: Theme.of(context).textTheme.apply(
            fontSizeFactor: 0,
            fontSizeDelta:
            Localizations.localeOf(context).toString() == 'ar_SAR'
                ? 21
                : 16,
            bodyColor: Colors.orange,
            fontFamily: Localizations.localeOf(context).toString() == 'ar_SAR' ? "Bahij_Muna" : "",//isLanguageSpecified ? "Bahij_Muna":"",
          ),
          hintColor: Colors.orange,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Container(
              child: ElevatedButton(
                onPressed: () async {
                  bool isOnline = await hasNetwork();
                  if(isOnline) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => new Second(null, null, false))
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastNoInternetConnection'),
                        //                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white70,
                        textColor: Colors.black,
                        fontSize: 16.0);
                  }
                },
                child: Text(
                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tryAgain'),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Future<bool> _onBackPressed() async{
    return false;
  }

}