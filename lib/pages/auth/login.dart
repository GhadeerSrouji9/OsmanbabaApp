import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/auth/sign_up.dart';
import 'package:url_launcher/url_launcher.dart';
import '../second.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/app_localization.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  static final String assetsURL = 'assets/imgs/';
  int _state = 0;
  bool isLoading = false;

  Future<List<List<String>>> fetchCountries() async{
    List<String> countryNamesList = [];
    List<String> countryIdsList = [];
    final url = Uri.parse(webURL + 'api/ListCountry');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{}';
    final response = await post(url, headers: headers, body: json).timeout(const Duration(seconds: 10), onTimeout:(){
      setState(() {
        _state = 0;
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0
      );
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"];
      setState(() {
        for(int i = 0; i < decoded.length; i++){
          countryNamesList.add(decoded[i]["name"]);
          countryIdsList.add(decoded[i]["id"]);
        }
      });
    } else {
      throw Exception('Failed to load');
    }

    return [
      countryNamesList,
      countryIdsList
    ];
  }

  @override
  void initState(){
    super.initState();
  }

  bool areMatched = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.orange,
        ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),

      supportedLocales: [
        Locale('ar', 'SAR'),
        Locale('en', 'US'),
        Locale('tr', 'TR'),
      ],

     localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      locale: isLanguageSpecified ? globalLocale : null,

      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(225, 224, 204 , 1),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.orange,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 1.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
                width: 0.0,
              )
          ),
          child: Container(
            child: Stack(
              children: [
                // CARD
                Positioned(
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.only(top: 170, right: 50, left: 50),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), ),
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black45),
                                  hintText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('email'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration( borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                          child: Center(
                            child: TextField(
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: passwordController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black45),
                                  hintText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('password'),
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                            ),
                          ),
                        ),
                        // LOGIN BUTTON
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 60.0),
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.orange,
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              onPressed: () async{
                                 if(!isLoading) {
                                 if(_state == 0) {
                                   animateLoginButton();}
                                 } else {
                               Fluttertoast.showToast(
                                   msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastWaitWhileLoading'),
                                   toastLength: Toast.LENGTH_SHORT,
                                   gravity: ToastGravity.CENTER,
                                   timeInSecForIosWeb: 1,
                                   backgroundColor: Colors.white70,
                                   textColor: Colors.black,
                                   fontSize: 16.0);
                                    }
                                     },
                              child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('loginButton'),
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white , fontWeight: FontWeight.bold),
                                  ),
                            ),
                          )
                        ),
                        SizedBox(),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('account'),),
                              TextButton(
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('create'),
                                  style: TextStyle(fontSize: 15),
                                ),
                                onPressed: () async{
                                  {
                                    if(!isLoading) {
                                      List<List<
                                          String>> fetchedCountries = await fetchCountries();
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                              new SignUp(
                                                  {
                                                    "countries": fetchedCountries[0],
                                                    "countryIds": fetchedCountries[1]
                                                  }

                                              )
                                          )
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastWaitWhileLoading'),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white70,
                                          textColor: Colors.black,
                                          fontSize: 16.0);
                                    }
                                  }
                                },
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => launch('https://osmanbaba.net/Privacy'),
                          child: Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Text(
                              Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('privacy'),
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // LOGO
                Positioned(
                  top: 25,
                  left: 0,
                  right: 0,
                  child: Container(
//                      margin: EdgeInsets.only(bottom: 200),
                      child:
                      Center(child: Image.asset("assets/imgs/login.png", width: 200, height: 200,))),
                ),
                // Footer Logo
                Positioned(
                  bottom: 16.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            this.context,
                            new MaterialPageRoute(builder: (context) => new Second(null, null, true))
                        );
                      } ,
                      child: Image(
                        image: AssetImage(assetsURL + 'footerob.png'),
                        height: 40,
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  Future<void> storeUserLoginPreference(token, username, password, email, id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setString('email', email);
    await prefs.setString('id', id);
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return Text(
        Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('loginButton'),
        style: TextStyle(
          color: Colors.grey[100],
        ),
      );
    } else if (_state == 1) {
      return Container(
        height: 15,
        width: 15,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateLoginButton() async{
    setState(() {
      _state = 1;
    });

    List<String> data = [
      usernameController.text,
      passwordController.text
    ];

    var head = {
      "Accept": "application/json",
      "content-type":"application/json"
    };

    if (data[0].isEmpty || data[1].isEmpty) {
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);

      setState(() {
        isLoading = false;
        _state = 0;
      });
    }
    else {
      isLoading = true;
      var response = await http.post(Uri.parse(webURL + "api/Login"), body: jsonEncode(
        {
          "UserName": data[0],
          "Password": data[1]
        },
      ), headers: head
      ).timeout(const Duration(seconds: 20), onTimeout:(){
        setState(() {
          _state = 0;
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0
        );
        throw TimeoutException('The connection has timed out, Please try again!');
      });
      isLoading = false;

      if(response.statusCode == 500) {
        Fluttertoast.showToast(
            msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
      }
      else {
        var jsonResponse = json.decode(response.body);
        if(jsonResponse["description"] == "InActive") {
          Fluttertoast.showToast(
              msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('accountInactive'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);
        }
        else if (!jsonResponse["status"]) {
          if(jsonResponse.containsKey("accessFailedCount")){
            Fluttertoast.showToast(
                msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastNotMatched') +
                    (4 - jsonResponse["accessFailedCount"]).toString() +
                    Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastNotMatched2'),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white70,
                textColor: Colors.black,
                fontSize: 16.0);
          }else{
            Fluttertoast.showToast(
                msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastNotMatched3'),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white70,
                textColor: Colors.black,
                fontSize: 16.0);
          }

          print("$jsonResponse logiiiiiiiin");
        }
        else {
          storeUserLoginPreference(
              jsonResponse["description"]["token"],
              data[0], data[1],
              jsonResponse["description"]["email"],
              jsonResponse["description"]["id"]);

          bool isCompany = jsonResponse["description"]["role"] == "Company";

          Navigator.push(
            // Second Navigator
              context,
              new MaterialPageRoute(
                  builder: (context) => new Second(
                      {
                        'username': data[0],
                        'password': data[1],
                        'isLoggedIn': true,
                      },
                      null,
                      true
                  ),
              ),
          );
          Fluttertoast.showToast(
              msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastWelcome') + data[0],
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);

          setState(() {
            isToken = true;
          });
        }
      }

      setState(() {
        _state = 0;
      });

    }


  }


}


