import 'dart:async';
import 'dart:convert';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/kurumsal.dart';
import 'package:osmanbaba/pages/order.dart';
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
import 'orderKurumsal.dart';

class Packages extends StatefulWidget {
  final List<Map<String, dynamic>>  packages;
  Packages(this.packages);

  @override
  _PackagesState createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  final _advancedDrawerController = AdvancedDrawerController();
  final List<String> dropdownNameItems=[""];
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;

  String price = "";
  String name = "";
  String packagePrice6Month = "";
  String packagePriceYear = "";


  String packageName = "";
  String packagePrice = "";
  CarouselController buttonCarouselController = CarouselController();


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

  Future<void> storeLanguagePreference(val) async {
    print('___SECOND storeLanguagePreference: val: ' + val + ' ' + langMap[val]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);

    print('___SECOND storeLanguagePreference: Glocale: ' +
        globalLocale.languageCode.toString() + ' ' +
        globalLocale.countryCode.toString());

    await prefs.setString('languageCode', globalLocale.languageCode);
    await prefs.setString('countryCode', globalLocale.countryCode);
    await prefs.setBool('isLanguageSpecified', true);
  }

  List<Map<String, dynamic>> kindList = [];
  List<Map<String, dynamic>> listPackage = [];

  List<Map<String, dynamic>> languageList = [];

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

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  List<Map<String, dynamic>> packages = [];

  Widget checkIcon() => Padding(padding: EdgeInsets.only(bottom: 16, top: 8),
    child: Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
  );


  Widget cancelIcon() => Padding(padding: EdgeInsets.only(bottom: 16, top: 8),
    child: Icon(
      Icons.cancel,
      color: Colors.orange,
    ),
  );



  Future<List<String>> getPackage() async{
    final url = await http.get(Uri.parse(webURL + 'api/ListPackage'));
    listPackage=[];
    var response=jsonDecode(url.body);
    if(response['status']){
      for(int i = 0; i < response["description"].length; i++){
        listPackage.add(
            {
              "id": response["description"][i]["id"],
              "name": response["description"][i]["name_" + globalLocale.toString().substring(0, 2)],
              "price": response["description"][i]["price"],
              "price6Month": response["description"][i]["price6Month"],
              "priceYear": response["description"][i]["priceYear"],
            }
        );
        print("wwwwwww"+ listPackage[i].toString());
        print(listPackage[i]);
      }
    }
  }




