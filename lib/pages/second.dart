import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/Widgets/ads.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/pages/auth/Login.dart';
import 'package:osmanbaba/pages/chat.dart';
import 'package:osmanbaba/pages/eSignature.dart';
import 'package:osmanbaba/pages/help.dart';
import 'package:osmanbaba/pages/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import '../main.dart';
import 'Packages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../helpers/app_localization.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/helpers/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blur/blur.dart';
import 'news_source.dart';

class Second extends StatefulWidget {
  final Map<String, dynamic> loginArgs;
  final List<Map<String, dynamic>>  adsListArgs;
  final bool backToOrigin;
  Second(this.loginArgs, this.adsListArgs, this.backToOrigin);
  final List<String> list = List.generate(10, (index) => 'Text $index');

  @override
  State<StatefulWidget> createState() {
    return _SecondState();
  }
}

class _SecondState extends State<Second> with SingleTickerProviderStateMixin {
  static final String assetsURL = 'assets/imgs/';
  final _advancedDrawerController = AdvancedDrawerController();
  final tfSearchController = TextEditingController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  CarouselController buttonCarouselController = CarouselController();
  String singleBanner = "https://OsmanBaba.appinfinitytouch.net/Files/BannersImage/3a5f64d6-a59b-41a9-a054-f75f222b1496/3a5f64d6-a59b-41a9-a054-f75f222b1496.pngr";
  double statefulValue = 0;
  int _state = 0;
  int _fabState = 0;
  int clickedNewsIndex = -1;
  int visitorsTotal;
  bool isLoading = false;
  bool areStoriesFetching = true;
  bool isNewsOpening = false;
  bool isNewsLoading = true;
  bool callInit = true;
  bool isVisitorsNumLoading = true;
  String dropdownValue = 'General';
  String _token;
  String fullNewsString = "";
  List<Image> flagImages = [Image.asset('icons/flags/png/gb.png', package: 'country_icons'), Image.asset('assets/imgs/sy.jpg'), Image.asset('assets/imgs/tr.jpg')];
  List<String> options = <String>['General', 'Product', 'Services'];
  List<Map<String, dynamic>> newsStrings = [];
  List<String> storyImages = [webURL + "Files/BannersImage/e3298d62-baad-4c93-9089-9a646d3b7f75/e3298d62-baad-4c93-9089-9a646d3b7f75_2.png"];
  List<String> storyIds = [];
  List<Map<String, dynamic>> storyIdImage = [];
  List<Map<String, dynamic>> bannerImages = []; //[Image.asset(assetsURL + '01_banner_osmanbaba.png', fit: BoxFit.fill)];
  List<Map<String, dynamic>> adsList = [];
  List<Map<String, dynamic>> specialAds = [];
  List<Map<String, dynamic>> top4ads = [];
  List<Map<String, dynamic>> languageList = [];
  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> searchAds = [];
  List<bool> isAvatarError = [];
  bool isLoggedIn = false;
  Map<String, dynamic> localLoginArgs;
  Map<String, dynamic> selectedAd;


