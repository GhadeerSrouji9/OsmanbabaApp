import 'dart:async';
import 'dart:convert';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/product.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:osmanbaba/pages/chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Packages.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'package:http/http.dart' as http;

import 'categories.dart';
import 'chat.dart';
import 'company.dart';
import 'eSignature.dart';

class SearchResult extends StatefulWidget {
  final List<Map<String, dynamic>> bannerArgs;
  final List<Map<String, dynamic>> searchAds;
  final List<Map<String, dynamic>> adsListArgs;

//  final List<Map<String, dynamic>> searchBanners;

  SearchResult(this.bannerArgs, this.searchAds, this.adsListArgs);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  PanelController _panelController = PanelController();
  List<Map<String, dynamic>> bannerImages = []; //[Image.asset(assetsURL + '01_banner_osmanbaba.png', fit: BoxFit.fill)];
  List<Map<String, dynamic>> searchAds = [];
  List<Map<String, dynamic>> adsList = [];
  List<Map<String, dynamic>> packages = [];
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> specialAds = [];
  Map<String, dynamic> selectedAd;
  bool isLoading = false;
  List<bool> isAvatarError = [];

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

  Future<void> fetchListSpecialAds() async {
    final response = await http.get(Uri.parse(webURL + 'api/ListSpicalAds'));
    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      setState(() {
        for(int i = 0; i < decoded["description"].length; i++) {

          specialAds.add(
              {
                "image":  webURL + json.decode(decoded["description"][i]["image"])["1"],
                "id":  decoded["description"][i]["id"],
                "link":  decoded["description"][i]["link"],
              }
          );
        }

      });
    } else {
      throw Exception('Failed to load');
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

  Future<void> fetchAdById(id) async {
    // print("111oooooooooooooooooo " + await FirebaseMessaging.instance.getToken());
    print("sllllllllllllllllllll");

    //String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;
    // String currentLocale = globalLocale.countryCode;
    //
    print("sllllllllllllllllllll444");
    //print("sllllllllllllllllllll12 ${currentLocale}");

    var head = {
      //"lang": globalLocale.toString().substring(0, 2),
      "Accept": "application/json",
      "content-type":"application/json"
    };
    final response = await http.post(Uri.parse(webURL + "api/OneAds"), headers: head, body: jsonEncode(
      {
        "id": id
      },
    )
    );
    var decoded = jsonDecode(response.body);

    print("ggggggggggg ${decoded}");
    if (decoded["status"]) {
      setState(() {
        selectedAd =
        {
          "id": decoded["description"]["id"],
          "title": decoded["description"]["title_" + globalLocale.toString().substring(0, 2)],
          "description": decoded["description"]["description_" + globalLocale.toString().substring(0, 2)],
         // "adjactiveOneValue": decoded["description"]["adjactiveOneValue" ],
          "productImage": webURL + json.decode(decoded["description"]["productImage"])["1"].toString(),
          "primaryImage": webURL + json.decode(decoded["description"]["primaryImage"])["1"].toString(),
          "image1": webURL + json.decode(decoded["description"]["image1"])["1"].toString(),
          "image2": webURL + json.decode(decoded["description"]["image2"])["1"].toString(),
          "image3": webURL + json.decode(decoded["description"]["image3"])["1"].toString(),
          //"logo": logo,
          // "logo": webURL + json.decode(decoded["description"][i]["userName"]["imageProfile"])["1"].toString(),
//                "logo": webURL + json.decode(decoded["description"][i]["applicationUser"]["logo"])["1"].toString() == null ?
//                "https://osmanbaba.appinfinitytouch.net/Files/NewsImage/ed12c4d0-c65a-4fd2-b0cb-0555251ff9c7/ed12c4d0-c65a-4fd2-b0cb-0555251ff9c7.jpg":
//                "https://osmanbaba.appinfinitytouch.net/Files/NewsImage/ed12c4d0-c65a-4fd2-b0cb-0555251ff9c7/ed12c4d0-c65a-4fd2-b0cb-0555251ff9c7.jpg",
          "video": webURL + json.decode(decoded["description"]["video"])["1"].toString(),

//                "length": decoded["description"][i]["length"],

        };
        print("11111111ZZZZZZZZZ");
      });
    } else {
      throw Exception('Failed to load');
    }
  }


  @override
  void initState() {
    fetchListSpecialAds();
    for(int i = 0; i<globaladsList.length; i++){
      isAvatarError.add(false);
    }
    
    print("//////////////////////////////////////search results///////////////////");
    if(widget.bannerArgs != null) {
      bannerImages = widget.bannerArgs;
     // print("......... " + bannerImages.toString());
    }
    if(widget.searchAds != null) {
      print("yyyyyyyyy" + widget.searchAds.toString());
      searchAds = widget.searchAds;
    }
    if(widget.adsListArgs != null) {
      adsList = widget.adsListArgs;
    }
  }
  void togglePanel() => _panelController.isPanelOpen ? _panelController.close() : _panelController.open();
  @override
  Widget build(BuildContext context)  {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.enter)){
          print("Enter");
          Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new SearchResult(bannerImages, searchAds, adsList)));
        }

      },
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
          //Adding SpinCircleBottomBarHolder to body of Scaffold
          body: Container(
            height: MediaQuery.of(context).size.height,
            // color: Colors.red,
            child: Stack(
              children: [
                Container(

//            color: Colors.orangeAccent.withAlpha(55),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 150,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayAnimationDuration: Duration(milliseconds: 2000),
                                pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                              ),
                              items: bannerImages.map((bannerItem) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
//                                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                        child: CachedNetworkImage(
                                          imageUrl: bannerItem["image"],
                                          fit: BoxFit.fill,
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
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          ],
                        ),
                        Divider(),
                        CarouselSlider(
                          options: CarouselOptions(
                              height:200,
                              viewportFraction: 0.75,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(milliseconds: 3000),
//                              autoPlayAnimationDuration: Duration(seconds: 3),
                              autoPlayCurve: Curves.linear
                          ),
                          items: specialAds.map((adItem) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: InkWell(
                                    onTap: (){
                                      if (!isLoading) {
                                        launch(adItem["link"]);
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
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            // AD PRIMARY IMAGE
                                            Positioned(
                                              child: Container(
                                                height: 150,
                                                width: MediaQuery.of(context).size.width,
//                                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Hero(
                                                  tag: "tranz",
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(20),
                                                    child: CachedNetworkImage(
                                                      imageUrl:  adItem["image"],
                                                      height: 150,
                                                      //fit: BoxFit.scaleDown,
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
                                                ),
                                              ),
                                            ),
                                            // AD LOGO
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                              height: 265,
                              viewportFraction: 0.3,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(milliseconds: 3000),
//                              autoPlayAnimationDuration: Duration(seconds: 3),
                              autoPlayCurve: Curves.linear
                          ),
                          items: globaladsList.map((adItem) {
                            print("aaaaaaaaaaaa " + adItem.toString());
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: InkWell(
                                    onTap: () async{
                                      if (!isLoading) {
//                                    print("zzzzzzzzz" + adItem["userName"].toString());
                                     await fetchAdById(adItem["id"]);
                                        Navigator.push(
                                            this.context,
                                            new MaterialPageRoute(builder: (context) => new Product(adItem["id"], adItem["primaryImage"]))
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
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            // AD PRIMARY IMAGE
                                            Positioned(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                                    border: Border.all(width: 1.5, color: Colors.orange)
                                                ),
                                                height: 150,
                                                width: 150,
//                                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Hero(
                                                  tag: "tranz",
                                                  child: CachedNetworkImage(
                                                    imageUrl: adItem["primaryImage"],
                                                    fit: BoxFit.scaleDown,
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
                                              ),
                                            ),
                                            // AD LOGO
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 60.0,
                                                height: 60.0,
//                                            decoration: BoxDecoration(
//                                                shape: BoxShape.circle,
//                                                image: DecorationImage(
//                                                    image: NetworkImage(adItem["logo"]),
//                                                    fit: BoxFit.fill
//                                                )
//                                            ),
                                              ),
                                            ),
                                            // AD PRODUCT
                                            Positioned(
                                              bottom: 5,
                                              left: 5,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(adItem["productImage"]),
                                                        fit: BoxFit.fill
                                                    )
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        // AD TITLE
//                                             Container(
//                                               width: MediaQuery.of(context).size.width * 0.75,
//                                               decoration: BoxDecoration(
//                                                 color: Color.fromRGBO(72, 122, 112, 1),
//                                                 borderRadius: BorderRadius.circular(5,),
//                                               ),
//                                               margin: EdgeInsets.only(top: 8.0),
//                                               padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
//                                               child: Text(
//                                                 adItem["title"].length < 29 ? adItem["title"] : adItem["title"].substring(0, 29) + "...",
// //                                        "ABCDEFGHIJABCDEFGHIJ",
//                                                 textAlign: TextAlign.center,
//                                                 softWrap: true,
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//
//                                             )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        SingleChildScrollView(
                          child:  Container(
                            height: (adsList.length * 60 + 120.0),
                            child: GridView.count(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 7.5 / 10,
                                crossAxisCount: 3,
                                // Generate 100 widgets that display their index in the List.
                                children: List.generate(globalsearchAds.length, (index) {
                                  return InkWell(
                                    onTap: () async{
                                      if(!isLoading) {
                                        await fetchAdById(globalsearchAds[index]["id"]);
                                        Navigator.push(
                                            this.context,
                                            new MaterialPageRoute(builder: (context) => new Product(globalsearchAds[index]["id"], globalsearchAds[index]["primaryImage"]))
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastWaitWhileLoading'),
                                            //                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white70,
                                            textColor: Colors.black,
                                            fontSize: 16.0
                                        );
                                      }
                                    },
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Card(
                                          margin: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
                                          color: Colors.white,
                                          elevation: 5,
                                          child: Container(
                                            //padding: EdgeInsets.all(16.0),
                                            //margin: EdgeInsets.only(bottom: 24.0),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  child: Image.network(adsList[index]["primaryImage"],fit: BoxFit.fill, height: 200, width: 200,).blurred(
                                                    colorOpacity: 0.5,
                                                    blur: 2,
                                                    overlay: Container(
                                                      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 2.0, right: 2.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: adsList[index]["primaryImage"],
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
                                                  ),
                                                ),
                                                // Primary
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.33,
                                                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 2.0, right: 2.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: globalsearchAds[index]["primaryImage"],
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
//
                                                // TITLE
                                         Positioned(
                                           width: MediaQuery.of(context).size.width * 0.3, bottom: 0,
                                           child: Container(
                                             color: Colors.white,
                                             padding: EdgeInsets.symmetric(vertical: 8.0),
                                             child: Text(
                                               globalsearchAds[index]["title"].length < 14 ? globalsearchAds[index]["title"]:
                                               globalsearchAds[index]["title"].substring(0, 14) + "..",
                                               textAlign: TextAlign.center,
                                               softWrap: true,
                                               style: TextStyle(
                                                 color: Colors.orange, fontWeight: FontWeight.bold,
                                                 fontSize: Localizations.localeOf(context).toString() == 'ar_SAR' ?
                                                 11 : 11,
                                               ),
                                             ),
                                           ),
                                         )
                                              ],
                                            ),
                                          ),
                                        ),
                                        //LOGO
                                        Container(
                                          padding: EdgeInsets.only(left: 20, right: 20),
                                          child: CircleAvatar(
                                              radius: 20.0,
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(globalsearchAds[index]["logo"],),
                                              onBackgroundImageError: (_, __){
                                                setState(() {
                                                  isAvatarError[index] = true ;
                                                });
                                              },
                                              child:
                                              !isAvatarError[index] ?
                                              Container(
                                                  height: 0,
                                                  width: 0,
                                                  color: Colors.orange
                                              ): Image.asset("assets/imgs/error/imageLoadFailure.png")
                                          ),
                                        ),
                                      ],
                                    ),
                                  );                                }
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 170,
                    width: MediaQuery.of(context).size.width,
                    child: SpinCircleBottomBarHolder(
                      bottomNavigationBar: SCBottomBarDetails(
                          circleColors: [Colors.white, Colors.orange, Colors.orangeAccent],
                          iconTheme: IconThemeData(color: Colors.orange, size: 18),
                          activeIconTheme: IconThemeData(color: Colors.orangeAccent, size: 18),
                          backgroundColor: Colors.white,
                          titleStyle: TextStyle(color: Colors.orange,fontSize: 12),
                          activeTitleStyle: TextStyle(color: Colors.orangeAccent,fontSize: 12,fontWeight: FontWeight.bold),
                          actionButtonDetails: SCActionButtonDetails(
                              color: Colors.orange,
                              icon: Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.white,
                              ),
                              elevation: 2),
                          elevation: 2.0,
                          items: [
                            // Suggested count : 4
                            SCBottomBarItem(icon: Icons.arrow_back, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('back')), onPressed: () {
                              Navigator.pop(context);
                            }),
                            SCBottomBarItem(icon: Icons.login, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('login')), onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(builder: (context) => new Login()));
                            }),
                            SCBottomBarItem(icon: FontAwesomeIcons.percent, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('paketler')),
                                onPressed: () async {
                                  await fetchPackages();
                                  print("hhjmhj" + packages.toString());
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(builder: (context) => new Packages(packages)));
                                }),
                            SCBottomBarItem(icon: Icons.chat, title:(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mesaj')),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(builder: (context) => new Chat()));
                                }),
                          ],
                          circleItems: [
                            //Suggested Count: 3
                            SCItem(icon: Icon(Icons.add), onPressed: () {}),
                            SCItem(icon: Icon(Icons.print), onPressed: () {}),
                            SCItem(icon: Icon(Icons.map), onPressed: () {}),
                          ],
                          bnbHeight: 75 // Suggested Height 80
                      ),
                      child: Container(
                        width: 109,
                        height: 200,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
          drawer: Drawers(),
        ),

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}