  @override
  void initState() {

    if(widget.packages != null){
      packages = widget.packages;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3 ,
    child: MaterialApp(
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
              child: appbar(context,_advancedDrawerController)
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Table(
                                border: TableBorder.symmetric(
                                    outside: BorderSide(width: 1, color: Colors.orange
                                )),
                                children: [
                                  TableRow(
                                      children: [
                                    TableCell(
                                        child: Center(
                                            child: Text(''))),
                                    TableCell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 50, bottom: 20),
                                        child: Center(
                                            child: Text(packages[8]["name"],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                          textAlign: TextAlign.center,)),
                                      ),
                                    ),
                                    TableCell(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 50),
                                          child: Center(child: Text(packages[2]["name"],
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                            textAlign: TextAlign.center,)),
                                        )),
                                    TableCell(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 50),
                                          child: Center(child: Text(packages[3]["name"],
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                            textAlign: TextAlign.center,)),
                                        )),
                                  ]),
                                  TableRow(
                                      decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                      ),
                                      children: [
                                    TableCell(

                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                        child: Container(
                                          height: 50,
                                          child: Center(child: Container(
                                              height: 50,
                                              width: 100,
                                              child: Align(
                                                  alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                      .locale
                                                      .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                  child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adnumber'),
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                    textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                        .locale
                                                        .languageCode == "ar" ? TextAlign.end : TextAlign.start,
                                                  )))),
                                        ),
                                      )),
                                      verticalAlignment: TableCellVerticalAlignment.bottom,
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Center(child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                            height: 50,
                                            child: Center(
                                              child: packages[8]["numberAd"] == 0 ?
                                              cancelIcon():
                                              Text(
                                                packages[8]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            )),
                                      )),
                                    ),
                                    TableCell(
                                        child: Center(
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                  height: 50,
                                                  child: Center(
                                                    child: packages[2]["numberAd"] == 0 ?
                                                    cancelIcon():
                                                    Text(
                                                      packages[2]["numberAd"].toString(),
                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))),
                                    TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[3]["numberAd"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[3]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                          )),
                                      verticalAlignment: TableCellVerticalAlignment.top,
                                    ),
                                  ]),
                                  TableRow(
                                      children: [
                                        TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                              child: Container(
                                                  height: 50,
                                                  width: 100,
                                                  child: Align(
                                                      alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                          .locale
                                                          .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                      child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('banner'),
                                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.start,
                                                      ))),
                                            )),
                                        TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                      child: packages[8]["numberBanner"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[8]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                                    )),
                                              )),
                                        ),
                                        TableCell(
                                            child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      height: 50,
                                                      child: Center(
                                                          child: packages[2]["numberBanner"] == 0 ?
                                                          cancelIcon():
                                                          Text(packages[2]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                                ))),
                                        TableCell(
                                            child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      height: 50,
                                                      child: Center(
                                                          child: packages[3]["numberBanner"] == 0 ?
                                                          cancelIcon():
                                                          Text(packages[3]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                                ))),
                                      ]),
                                  TableRow(
                                      decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                      ),
                                      children: [
                                        TableCell(
                                            child:
                                            Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                                                  child: Container(
                                                      height: 50,
                                                      width: 100,
                                                      child: Align(
                                                          alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                              .locale
                                                              .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mainpage'),
                                                            maxLines: 3,
                                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.start,

                                                          ))),
                                                ))),
                                        TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[8]["number30"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[8]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                              )),
                                        ),
                                        TableCell(
                                            child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      height: 50,
                                                      child: Center(
                                                          child: packages[2]["number30"] == 0 ?
                                                          cancelIcon():
                                                          Text(packages[2]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                                ))),
                                        TableCell(
                                            child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      height: 50,
                                                      child: Center(
                                                          child: packages[3]["number30"] == 0 ?
                                                          cancelIcon():
                                                          Text(packages[3]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                                ))),
                                      ]),
                                  TableRow(children: [
                                    TableCell(
                                        child:
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                              child: Container(
                                                  height: 50,
                                                  width: 100,
                                                  child: Align(
                                                      alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                          .locale
                                                          .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                      child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sosyalmedya'),
                                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.start,

                                                      ))),
                                            ))),
                                    TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[8]["socialMedia"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[8]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                          )),
                                    ),
                                    TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                      child: packages[2]["socialMedia"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[2]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                            ))),
                                    TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                      child: packages[3]["socialMedia"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[3]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                            ))),
                                  ]),
                                  TableRow(
                                      decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                      ),
                                      children: [
                                        TableCell(
                                            child:
                                            Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                  child: Container(
                                                      height: 50,
                                                      width: 100,
                                                      child: Align(
                                                          alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                              .locale
                                                              .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('searchresults'),
                                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.start,

                                                          ))),
                                                ))),
                                        TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child:
                                                    Center(
                                                        child: packages[8]["search"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[8]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),

                                              )),
                                        ),
                                        TableCell(
                                            child:
                                            Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      height: 50,
                                                      child: Center(
                                                          child: packages[2]["search"] == 0 ?
                                                          cancelIcon():
                                                          Text(packages[2]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                                ))),
                                        TableCell(child: Center(child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 50,
                                              child: Center(
                                                  child: packages[3]["search"] == 0 ?
                                                  cancelIcon():
                                                  Text(packages[3]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold)))),
                                        ))),
                                      ]),
                                  TableRow(
                                      children: [
                                        TableCell(
                                            child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                  child: Container(
                                                      height: 50,
                                                      width: 100,
                                                      child: Align(
                                                          alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                              .locale
                                                              .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price'),
                                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                            textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                                .locale
                                                                .languageCode == "ar" ? TextAlign.end : TextAlign.start,)
                                                      )
                                                  ),
                                                )
                                            )
                                        ),
                                        TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 100,
                                                    child:
                                                    Center(
                                                        child:
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child: packages[8]["price"] == 0 ?
                                                            cancelIcon():
                                                            // llllllllllllllll
                                                            packages[8]["addtionalPrice"] == 0 ?
                                                            Text("\n" +packages[8]["price"].toString() + " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                            ) : Column(
                                                              children: [
                                                                Text(packages[8]["price"].toString()+' %',
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                                Text("+ " + packages[8]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),),
                                                              ],
                                                            )
                                                        ),
                                                        Container(
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              packagePrice = packages[8]["price"].toString();
                                                              packageName = packages[8]["name"].toString();
                                                              packagePrice6Month = packages[8]["price6Month"].toString();
                                                              packagePriceYear = packages[8]["priceYear"].toString();
                                                              Navigator.push(
                                                                  context,
                                                                  new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear )),
                                                              );
                                                            },
                                                            child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                              style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          ),
                                                        ),
                                                      ],
                                                    ))),
                                              )),
                                        ),
                                        TableCell(
                                            child:
                                            Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0,),
                                                  child: Container(
                                                      height: 100,
                                                      child: Center(child:
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                              child: packages[2]["price"] == 0 ?
                                                              cancelIcon():
                                                              // llllllllllllllll
                                                              packages[2]["addtionalPrice"] == 0 ?
                                                              Text("\n" + packages[2]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                              ) : Column(
                                                                children: [
                                                                  Text(packages[2]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                                  Text("+ " + packages[2]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),),
                                                                ],
                                                              )
                                                          ),
                                                          Container(
                                                            child: ElevatedButton(
                                                              onPressed: (){
                                                                packagePrice = packages[2]["price"].toString();
                                                                packageName = packages[2]["name"].toString();
                                                                packagePrice6Month = packages[2]["price6Month"].toString();
                                                                packagePriceYear = packages[2]["priceYear"].toString();
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                                );
                                                              },
                                                              child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                                style: TextStyle(color: Colors.white, fontSize: 10),),
                                                            ),
                                                          )
                                                        ],
                                                      ))),
                                                ))),
                                        TableCell(child:
                                          Center(child:
                                            Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 100,
                                              child: Center(child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      child: packages[3]["price"] == 0 ?
                                                      cancelIcon():
                                                      // llllllllllllllll
                                                      packages[3]["addtionalPrice"] == 0 ?
                                                      Text("\n" + packages[3]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                      ) : Column(
                                                        children: [
                                                          Text(packages[3]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                          Text("+ " + packages[3]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),),
                                                        ],
                                                      )
                                                  ),
                                                  Container(
                                                    child: ElevatedButton(
                                                      onPressed: (){
                                                        packagePrice = packages[3]["price"].toString();
                                                        packageName = packages[3]["name"].toString();
                                                        packagePrice6Month = packages[3]["price6Month"].toString();
                                                        packagePriceYear = packages[3]["priceYear"].toString();
                                                        Navigator.push(
                                                            context,
                                                            new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                        );
                                                      },
                                                      child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                        style: TextStyle(color: Colors.white, fontSize: 10),),
                                                    ),
                                                  )
                                                ],
                                              ))),
                                        ))),
                                      ]
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                  .locale
                                  .languageCode == "ar" ? Alignment.center: Alignment.center,
                              child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)), color: Colors.orange),
                                  margin: EdgeInsets.only(top: 8, left: 8, bottom: 16, right: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('reklam'),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Table(
                              border: TableBorder.symmetric(outside: BorderSide(width: 1, color: Colors.orange
                              )),
                              children: [
                                TableRow(children: [
                                  TableCell(
                                      child: Center(child: Text(''))),
                                  TableCell(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 50, bottom: 20),
                                      child: Center(child: Text(packages[6]["name"],
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                        textAlign: TextAlign.center,)),
                                    ),
                                  ),
                                  TableCell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 50),
                                        child: Center(child: Text(packages[0]["name"],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                          textAlign: TextAlign.center,)),
                                      )),
                                  TableCell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 50),
                                        child: Center(child: Text(packages[5]["name"],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                          textAlign: TextAlign.center,)),
                                      )),
                                ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                  TableCell(
                                    child: Center(child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                      child: Container(
                                        height: 50,
                                        child: Center(child: Container(
                                            height: 50,
                                            width: 100,
                                            child: Align(
                                                alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                    .locale
                                                    .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adnumber'),
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                  textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                      .locale
                                                      .languageCode == "ar" ? TextAlign.end : TextAlign.start,
                                                )))),
                                      ),
                                    )),
                                    verticalAlignment: TableCellVerticalAlignment.bottom,
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Center(child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                          height: 50,
                                          child: Center(
                                            child: packages[6]["numberAd"] == 0 ?
                                            cancelIcon():
                                            Text(
                                              packages[6]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    )),
                                  ),
                                  TableCell(
                                      child: Center(
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                height: 50,
                                                child: Center(
                                                  child: packages[0]["numberAd"] == 0 ?
                                                  cancelIcon():
                                                  Text(
                                                    packages[0]["numberAd"].toString(),
                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))),
                                  TableCell(
                                    child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 50,
                                              child: Center(
                                                  child: packages[5]["numberAd"] == 0 ?
                                                  cancelIcon():
                                                  Text(packages[5]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                        )),
                                    verticalAlignment: TableCellVerticalAlignment.top,
                                  ),
                                ]),
                                TableRow(
                                    children: [
                                      TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                            child: Container(
                                                height: 50,
                                                width: 100,
                                                child: Align(
                                                    alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                        .locale
                                                        .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('banner'),
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.start,
                                                    ))),
                                          )),
                                      TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                    child: packages[6]["numberBanner"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[6]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                                  )),
                                            )),
                                      ),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[0]["numberBanner"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[0]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[5]["numberBanner"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[5]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                    ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mainpage'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.start,

                                                        ))),
                                              ))),
                                      TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                      child: packages[6]["number30"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[6]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                            )),
                                      ),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[0]["number30"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[0]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[5]["number30"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[5]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                    ]),
                                TableRow(children: [
                                  TableCell(
                                      child:
                                      Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                            child: Container(
                                                height: 50,
                                                width: 100,
                                                child: Align(
                                                    alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                        .locale
                                                        .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sosyalmedya'),
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.start,

                                                    ))),
                                          ))),
                                  TableCell(
                                    child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 50,
                                              child: Center(
                                                  child: packages[6]["socialMedia"] == 0 ?
                                                  cancelIcon():
                                                  Text(packages[6]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                        )),
                                  ),
                                  TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[0]["socialMedia"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[0]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                          ))),
                                  TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[5]["socialMedia"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[5]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                          ))),
                                ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('searchresults'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.start,

                                                        ))),
                                              ))),
                                      TableCell(
                                        child:
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child:
                                                  Center(
                                                      child: packages[6]["search"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[6]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),

                                            )),
                                      ),
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[0]["search"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[0]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(child: Center(child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                            height: 50,
                                            child: Center(
                                                child: packages[5]["search"] == 0 ?
                                                cancelIcon():
                                                Text(packages[5]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                      ))),
                                    ]),
                                TableRow(
                                    children: [
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                              .locale
                                                              .languageCode == "ar" ? TextAlign.end : TextAlign.start,))),
                                              ))),
                                      TableCell(
                                        child:
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 100,
                                                  child: Center(child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                          child: packages[6]["price"] == 0 ?
                                                          cancelIcon():
                                                          // llllllllllllllll
                                                          packages[6]["addtionalPrice"] == 0 ?
                                                          Text("\n" + packages[6]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                          ) : Column(
                                                            children: [
                                                              Text(packages[6]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                              Text("+ " + packages[6]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),),
                                                            ],
                                                          )
                                                      ),
                                                      Container(
                                                        child: ElevatedButton(
                                                          onPressed: (){
                                                            packagePrice = packages[6]["price"].toString();
                                                            packageName = packages[6]["name"].toString();
                                                            packagePrice6Month = packages[6]["price6Month"].toString();
                                                            packagePriceYear = packages[6]["priceYear"].toString();
                                                            Navigator.push(
                                                                context,
                                                                new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                            );
                                                          },
                                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                            style: TextStyle(color: Colors.white, fontSize: 10),),
                                                        ),
                                                      )
                                                    ],
                                                  ))),
                                            )),
                                      ),
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0,),
                                                child: Container(
                                                    height: 100,
                                                    child: Center(child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child: packages[0]["price"] == 0 ?
                                                            cancelIcon():
                                                            // llllllllllllllll
                                                            packages[0]["addtionalPrice"] == 0 ?
                                                            Text("\n" + packages[0]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                            ) : Column(
                                                              children: [
                                                                Text(packages[0]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                                Text("+ " + packages[0]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),),
                                                              ],
                                                            )
                                                        ),
                                                        Container(
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              packagePrice = packages[0]["price"].toString();
                                                              packageName = packages[0]["name"].toString();
                                                              packagePrice6Month = packages[0]["price6Month"].toString();
                                                              packagePriceYear = packages[0]["priceYear"].toString();
                                                              Navigator.push(
                                                                  context,
                                                                  new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                              );
                                                            },
                                                            child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                              style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          ),
                                                        )
                                                      ],
                                                    ))),
                                              ))),
                                      TableCell(child: Center(child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                            height: 100,
                                            child:
                                            Center(child:
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    child: packages[5]["price"] == 0 ?
                                                    cancelIcon():
                                                    // llllllllllllllll
                                                    packages[5]["addtionalPrice"] == 0 ?
                                                    Text("\n" + packages[5]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)
                                                    ) : Column(
                                                      children: [
                                                        Text(packages[5]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                        Text("+ " + packages[5]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                                Container(
                                                  child: ElevatedButton(
                                                    onPressed: (){
                                                      packagePrice = packages[5]["price"].toString();
                                                      packageName = packages[5]["name"].toString();
                                                      packagePrice6Month = packages[5]["price6Month"].toString();
                                                      packagePriceYear = packages[5]["priceYear"].toString();
                                                      Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                      );
                                                    },
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                      style: TextStyle(color: Colors.white, fontSize: 10),),
                                                  ),
                                                )
                                              ],
                                            ))),
                                      ))),
                                    ])
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                .locale
                                .languageCode == "ar" ? Alignment.center: Alignment.center,
                            child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)), color: Colors.orange),
                                margin: EdgeInsets.only(top: 8, left: 8, bottom: 16, right: 8),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('bireyselReklam'),
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),)
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Table(
                              border: TableBorder.symmetric(outside: BorderSide(width: 1, color: Colors.orange
                              )),
                              children: [
                                TableRow(children: [
                                  TableCell(
                                      child: Center(child: Text(''))),
                                  TableCell(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 50, bottom: 20),
                                      child: Center(child: Text(packages[7]["name"],
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                        textAlign: TextAlign.center,)),
                                    ),
                                  ),
                                  TableCell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 50),
                                        child: Center(child: Text(packages[1]["name"],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                          textAlign: TextAlign.center,)),
                                      )),
                                  TableCell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 50),
                                        child: Center(child: Text(packages[4]["name"],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                                          textAlign: TextAlign.center,)),
                                      )),
                                ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                  TableCell(
                                    child: Center(child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10 , right: 10),
                                      child: Container(
                                        height: 50,
                                        child: Center(child: Container(
                                            height: 50,
                                            width: 100,
                                            child: Align(
                                                alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                    .locale
                                                    .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adnumber'),
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                  textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                      .locale
                                                      .languageCode == "ar" ? TextAlign.end : TextAlign.start,
                                                )))),
                                      ),
                                    )),
                                    verticalAlignment: TableCellVerticalAlignment.bottom,
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Center(child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                          height: 50,
                                          child: Center(
                                            child: packages[7]["numberAd"] == 0 ?
                                            cancelIcon():
                                            Text(
                                              packages[7]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    )),
                                  ),
                                  TableCell(
                                      child: Center(
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                height: 50,
                                                child: Center(
                                                  child: packages[1]["numberAd"] == 0 ?
                                                  cancelIcon():
                                                  Text(
                                                    packages[1]["numberAd"].toString(),
                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))),
                                  TableCell(
                                    child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 50,
                                              child: Center(
                                                  child: packages[4]["numberAd"] == 0 ?
                                                  cancelIcon():
                                                  Text(packages[4]["numberAd"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                        )),
                                    verticalAlignment: TableCellVerticalAlignment.top,
                                  ),
                                ]),
                                TableRow(
                                    children: [
                                      TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
                                            child: Container(
                                                height: 50,
                                                width: 100,
                                                child: Align(
                                                    alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                        .locale
                                                        .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('banner'),
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                          .locale
                                                          .languageCode == "ar" ? TextAlign.end : TextAlign.start,
                                                    ))),
                                          )),
                                      TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                    child: packages[7]["numberBanner"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[7]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                                  )),
                                            )),
                                      ),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[1]["numberBanner"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[1]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[4]["numberBanner"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[4]["numberBanner"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                    ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0,left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mainpage'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.start,

                                                        ))),
                                              ))),
                                      TableCell(
                                        child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child: Center(
                                                      child: packages[7]["number30"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[7]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                            )),
                                      ),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[1]["number30"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[1]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[4]["number30"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[4]["number30"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                    ]),
                                TableRow(children: [
                                  TableCell(
                                      child:
                                      Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                            child: Container(
                                                height: 50,
                                                width: 100,
                                                child: Align(
                                                    alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                        .locale
                                                        .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sosyalmedya'),
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.start,

                                                    ))),
                                          ))),
                                  TableCell(
                                    child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 50,
                                              child: Center(
                                                  child: packages[7]["socialMedia"] == 0 ?
                                                  cancelIcon():
                                                  Text(packages[7]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                        )),
                                  ),
                                  TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[1]["socialMedia"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[1]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                          ))),
                                  TableCell(
                                      child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                                height: 50,
                                                child: Center(
                                                    child: packages[4]["socialMedia"] == 0 ?
                                                    cancelIcon():
                                                    Text(packages[4]["socialMedia"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                          ))),
                                ]),
                                TableRow(
                                    decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1),
                                    ),
                                    children: [
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('searchresults'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.start,

                                                        ))),
                                              ))),
                                      TableCell(
                                        child:
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 50,
                                                  child:
                                                  Center(
                                                      child: packages[7]["search"] == 0 ?
                                                      cancelIcon():
                                                      Text(packages[7]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),

                                            )),
                                      ),
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Center(
                                                        child: packages[1]["search"] == 0 ?
                                                        cancelIcon():
                                                        Text(packages[1]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                              ))),
                                      TableCell(child: Center(child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                            height: 50,
                                            child: Center(
                                                child: packages[4]["search"] == 0 ?
                                                cancelIcon():
                                                Text(packages[4]["search"].toString(), style: TextStyle(fontWeight: FontWeight.bold),))),
                                      ))),
                                    ]),
                                TableRow(
                                    children: [
                                      TableCell(
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10, right: 10),
                                                child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    child: Align(
                                                        alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                            .locale
                                                            .languageCode == "ar" ? Alignment.centerRight: Alignment.centerLeft,
                                                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price'),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          textAlign: Localizations.of<AppLocalizations>(context, AppLocalizations)
                                                              .locale
                                                              .languageCode == "ar" ? TextAlign.end : TextAlign.start,))),
                                              ))),
                                      TableCell(
                                        child:
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Container(
                                                  height: 100,
                                                  child: Center(child:
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                          child: packages[7]["price"] == 0 ?
                                                          cancelIcon():
                                                          // llllllllllllllll
                                                          packages[7]["addtionalPrice"] == 0 ?
                                                          Text("\n" + packages[7]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)
                                                          ) : Column(
                                                            children: [
                                                              Text(packages[7]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                              Text("+ " + packages[7]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),),
                                                            ],
                                                          )
                                                      ),
                                                      Container(
                                                        child: ElevatedButton(
                                                          onPressed: (){
                                                            packagePrice = packages[7]["price"].toString();
                                                            packageName = packages[7]["name"].toString();
                                                            packagePrice6Month = packages[7]["price6Month"].toString();
                                                            packagePriceYear = packages[7]["priceYear"].toString();
                                                            Navigator.push(
                                                                context,
                                                                new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                            );
                                                          },
                                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                            style: TextStyle(color: Colors.white, fontSize: 10),),
                                                        ),
                                                      )
                                                    ],
                                                  ))),
                                            )),
                                      ),
                                      TableCell(
                                          child:
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10),
                                                child: Container(
                                                    height: 100,
                                                    child: Center(child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child: packages[1]["price"] == 0 ?
                                                            cancelIcon():
                                                            // llllllllllllllll
                                                            packages[1]["addtionalPrice"] == 0 ?
                                                            Text("\n" + packages[1]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
                                                            ) : Column(
                                                              children: [
                                                                Text(packages[1]["price"].toString()+' %', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                                Text("+ " + packages[1]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),),
                                                              ],
                                                            )
                                                        ),
                                                        Container(
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              packagePrice = packages[1]["price"].toString();
                                                              packageName = packages[1]["name"].toString();
                                                              packagePrice6Month = packages[1]["price6Month"].toString();
                                                              packagePriceYear = packages[1]["priceYear"].toString();
                                                              Navigator.push(
                                                                  context,
                                                                  new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                              );
                                                            },
                                                            child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                              style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          ),
                                                        )
                                                      ],
                                                    ))),
                                              ))),
                                      TableCell(
                                          child: Center(

                                              child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                            height: 100,
                                            child: Center(
                                                child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    child: packages[4]["price"] == 0 ?
                                                    cancelIcon():
                                                    // llllllllllllllll
                                                    packages[4]["addtionalPrice"] == 0 ?
                                                    Text("\n" + packages[4]["price"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)
                                                    ) : Column(
                                                      children: [
                                                        Text(packages[4]["price"].toString()+' %',
                                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                        Text("+ " + packages[4]["addtionalPrice"].toString()+ " " +(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),),
                                                      ],
                                                    )
                                                ),
                                                Container(
                                                  child: ElevatedButton(
                                                    onPressed: (){
                                                      packagePrice = packages[4]["price"].toString();
                                                      packageName = packages[4]["name"].toString();
                                                      packagePrice6Month = packages[4]["price6Month"].toString();
                                                      packagePriceYear = packages[4]["priceYear"].toString();
                                                      Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                      );
                                                    },
                                                    child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('submit'),
                                                      style: TextStyle(color: Colors.white, fontSize: 10),),
                                                  ),
                                                )
                                              ],
                                            ))),
                                      ))),
                                    ])

                              ],
                            ),

                          ),
                        ),
                        Align(
                          alignment: Localizations.of<AppLocalizations>(context, AppLocalizations)
                        .locale
                        .languageCode == "ar" ? Alignment.center: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)), color: Colors.orange),
                              margin: EdgeInsets.only(top: 8, left: 8, bottom: 16, right: 8),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('kullanilan'),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50,),
                    Stack(
                      children: [
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(top: 40, bottom: 20,),
                          child: CarouselSlider(
                              options: CarouselOptions(
                                height: 300,
                                viewportFraction: 0.65,
                                enlargeCenterPage: false,
                                autoPlay: false,
                                autoPlayAnimationDuration: Duration(milliseconds: 3000),
                                pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                              ),
                              carouselController: buttonCarouselController,
                              items: [
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('monthly'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[9]["price"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[9]["price"].toString();
                                                    packageName = packages[9]["name"].toString();
                                                    packagePrice6Month = packages[9]["price6Month"].toString();
                                                    packagePriceYear = packages[9]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear ))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                      style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                    ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1)),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('6month'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[9]["price6Month"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[9]["price6Month"].toString();
                                                    packageName = packages[9]["name"].toString();
                                                    packagePrice6Month = packages[9]["price6Month"].toString();
                                                    packagePriceYear = packages[9]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear ))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                      style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1) ,),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                  margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('yearly'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[9]["priceYear"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[9]["priceYear"].toString();
                                                    packageName = packages[9]["name"].toString();
                                                    packagePrice6Month = packages[9]["price6Month"].toString();
                                                    packagePriceYear = packages[9]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear ))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                      style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1) ,),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                  margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ]
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                color: Colors.orange ,
                            ),
                            child: Center(
                              child: Text(packages[9]["name"].toString(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50,),
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.only(top: 40, bottom: 20,),
                          child: CarouselSlider(
                              options: CarouselOptions(
                                height: 300,
                                viewportFraction: 0.65,
                                enlargeCenterPage: false,
                                autoPlay: false,
                                autoPlayAnimationDuration: Duration(milliseconds: 3000),
                                pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                              ),
                              carouselController: buttonCarouselController,
                              items: [
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('monthly'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[10]["price"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[10]["price"].toString();
                                                    packageName = packages[10]["name"].toString();
                                                    packagePrice6Month = packages[10]["price6Month"].toString();
                                                    packagePriceYear = packages[10]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear ))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                    style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1) ,),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('6month'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[10]["price6Month"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[10]["price6Month"].toString();
                                                    packageName = packages[10]["name"].toString();
                                                    packagePrice6Month = packages[10]["price6Month"].toString();
                                                    packagePriceYear = packages[10]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear ))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                    style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1) ,),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 230,
                                  height: 280,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 75,
                                          color:  Color.fromRGBO(46, 96, 113, 1) ,
                                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('yearly'),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text(packages[10]["priceYear"].toString(),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tl')),
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    packagePrice = packages[10]["priceYear"].toString();
                                                    packageName = packages[10]["name"].toString();
                                                    packagePrice6Month = packages[10]["price6Month"].toString();
                                                    packagePriceYear = packages[10]["priceYear"].toString();
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(builder: (context) => new OrderKurumsal(packagePrice, packageName, packagePrice6Month, packagePriceYear))
                                                    );
                                                  },
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                    style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(46, 96, 113, 1) ,),),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 10 , right: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote1'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote2'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote3'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                    Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageNote4'),
                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ]
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                color: Colors.orange
                            ),
                            child: Center(
                              child: Text(packages[10]["name"].toString(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 110,),
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
    ),
  );

}