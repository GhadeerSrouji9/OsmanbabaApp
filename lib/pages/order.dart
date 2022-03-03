import 'dart:async';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';

import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/personalinfo.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';

import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'chat.dart';
import 'company.dart';
import 'eSignature.dart';



class Order extends StatefulWidget {

  final String price;
  final String name;


  Order(this.price, this.name);


  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {

  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> languageList = [];
  List<Map<String, dynamic>> kindList = [];
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  bool cardInfo = false;
  String dropdownValue;


  String lang(){

    switch(Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode){

      case "en": return "English";
      break;
      case "ar": return "Arabic";
      break;
      case "tr" : return "Turkish";
      break;
    }
    return "Turkish";

  }
  String langShort(val){

    switch(val){

      case "English": return "en";
      break;
      case "Arabic": return "ar";
      break;
      case "Turkish" : return "tr";
      break;
    }
    return "tr";

  }


  Future<List<Map<String, dynamic>>> fetchCategories() async{
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];
    final response = await http.get(Uri.parse(webURL + 'api/ListCategory')).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        isLoading = false;
        _fabState = 0;
        _state = 0;
      });


      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'),
          //                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      throw TimeoutException('The connection has timed out, Please try again!');
    });


    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      var currentRecord;
      setState(() {
        for(int i = 0; i < decoded.length; i++) {
          currentRecord = decoded[i];
          categoryNamesList.add(decoded[i]["name_" + currentLocale].trim());
          while(currentRecord["applicationCategory1"] != null ) {
            currentRecord = currentRecord["applicationCategory1"];
            categoryNamesList.add(currentRecord["name_" + currentLocale].trim());
          }
          if(currentRecord["applicationCategory1"] == null && !primaryCategoryNames.contains(currentRecord["name_" + currentLocale].trim())) {
            print("ffffffffffffffff " + currentRecord["name_" + currentLocale]);
            primaryCategoryNames.add(currentRecord["name_" + currentLocale].trim());
            primaryCategories.add({
              "name": currentRecord["name_" + currentLocale],
              "id": currentRecord["id"],
//              webURL + json.decode(decoded["result"][i]["productImage"])["1"].toString(),
              "image": webURL + json.decode(currentRecord["image"])["1"].toString()
            });
          }
        }
      });
      return primaryCategories;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<String>> getLanguage() async{
    final url = await http.get(Uri.parse(webURL + 'api/ListLanguage'));
    languageList=[];
    var response=jsonDecode(url.body);
    if(response['status']){
      for(int i = 0; i < response["description"].length; i++){
        languageList.add(
            {
              "id": response["description"][i]["id"],
              "name": response["description"][i]["name_" + globalLocale.toString().substring(0, 2)]
            }
        );
        print(languageList[i]);


        // price=kindList[i]['price'];
        //return response;
      }
    }
  }

  Future<void> storeLanguagePreference(val) async {
    print(
        '___SECOND storeLanguagePreference: val: ' + val + ' ' + langMap[val]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);

    print('___SECOND storeLanguagePreference: Glocale: ' +
        globalLocale.languageCode.toString() +
        ' ' +
        globalLocale.countryCode.toString());

    await prefs.setString('languageCode', globalLocale.languageCode);
    await prefs.setString('countryCode', globalLocale.countryCode);
    await prefs.setBool('isLanguageSpecified', true);
  }

  Future<List<String>> getKind() async{
    final url = await http.get(Uri.parse(webURL + 'api/ListKind'));
    kindList=[];
    var response=jsonDecode(url.body);
    if(response['status']){
      for(int i = 0; i < response.length; i++){
        kindList.add(
            {
              "id": response["description"][i]["id"],
              "name": response["description"][i]["name_" + globalLocale.toString().substring(0, 2)],
              "price": response["description"][i]["price"]
            }
        );
        print(kindList[i]);
        dropdownNameItems.add(kindList[i]["name"]);
        print(dropdownNameItems[i]);


        // price=kindList[i]['price'];
        //return response;
      }
    }
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
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
        ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),

      home:  AdvancedDrawer(
      backdropColor: Colors.orange,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      openRatio: 0.5,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: Localizations.localeOf(context).toString() == 'ar_SAR' ? true : false ,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: appbar(context,_advancedDrawerController)

          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              border: TableBorder.symmetric(
                                  outside: BorderSide(width: 1, color: Colors.orange
                                  )),
                              children: [
                                TableRow(
                                    decoration: BoxDecoration(color: Colors.orange
                                    ),
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adProduct')),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                          margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price')),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )),
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Text("${widget.name}",
                                            style:  TextStyle(color: Colors.black),
                                          )
                                      ),
                                      Container(
                                          margin: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                          child: Text("${widget.price}" + " " + (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                            style: TextStyle(color: Colors.black),
                                          )),
                                    ]
                                ),
                              ],
                            ),

                          ),
                        )
                      ],
                    ),
                  ),

                  Container(
                      padding: EdgeInsets.all(20), //padding of outer Container
                      child: DottedBorder(
                        color: Colors.orange,//color of dotted/dash line
                        strokeWidth: 3, //thickness of dash/dots
                        dashPattern: [10,6],
                        //dash patterns, 10 is dash width, 6 is space width
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                            color: Color.fromRGBO(245, 245, 245, 1),
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                   (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageName')),
                                      style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price')),
                                      style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                margin: EdgeInsets.only(right: 12, left: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${widget.name}",
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      "${widget.price}" + " " + (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30,),
                              Container(
                                  margin: EdgeInsets.only(left: 50, right: 50),
                                  child: Divider(color: Colors.orange,)),
                              SizedBox(height: 30,),

                              Container(
                                color: Colors.orange,
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total')),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      "${widget.price}" + " " + (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40,),
                            ],
                          ),
                        ),
                      )
                  ),
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(bottom: 100),
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.orange) ),
                      onPressed: (){
                        Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => new PersonalInfo(widget.price, widget.name))
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18.0,
                            semanticLabel: 'Text to announce in accessibility modes',
                          ),
                          Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('next')),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            spincbbh(context),
          ],
        ),
      ),
        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,
    );

  }
}
