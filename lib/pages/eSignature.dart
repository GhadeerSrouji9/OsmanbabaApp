import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osmanbaba/Models/Message.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'Packages.dart';
import 'SignalRHelper.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'chat.dart';
import 'company.dart';
import 'order.dart';


class Esignature extends StatefulWidget {

  @override
  _EsignatureState createState() => _EsignatureState();
}

class _EsignatureState extends State<Esignature> {
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  SignalRHelper signalR = new SignalRHelper();
  var scrollController = ScrollController();
  var txtController = TextEditingController();
  List<Map<String, dynamic>> packages = [];

  String packageName = "";
  String packagePrice = "";


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

  final List<String> dropdownNameItems=[""];
  CarouselController buttonCarouselController = CarouselController();
  List<Map<String, dynamic>> kindList = [];


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

  Future<void> fetchPackages() async {
    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;
    final response = await http.get(Uri.parse(webURL + 'api/ListPackage'));

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      setState(() {
        for(int i = 0; i < decoded.length; i++){
          packages.add(
              {
                "id": decoded[i]["id"],
                "name": decoded[i]["name_" + currentLocale],
                "numberAd": decoded[i]["numberAd"],
                "number30": decoded[i]["number30"],
                "numberBold": decoded[i]["numberBold"],
                "numberBanner": decoded[i]["numberBanner"],
                "search": decoded[i]["search"],
                "socialMedia": decoded[i]["socialMedia"],
                "message": decoded[i]["message"],
                "price": decoded[i]["price"],
                "priceYear": decoded[i]["priceYear"],
                "price6Month": decoded[i]["price6Month"],
                "used": decoded[i]["used"],
                "active": decoded[i]["active"],
              }
          );
          print("bbbbbbbbbbbbbbbb " + packages[i].toString());
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
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

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
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


  @override
  void initState() {
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
              child: appbar(context,_advancedDrawerController)
            ),
          ),
          body: Container(
            margin: EdgeInsets.only(top: 30),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('eimzaTitle1')),
                          style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.orange,),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12, right: 12,),
                        child: ReadMoreText((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('eimzaText1')),
                          trimLines: 3,
                          colorClickableText: Colors.orange,
                          trimMode: TrimMode.Line,
                          moreStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                          trimCollapsedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('more'),
                          trimExpandedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('less'),
                          style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                        ),
                      ),
                      SizedBox(height: 50,),
                      Column(
                        children: [
                          Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle1')),
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20) ,
                          ),
                          Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle2')),
                            style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold, fontSize: 18) ,
                          ),
                          SizedBox(height: 50,),
                          Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle3')),
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20) ,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: false,
                          autoPlayAnimationDuration: Duration(milliseconds: 3000),
                          pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                        ),
                        carouselController: buttonCarouselController,
                        items: [
                          Container(
                            width: 300,
                            height: 280,
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                            ),
                            child: Card(
                              child: Column(
                                children: [
                                  Container(
                                    width: 300,
                                    height: 100,
                                    color: Colors.orange,
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('oneYearPackage')),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("219",
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
                                          width: 280,
                                          child: ElevatedButton(
                                            onPressed: (){
                                              packagePrice = "219";
                                              packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle3'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                              );
                                            },
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                              style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not1')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not2')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not3')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 280,
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                            ),
                            child: Card(
                              child: Column(
                                children: [
                                  Container(
                                    width: 300,
                                    height: 100,
                                    color: Colors.orange,
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('twoYearPackage')),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("329",
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
                                          width: 280,
                                          child: ElevatedButton(
                                            onPressed: (){
                                              packagePrice = "329";
                                              packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle3'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                              );
                                            },
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                              style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not1')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not2')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not3')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 280,
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                            ),
                            child: Card(
                              child: Column(
                                children: [
                                  Container(
                                    width: 300,
                                    height: 100,
                                    color: Colors.orange,
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('threeYearPackage')),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("429",
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
                                          width: 280,
                                          child: ElevatedButton(
                                            onPressed: (){
                                              packagePrice = "429";
                                              packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle3'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                              );
                                            },
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                              style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not1')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not2')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not3')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                          ],
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
                      SizedBox(height: 70,),
                      Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle4')),
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20) ,
                      ),
                      SizedBox(height: 10,),
                      CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 0.8,
                            enlargeCenterPage: false,
                            autoPlay: false,
                            autoPlayAnimationDuration: Duration(milliseconds: 3000),
                            pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                          ),
                          carouselController: buttonCarouselController,
                          items: [
                            Container(
                              width: 300,
                              height: 280,
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 300,
                                      height: 100,
                                      color: Colors.orange,
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('oneYearPackage')),
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("152",
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
                                            width: 280,
                                            child: ElevatedButton(
                                              onPressed: (){
                                                packagePrice = "152";
                                                packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle4'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                                );
                                              },
                                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 300,
                              height: 280,
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 300,
                                      height: 100,
                                      color: Colors.orange,
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('twoYearPackage')),
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("201",
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
                                            width: 280,
                                            child: ElevatedButton(
                                              onPressed: (){
                                                packagePrice = "201";
                                                packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle4'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                                );
                                              },
                                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 300,
                              height: 280,
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 300,
                                      height: 100,
                                      color: Colors.orange,
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('threeYearPackage')),
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("239",
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
                                            width: 280,
                                            child: ElevatedButton(
                                              onPressed: (){
                                                packagePrice = "239";
                                                packageName = (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageTitle4'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(builder: (context) => new Order(packagePrice, packageName))
                                                );
                                              },
                                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('buyNow')),
                                                style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,)),
                                            ],
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
                      Stack(
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.only(right: 10, left: 10, top: 60, bottom: 150),
                              decoration: BoxDecoration(
                              border: Border.all(color: Color.fromRGBO(46, 96, 113, 1) ,),
                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                            ),
                            child: Container(
                              padding :EdgeInsets.only(top: 30, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                      child:
                                          Container(
                                              width: MediaQuery.of(context).size.width * 0.8,
                                              child:
                                          Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not5')),
                                            style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 12, fontStyle: FontStyle.italic),)),

                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not4')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 12, fontStyle: FontStyle.italic),
                                      )),
                                      SizedBox(height: 20,),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not6')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 12, fontStyle: FontStyle.italic),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            right: 20,
                            child: Container(
                              child: Icon(Icons.announcement_rounded, color: Color.fromRGBO(46, 96, 113, 1), size: 50,),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                spincbbh(context),
              ],
            ),
          ),
        ),
        drawer: Drawers()
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
