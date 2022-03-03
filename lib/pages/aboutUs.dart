import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osmanbaba/Models/Message.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/Packages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'SignalRHelper.dart';


class AboutUs extends StatefulWidget {

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  SignalRHelper signalR = new SignalRHelper();
  var scrollController = ScrollController();
  var txtController = TextEditingController();
  List<Map<String, dynamic>> packages = [];
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> kindList = [];

  VideoPlayerController _controller;


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
    _controller = VideoPlayerController.asset('assets/info.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
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
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle1')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc1')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          Container(
                            child: Image.asset('assets/imgs/grow.png'),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            color: Colors.orangeAccent,
                            child: Center(
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsText1')),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle2')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc2')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsText2')),),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                              onPressed: () {
                                Navigator.push(
                                    this.context,
                                    new MaterialPageRoute(builder: (context) => new Packages(packages))
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  primary: Color.fromRGBO(46, 96, 113, 1),
                                  padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  textStyle:
                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            child: Image.asset('assets/imgs/grow2.png'),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle3')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc3')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            child: Image.asset('assets/imgs/why.png'),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            color: Colors.orangeAccent,
                            child: Center(
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsText3')),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle4')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc4')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            child: Image.asset('assets/imgs/pc.png'),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle5')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc5')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Center(
                              child: _controller.value.isInitialized
                                  ? AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                    child: VideoPlayer(_controller)),
                              )
                                  : Container(),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 250,
                            color: Colors.orangeAccent,
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsText4')),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsText5')),
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin:EdgeInsets.only(left: 10, right: 10),
                                child: Card(
                                  elevation: 10,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle6')),
                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc6')),
                                          style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                margin:EdgeInsets.only(left: 10, right: 10),
                                child: Card(
                                  elevation: 10,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle7')),
                                          style:   TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc7')),
                                          style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                margin:EdgeInsets.only(left: 10, right: 10),
                                child: Card(
                                  elevation: 10,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle8')),
                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc8')),
                                          style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsTitle9')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold, fontSize: 16 ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('aboutUsDesc9')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset('assets/imgs/markets.png'),
                          ),
                          SizedBox(height: 30,),
                        ],
                      ),
                    ),
                  ),
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
}