  Future<void> fetchBanners() async {
    final response = await http.get(Uri.parse(webURL + 'api/ListBanner'));
    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      setState(() {
        for(int i = 0; i < decoded["description"].length; i++) {
          String selectedUrl;
          if(currentLocale == "tr") {
            selectedUrl = webURL + json.decode(decoded["description"][i]["image"])["1"];
          } else {
            selectedUrl = webURL + json.decode(decoded["description"][i]["image_" + currentLocale])["1"];
          }
          bannerImages.add(
              {
                "image": selectedUrl,
              }
          );
        }
        var _random = new Random();
        var _randomAdIndex = _random.nextInt(bannerImages.length - 1);
        singleBanner = bannerImages[_randomAdIndex]["image"];
      });
    } else {
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


  Future<void> fetchBannersSearch() async{
    final response = await http.get(Uri.parse(webURL + 'api/ListBannerSearch'));

    var decoded = jsonDecode(response.body);

    if (decoded["status"]) {
      setState(() {
        for(int i = 0; i < decoded["description"].length; i++) {
          String selectedUrl;
          if(currentLocale == "tr") {
            selectedUrl = webURL + json.decode(decoded["description"][i]["image"])["1"];
          } else {
            selectedUrl = webURL+ json.decode(decoded["description"][i]["image_" + currentLocale])["1"];
          }
          globalbannerImages.add(
              {
                "image": selectedUrl,
              }
          );
        }

      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  }

  fetchLoginPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      if(token!=null){
        isToken =true;
      }
    });
  }

  Future<void> fetchStories() async{
    final response = await http.get(Uri.parse(webURL + 'api/ListStory'));
    List<String> storiesUrls = [];
    List<Map> mappedImageStrings = [];

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      storyImages = [];

      setState(() {
        for(int i = 0; i < decoded["description"].length; i++){
          storiesUrls.add(decoded["description"][i]["image"]);
          mappedImageStrings.add(json.decode(storiesUrls[i]));

          storyImages.add(webURL + mappedImageStrings[i]["1"]);
          storyIds.add(decoded["description"][i]["id"]);

          storyIdImage.add(
              {
                "id": storyIds[i],
                "image": storyImages[i]
              }
          );
//          bannerImageList.add(Image.network(webURL + mappedImageStrings[i]["1"]));
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }

    setState(() {
      areStoriesFetching = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchNewsByStory(story) async {
    List<Map<String, dynamic>> newsList = [];
    final queryParameters = {"id": story["id"]};
    final url = Uri.parse(webURL + "api/ListBySourceID");
    final headers = {
      "Content-type": "application/json",
      "lang": Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode.toString(),
    };

    final response = await post(url, headers: headers, body: jsonEncode(queryParameters)).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        isLoading = false;
        _state = 0;
      });
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      throw TimeoutException('The connection has timed out, Please try again!');
    });
    var decoded = jsonDecode(response.body);

    if(decoded["status"]) {
      decoded = decoded["description"];
      setState(() {
        for(int i = 0; i < decoded.length; i++) {
          newsList.add(
              {
                "id": decoded[i]["id"],
                "title": decoded[i]["title"],
                "name": decoded[i]["storyName" ],
                "description": decoded[i]["desc"],
                "image": webURL + json.decode(decoded[i]["image"])["1"].toString(),
                "storyImage": webURL + json.decode(decoded[i]["storyImage"])["1"].toString(),
              });
        }
      });
    }
    return newsList;
  }

  Future<void> fetchAdsList() async {

    var head = {
      "content-type":"application/json",
      "lang":  currentLocale,
    };
    final response = await http.get(Uri.parse(webURL + "api/ListAds"), headers: head);
    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      setState(() {
        adsList = [];
        for(int i = 0; i < decoded["description"].length; i++){
          String logo = webURL + json.decode(decoded["description"][i]["userName"]["imageProfile"])["1"].toString();
          if(logo == null){
            logo = "" ;
          }
          adsList.add(
              {
                "id": decoded["description"][i]["id"],
                "title": decoded["description"][i]["title"],
                "description": decoded["description"][i]["desc"],
                "productImage": webURL + json.decode(decoded["description"][i]["product"])["1"].toString(),
                "primaryImage": webURL + json.decode(decoded["description"][i]["image"])["1"].toString(),
                "logo": logo,
              }
          );
          isAvatarError.add(false);
          globaladsList.add(
              {
                "id": decoded["description"][i]["id"],
                "title": decoded["description"][i]["title"],
                "description": decoded["description"][i]["desc"],
                "productImage": webURL + json.decode(decoded["description"][i]["product"])["1"].toString(),
                "primaryImage": webURL + json.decode(decoded["description"][i]["image"])["1"].toString(),
                "logo": webURL + json.decode(decoded["description"][i]["userName"]["imageProfile"])["1"].toString(),
              }
          );
        }

        if(adsList.length <= 4) {
          print("lesss than fooooouuuuu ${adsList.length}");
          top4ads = adsList;
        }
        else {
          print("mmooreee thannn  444444");
          while(top4ads.length < 4) {
            var _random = new Random();
            var _randomAdIndex = _random.nextInt(adsList.length - 1);
            if(!top4ads.contains(adsList[_randomAdIndex])) {
              top4ads.add(adsList[_randomAdIndex]);
            }
          }
        }

        print("Made it this farrr");

      });
    } else {
      throw Exception('Failed to load');
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
                "addtionalPrice": decoded[i]["addtionalPrice"],
                "priceYear": decoded[i]["priceYear"],
                "price6Month": decoded[i]["price6Month"],
                "used": decoded[i]["used"],
                "active": decoded[i]["active"],
              }
          );
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }

  }

  Future<void> sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
    } catch (e) {
    }
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {

          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
        }
        break;
      case 'unsubscribe':
        {
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {

          } else {

          }
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    fetchLoginPreference();
    fetchListSpecialAds();

    if(widget.loginArgs != null) {
      localLoginArgs = widget.loginArgs;
      isLoggedIn = localLoginArgs['isLoggedIn'];
    }
    fetchBanners();

    fetchAdsList();

    fetchStories();

    fetchBannersSearch();

    super.initState();



    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {

    });


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: '@mipmap/ic_launcher',
              ),
            )
        );
      }
    });

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    tfSearchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    int bannerCounter = 0;

    Radius leftSideRadius = new Radius.circular(30.0);
    Radius rightSideRadius = new Radius.circular(0.0);

    double leftBorder = 1.0;
    double rightBorder = 0.0;

    Color rightBorderColor = Colors.transparent;
    Color leftBorderColor = Colors.black;

    if (Localizations.localeOf(context).toString() == 'ar_SAR') {
      leftSideRadius = new Radius.circular(0.0);
      rightSideRadius = new Radius.circular(30.0);

      rightBorderColor = Colors.black;
      leftBorderColor = Colors.transparent;

      leftBorder = 0;
      rightBorder = 1;
    }


    return WillPopScope(
      onWillPop: _onBackPressed,
      child: RefreshIndicator(
        onRefresh: (){
          return Future.delayed(
              Duration(seconds: 0), () async{

            await fetchBanners();

            await fetchStories();

            await fetchAdsList();

//              Phoenix.rebirth(this.context);
          }
          );
        },
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },

          child: RawKeyboardListener(
            autofocus: true,
            focusNode: FocusNode(),
            child: MaterialApp (
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

                child: Scaffold (
                  appBar:PreferredSize(
                    preferredSize: Size.fromHeight(70.0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: appbar(context,_advancedDrawerController),
                    ),
                  ),
                  body: Container(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // UPPER BANNER CAROUSEL
                              Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 150,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      autoPlayAnimationDuration: Duration(milliseconds: 3000),
                                      pauseAutoPlayOnManualNavigate: false,
//                                  autoPlayCurve: Curves.slowMiddle
                                    ),
                                    carouselController: buttonCarouselController,
                                    items: bannerImages.map((bannerItem) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            child: Stack(
                                              children: [
                                                // BANNER IMAGE
                                                Positioned(
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
//                                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: CachedNetworkImage(
                                                    imageUrl: bannerItem["image"] ,
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
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),

                              Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                                  margin: EdgeInsets.fromLTRB(0, 0.0, 0, 8.0),
                                  height: 60.0,
                                  child: CarouselSlider(
                                      options: CarouselOptions(
                                          height: 150,
                                          viewportFraction: 0.175,
                                          enlargeCenterPage: false,
                                          autoPlay: true,
                                          pauseAutoPlayOnManualNavigate: false,
                                          autoPlayInterval: Duration(milliseconds: 3000),
                                          autoPlayCurve: Curves.linear
                                      ),
                                      items: storyIdImage.map((story) {
                                        return GestureDetector(
                                          onTap: () async {
                                            if(!areStoriesFetching) {
                                              setState(() {
                                                isNewsOpening = true;
                                                statefulValue = 55.0;
                                              });
                                              List<Map<String, dynamic>> news = await fetchNewsByStory(story);
                                              isNewsOpening = false;
                                              clickedNewsIndex = -1;
                                              if(news.isEmpty) {
                                                Fluttertoast.showToast(
                                                    msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastNoNews'),
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.white70,
                                                    textColor: Colors.black,
                                                    fontSize: 16.0);
                                              }
                                              else {
                                                Navigator.push(
                                                    this.context,
                                                    new MaterialPageRoute(builder: (context) => new NewsSource(news))
                                                );
                                              }
                                            }
                                            else {
                                              Fluttertoast.showToast(
                                                  msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastStoriesLoading'),
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
                                              children:[
                                                Positioned(
                                                  child: Container(
                                                    decoration: BoxDecoration(),
                                                    height: 60,
                                                    width: 60,
                                                    child: AvatarGlow(
//                                                endRadius: clickedNewsIndex == index? 55.0 : 0.0,
                                                      endRadius: 0.0,
                                                      glowColor: Colors.orange,
                                                      showTwoGlows: false,
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                                                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                        child: CachedNetworkImage(
                                                          imageUrl: story["image"],
                                                          width: 55,
                                                          height: 55,
                                                          fit: BoxFit.fill,
                                                         placeholder: (context, url) => Center(
                                                           child: Container(
                                                             width: 30,
                                                             height: 30,
                                                             child: CircularProgressIndicator(),
                                                           ),
                                                         ),
                                                          errorWidget: (context, url, error) {
                                                            return Center(
                                                              child: Container(
                                                                child: Image.asset(
                                                                  'assets/imgs/error/imageLoadFailure.png',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 0,
                                                  height: 0,
                                                ),
                                              ]
                                          ),
                                        );
                                      }).toList()
                                  )
//
                              ),
                              Divider(
                                color: Colors.transparent,
                              ),

                              // TOP 4 ADS
                              Container(
                                child: Column(
                                  children: [
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // AD 1
                                        top4ads.length > 0 ? ads(top4ads[0],isLoading, ):
                                        Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.50,
                                              height: 30,
                                            //child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        // AD 2
                                        top4ads.length > 1 ? ads(top4ads[1],isLoading):
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.50,
                                            height: 30,
                                           // child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // AD 3
                                        top4ads.length > 2 ? ads(top4ads[2], isLoading):
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.50,
                                            height: 30,
                                           // child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        // AD 4
                                        top4ads.length > 3 ? ads(top4ads[3], isLoading):
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.50,
                                            height: 30,
                                            //  child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),

                              // SINGLE BANNER
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: CachedNetworkImage(
                                    imageUrl: singleBanner,
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
                             Container(
                                    height: 500,
                                    //height: ((adsList.length / 3) * 150 + 120.0),
                                    child: GridView.count(
                                        shrinkWrap: false,
                                        mainAxisSpacing: 10.0,
                                        childAspectRatio: 7.5 / 10,
                                        crossAxisCount: 3,
                                        // Generate 100 widgets that display their index in the List.
                                        children:
                                        List.generate(
                                            adsList.length + 1, (index) {
                                          return index != adsList.length ? InkWell(
                                            onTap: () async{
                                             // await fetchAdById(adsList[index]["id"]);
                                              if(!isLoading) {
                                                Navigator.push(
                                                    this.context,
                                                    new MaterialPageRoute(builder: (context) => new Product(adsList[index]["id"], adsList[index]["primaryImage"]))//(selectedAd))
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
                                                        // Primary
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
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.33,
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(left: 20, right: 20),
                                                  child: CircleAvatar(
                                                    radius: 20.0,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: NetworkImage(adsList[index]["logo"],),
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
                                          ) : SizedBox();
                                        }
                                        )
                                    ),
                                  )
                            ],
                          ),
                        ),
                        // FOOTER

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
                                  titleStyle: TextStyle(color: Colors.orange,fontSize: 11),
                                  activeTitleStyle: TextStyle(color: Colors.orangeAccent,fontSize: 11,fontWeight: FontWeight.bold),
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
                                      exit(0);
                                    }),
                                    SCBottomBarItem(icon: Icons.border_color_outlined, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('eimza')),
                                        onPressed: () {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(builder: (context) => new Esignature()));
                                    }),
                                    SCBottomBarItem(icon: FontAwesomeIcons.percent, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('paketler')),
                                        onPressed: () async {
                                          await fetchPackages();
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
                drawer: Drawers()
              ),
              debugShowCheckedModeBanner: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 6.0),
        child: Image.asset(
          "assets/imgs/categories.png",
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

  Future<bool> _onBackPressed() async{
    if(widget.backToOrigin){
      return true;
    } else {
      return false;
    }
  }
}
// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}



