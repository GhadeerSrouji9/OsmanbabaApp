import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osmanbaba/helpers/globals.dart';
import '../../helpers/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../second.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class SignUpCustomer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpCustomerState();
  }
}


class _SignUpCustomerState extends State {
  int _state = 0;
  bool isLoading = false;

  final nameTextFieldController = TextEditingController();
  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final passwordConfirmTextFieldController = TextEditingController();
  final facebookTextFieldController = TextEditingController();
  final twitterTextFieldController = TextEditingController();
  final instagramTextFieldController = TextEditingController();
  final phoneNumTextFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameTextFieldController.dispose();
    emailTextFieldController.dispose();
    passwordTextFieldController.dispose();
    passwordConfirmTextFieldController.dispose();
    facebookTextFieldController.dispose();
    twitterTextFieldController.dispose();
    instagramTextFieldController.dispose();
    phoneNumTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      supportedLocales: [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
        Locale('ar', 'SAR'),
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

//        localeResolutionCallback: (locale, supportedLocales) {
//          for (var supportedLocale in supportedLocales) {
//            if (supportedLocale.languageCode == locale.languageCode &&
//                supportedLocale.countryCode == locale.countryCode) {
//              return supportedLocale;
//            }
//          }
//          return supportedLocales.first;
//        },

      locale: isLanguageSpecified ? globalLocale : null,

      theme: ThemeData(
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.orange,
//            displayColor: Colors.blue,
        ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),

      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: InkWell(
                onTap: (){
                  Navigator.push(
                      this.context,
                      new MaterialPageRoute(builder: (context) => new Login())
                  );
                } ,
                child: Image(
                  image: AssetImage('assets/imgs/footerob.png'),
                  height: 50,
                ),
              ),
            ),
          ),

        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 32.0, left: 16.0, bottom: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerNameField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: nameTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.transparent,),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmailField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: emailTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.transparent,),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: passwordTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.transparent,),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordConfirmField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: passwordConfirmTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.transparent,),

//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerFacebookUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: facebookTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      //this widget gonna change to droplist
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerTwitterUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: twitterTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      //this widget gonna change to droplist
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerInstagramUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: instagramTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPhoneNumberField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: phoneNumTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.transparent,),

                Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () async{

                    String name = nameTextFieldController.text;
                    String email = emailTextFieldController.text;
                    String password = passwordTextFieldController.text;
                    String passwordConfirm = passwordConfirmTextFieldController.text;
//                    String facebook = facebookTextFieldController.text;
//                    String twitter = twitterTextFieldController.text;
//                    String instagram = instagramTextFieldController.text;
                    String phoneNum = phoneNumTextFieldController.text;

                    print((name == "").toString() + " " + (email == "").toString() + " " + (password == "").toString() + " " + " " + (phoneNum == "").toString());

                    if(name == "" || email == "" || password == "" || phoneNum == "") {
                      print((name == "").toString() + " " + (email == "").toString() + " " + (password == "").toString() + " " + (phoneNum == "").toString());
                      Fluttertoast.showToast(
                        msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmptyFields'),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white70,
                        textColor: Colors.black,
                        fontSize: 16.0);
                    }
                    else if(password != passwordConfirm){
                        Fluttertoast.showToast(
                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordsNoMatch'),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white70,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    }
                    else {
                      await makeCustomerSignUpPostRequest(name, email, password, phoneNum);
                    }
//                    await makePostRequest();

//                    final UserModel userModel = await createUser(name, email, password, countryId, phoneNum);
                    },
                    child: Text(
                        Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerSignUp'),
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
//                _imageFile == null ?  Text('No Image') : Image.file(_imageFile)
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> makeCustomerSignUpPostRequest(name, email, password, phoneNum) async{

    final url = Uri.parse(webURL + "api/RegisterUser");
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"UserName": "' + name + '",' + ' "Email": "' + email + '",' + ' "Password": "' +  password + '",'  + ' "PhoneNum": "' +  phoneNum + '"' + '}';
    final response = await post(url, headers: headers, body: json);

    print(json);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    var decoded = jsonDecode(response.body);

    if(decoded["message"] == "Check your Email"){
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastEmailInvalid'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    } else{
      Navigator.pop(context);
    }
  }

//  Widget setUpButtonChild() {
//    if (_state == 0) {
//      return Container(
//        margin: EdgeInsets.symmetric(vertical: 6.0),
//        child: Image.asset(
//          "assets/imgs/categories.png",
//        ),
//      );
////      return Text(
////        Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('categoriesButton'),
////        style: TextStyle(
////            color: Colors.white,
////        ),
////      );
//    } else if (_state == 1) {
//      return Container(
//        height: 15,
//        width: 15,
//        child: CircularProgressIndicator(
//          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//        ),
//      );
//    } else {
//      return Icon(Icons.check, color: Colors.white);
//    }
//  }
//
//  void animateCategoryButton() async{
//    setState(() {
//      _state = 1;
//    });
//
//    isLoading = true;
//    List<Map<String, dynamic>> categories = await fetchCategories();
//
//
//    Navigator.push(
//        context,
//        new MaterialPageRoute(builder: (context) => new Login())
//    );
//    isLoading = false;
//
//    setState(() {
//      _state = 0;
//    });
//
//  }

}
