import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_html/flutter_html.dart';


import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';

class NewsSource extends StatefulWidget {
  final List<Map<String, dynamic>> news;
  NewsSource(this.news);

  @override
  State<StatefulWidget> createState() {
    return _StateNewsSource();
  }

}

class _StateNewsSource extends State<NewsSource> {
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;


  Future<void> storeLanguagePreference(val) async {
    print(
        '___SECOND storeLanguagePreference: val: ' + val + ' ' + langMap[val]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);

    print('___SECOND storeLanguagePreference: Glocale: ' +
        globalLocale.languageCode.toString() + ' ' +
        globalLocale.countryCode.toString());

    await prefs.setString('languageCode', globalLocale.languageCode);
    await prefs.setString('countryCode', globalLocale.countryCode);
    await prefs.setBool('isLanguageSpecified', true);
  }
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> kindList = [];

  List<Map<String, dynamic>> newsSourceList;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];
    final response = await http.get(Uri.parse(webURL + 'api/ListCategory'))
        .timeout(const Duration(seconds: 20), onTimeout: () {
      setState(() {
        isLoading = false;
        _fabState = 0;
        _state = 0;
      });
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations)
              .getTranslation('ToastConnectionTimeout'),
          //                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      throw TimeoutException('The connection has timed out, Please try again!');
    });


    String currentLocale = Localizations
        .of<AppLocalizations>(context, AppLocalizations)
        .locale
        .languageCode;

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      var currentRecord;
      setState(() {
        for (int i = 0; i < decoded.length; i++) {
          currentRecord = decoded[i];
          categoryNamesList.add(decoded[i]["name_" + currentLocale].trim());
          while (currentRecord["applicationCategory1"] != null) {
            currentRecord = currentRecord["applicationCategory1"];
            categoryNamesList.add(
                currentRecord["name_" + currentLocale].trim());
          }
          if (currentRecord["applicationCategory1"] == null &&
              !primaryCategoryNames.contains(
                  currentRecord["name_" + currentLocale].trim())) {
            print("ffffffffffffffff " + currentRecord["name_" + currentLocale]);
            primaryCategoryNames.add(
                currentRecord["name_" + currentLocale].trim());
            primaryCategories.add({
              "name": currentRecord["name_" + currentLocale],
              "id": currentRecord["id"],
//              webURL + json.decode(decoded["result"][i]["productImage"])["1"].toString(),
              "image": webURL +
                  json.decode(currentRecord["image"])["1"].toString()
            });
          }
        }
      });
      return primaryCategories;
    } else {
      throw Exception('Failed to load');
    }
  }

  List<Map<String, dynamic>> languageList = [];

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

  @override
  void initState() {
    newsSourceList = widget.news;
    print("ghghghghghghgh " + globalLocale.toString());
    super.initState();
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

      locale: isLanguageSpecified ? globalLocale : null,

      theme: ThemeData(
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme
            .of(context)
            .textTheme
            .apply(
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
        rtlOpening: Localizations.localeOf(context).toString() == 'ar_SAR'
            ? true
            : false,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          // NOTICE: Uncomment if you want to add shadow behind the page.
          // Keep in mind that it may cause animation jerks.
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 0.0,
          //   ),
          // ],
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
            margin: EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: newsSourceList.length,
              itemBuilder: (context, index) {
                return index == 0 ? Container(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(top: 40.0),
                        elevation: 4,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          margin: EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: CachedNetworkImage(
                                  imageUrl:  newsSourceList[index]["image"],
                                  //fit: BoxFit.scaleDown,
                                  placeholder: (context, url) => Center(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Center(child: Container(height: 30));
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  newsSourceList[index]["name"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                                child: Text(
                                  newsSourceList[index]["title"],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Container(
                                child: Html(
                                 data: newsSourceList[index]["description"].toString() != null ? newsSourceList[0]["description"] :
                                  Localizations.of<AppLocalizations>(
                                      context, AppLocalizations).getTranslation(
                                      'noNewsFound'),
                                  defaultTextStyle: TextStyle(color: Color.fromRGBO(46, 96, 113, 1)),

                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(newsSourceList[index]["storyImage"],

                          ),
                        ),
                      ),
                    ],
                  ),
                ):
                  Card(
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:  newsSourceList[index]["image"],
                              //fit: BoxFit.scaleDown,
                              placeholder: (context, url) => Center(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Center(child: Container(height: 30,));
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            newsSourceList[index]["title"],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          child: Html(
                            data: newsSourceList[index]["description"].toString() !=
                                null ? newsSourceList[0]["description"] :
                            Localizations.of<AppLocalizations>(
                                context, AppLocalizations).getTranslation(
                                'noNewsFound'),
                            defaultTextStyle: TextStyle(
                                color: Color.fromRGBO(46, 96, 113, 1)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          ),
        ),
        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}