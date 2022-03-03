import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';

import 'Packages.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'dart:math' as math;

import 'chat.dart';
import 'company.dart';
import 'eSignature.dart';

class Categories extends StatefulWidget {
  final String categoryId;
  Categories(this.categoryId);

  @override
  State<StatefulWidget> createState() {
    return _CategoriesState();
  }
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> primaryCategories;
  List<Map<String, dynamic>> categoriesList;
  final _advancedDrawerController = AdvancedDrawerController();
  int _state = 0;
  int _fabState = 0;


  bool isLoading = false;
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  List<Image> flagImages = [
    Image.asset('icons/flags/png/gb.png', package: 'country_icons'),
    Image.asset('assets/imgs/sy.jpg'),
    Image.asset('assets/imgs/tr.jpg')
  ];

  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> kindList = [];
  List<Map<String, dynamic>> languageList = [];


  @override
  void initState() {
    if (widget.categoryId != null) {
//      primaryCategories = widget.categoryId;
      print("not nullllllllllll");
    }

//    categoriesList = fetchCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Radius leftSideRadius = new Radius.circular(30.0);
    Radius rightSideRadius = new Radius.circular(0.0);

    if (Localizations.localeOf(context).toString() == 'ar_SAR') {
      leftSideRadius = new Radius.circular(0.0);
      rightSideRadius = new Radius.circular(30.0);
    }

    return MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'SAR'),
        Locale('tr', 'TR'),
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      locale: isLanguageSpecified ? globalLocale : null,

      theme: ThemeData(
//          primaryColor: Color.fromRGBO(200, 100, 0, 1),
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

      home: AdvancedDrawer(
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
              child: appbar(context,_advancedDrawerController),
            ),
          ),
          body: Container(
            margin: EdgeInsets.all(8.0),
            child: Stack(
              children: [
                // GRID MAIN CONTENT
                widget.categoryId == null ?
                FutureBuilder(
                    future: fetchCategories(),
                    builder: (context, categorySnapshot) {
                      if(categorySnapshot.hasData) {
                        return GridView.count(
                          shrinkWrap: false,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 5 / 10,
                          crossAxisCount: 3,
                          // Generate 100 widgets that display their index in the List.
                          children: List.generate(categorySnapshot.data.length, (index) {
                            return InkWell(
                              onTap: () async {
                                print("ssssssssssssssssssss " + _state.toString());
                                //                        List<Map<String, dynamic>> selectedSub = await fetchSubCategories(index);
                                setIndicatorState(categorySnapshot.data[index]['id']);
                              },
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.30,
                                      height: 150,
                                      child: CachedNetworkImage(
                                        imageUrl: categorySnapshot.data[index]["image"].toString(),
                                        placeholder: (context, url) => Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          return Center(child: Container(child: Image.asset('assets/imgs/error/imageLoadFailure.png')));
                                        },
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        categorySnapshot.data[index]["name"],
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      } else {
                        return Container();
                      }
                    }
                ):
                FutureBuilder(
                    future: fetchSubCategories(widget.categoryId),
                    builder: (context, categorySnapshot) {
                      print("cccc ${categorySnapshot.hasData}");
                      if(categorySnapshot.hasData) {
                        return GridView.count(
                          shrinkWrap: false,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 5 / 10,
                          crossAxisCount: 3,
                          // Generate 100 widgets that display their index in the List.
                          children: List.generate(categorySnapshot.data.length, (index) {
                            return InkWell(
                              onTap: () async {
                                print("ssssssssssssssssssss " + _state.toString());
                                // List<Map<String, dynamic>> selectedSub = await fetchSubCategories(index);
                                setIndicatorState(categorySnapshot.data[index]["id"]);
                              },
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.30,
                                      height: 150,
                                      child: CachedNetworkImage(
                                        imageUrl: categorySnapshot.data[index]["image"].toString(),
                                        placeholder: (context, url) => Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          return Center(child: Container(child: Image.asset('assets/imgs/error/imageLoadFailure.png')));
                                        },
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        categorySnapshot.data[index]["name"],
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      } else {
                        return Container();
                      }
                    }
                ),

                Center(
                  child: setUpIndicatorChild(),
                ),
                // FOOTER
                spincbbh(context)
              ],
            ),
          ),
        ),
        drawer: Drawers()
      ),
      debugShowCheckedModeBanner: false,
    );
  }

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


  Future<List<Map<String, dynamic>>> fetchCategories() async {
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];

    final response = await http.get(Uri.parse(webURL + 'api/ListCategoryParents')).timeout(const Duration(seconds: 20), onTimeout:(){
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
//            print("ffffffffffffffff " + currentRecord["name_" + currentLocale]);
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

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  Widget setUpIndicatorChild() {
    if (_state == 0) {
      return null;
    } else if (_state == 1) {
      return Container(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void setIndicatorState(indexVal) async {
    if (_state != 1) {
      setState(() {
        _state = 1;
      });

      List<Map<String, dynamic>> selectedSub = await fetchSubCategories(indexVal);
      if (selectedSub.isNotEmpty) {
        print("ffffffffffff ${_state} ${selectedSub[0]["name"]}");

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new Categories(indexVal)
            )
        );
      } else {
        print("eeeeeeeeeeeeeee " + _state.toString());
        Fluttertoast.showToast(
            msg: Localizations.of<AppLocalizations>(context, AppLocalizations)
                .getTranslation('toastNoSubCategories'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
      }
      setState(() {
        _state = 0;
      });
    }
    else {
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations)
              .getTranslation('toastWaitWhileLoading'),
          //msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  int fetchFlagImage(String countryCode) {
    switch (countryCode) {
      case 'en':
        return 0;
        break;
      case 'ar':
        return 1;
        break;
      case 'tr':
        return 2;
        break;
    }
    return 99;
  }

  Future<List<Map<String, dynamic>>> fetchSubCategories(indexVal) async {
    List<Map<String, dynamic>> subCategories = [];

    final queryParameters = {"id": indexVal};

    print("QQQQQQQQQQ $queryParameters");

    final url = Uri.parse(webURL + "api/ListChildCategoryById");
    final headers = {"Content-type": "application/json"};

    final response =
    await post(url, headers: headers, body: jsonEncode(queryParameters))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      setState(() {
        isLoading = false;
        _state = 0;
      });
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations)
              .getTranslation('ToastConnectionTimeout'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    print('Status code: ${response.statusCode}');

    String currentLocale =
        Localizations.of<AppLocalizations>(context, AppLocalizations)
            .locale
            .languageCode;

    var decoded = jsonDecode(response.body);

    if (decoded["status"]) {
      decoded = decoded["description"];
      var currentRecord;
      setState(() {
        for (int i = 0; i < decoded.length; i++) {
          currentRecord = decoded[i];
//        print("recddddddddddd " + currentRecord.toString());
          subCategories.add({
            "name": currentRecord["name_" + currentLocale],
            "id": currentRecord["id"],
//              webURL + json.decode(decoded["result"][i]["productImage"])["1"].toString(),
            "image":
            webURL + json.decode(currentRecord["image"])["1"].toString()
          });
          print("llllllllllllllv  ${subCategories[i]}");
        }
      });
    }

    return subCategories;
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


}