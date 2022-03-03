import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_trianglify/flutter_trianglify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/chat.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'MediaView.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';

class Product extends StatefulWidget {

//  final Map<String, dynamic> productArg;
  String productArg;
  String primaryImage;

  Product(this.productArg, this.primaryImage);

  @override
  State<StatefulWidget> createState() {
    return _StateProduct();
  }
}

class _StateProduct extends State<Product> {
  Map<String, dynamic> localProductArgs;
  VideoPlayerController _controller;
  VideoPlayerController _dummyController;

  List<Map<String, dynamic>> fetchedAd = [];
  String productId;
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};

  bool isLoading = false;
  Map <String ,dynamic> companyInfo;
  List<String> imagesList = [];
  bool hasVideoFailed = false;

  String videoLink = "";
  String machineTitle = "";
  String machineDesc = "";
  String productOwnerId = "";
  String userId = "";
  bool carouselIndicator = false;
  FocusNode _emailFocus = FocusNode();
  String username;
  String email;
  TextEditingController messageController = TextEditingController();

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


  Future<void> fetchTokenPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token');
      username = prefs.getString('username');
      email = prefs.getString('email');
    });

    if(token == null){
      print("sssssdsdsdsdsdsdsdsdsd");

      Fluttertoast.showToast(
        msg: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('loginTranslate')),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white70,
        textColor: Colors.orange,
        fontSize: 16.0,
      );
    }



    print("llllllllllllllllllfffff" + email);
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

  Future<List<Map<String, dynamic>>> fetchCategories() async{
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];
    final response = await http.get(Uri.parse(webURL + 'api/ListCategory')).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        isLoading = false;
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
//              webURL + json.decodedecoded["result"][i]["productImage"])["1"].toString(),
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

  String valueAdjString(adjvalue){
    String val = "";
    for(int i = 0 ; i < adjvalue.length ; i++){
      val = "$val  ${adjvalue[i]}";
    }

    return val;
  }
  Future<void> fetchAdById(id) async {
    final queryParameters = {"id": id};

    final url = Uri.parse(webURL + "api/OneAds");
    final headers = {"Content-type": "application/json"};

    final response = await post(url, headers: headers, body: jsonEncode(queryParameters)).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        //        isLoading = false;
        //        _state = 0;
      });
      print(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'));
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

    print('VVVVVVVVVVVVVVVVVVVVVVVV Status code: ${response.statusCode}');

    String currentLocale =
        Localizations.of<AppLocalizations>(context, AppLocalizations)
            .locale
            .languageCode;

    var decoded = jsonDecode(response.body);

    if(decoded["status"]) {
      setState(() {
        imagesList.add(webURL + json.decode(decoded["description"]["video"])["1"].toString());
        videoLink = webURL + json.decode(decoded["description"]["video"])["1"].toString();
        _dummyController = VideoPlayerController.network(videoLink)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
        imagesList.add(webURL + json.decode(decoded["description"]["image1"])["1"].toString());
        imagesList.add(webURL + json.decode(decoded["description"]["image2"])["1"].toString());
        imagesList.add(webURL + json.decode(decoded["description"]["image3"])["1"].toString());
        imagesList.add(webURL + json.decode(decoded["description"]["primaryImage"])["1"].toString());
        imagesList.add(webURL + json.decode(decoded["description"]["productImage"])["1"].toString());

        machineTitle = decoded["description"]["title_$currentLocale"];
        machineDesc = decoded["description"]["description_$currentLocale"];
        productOwnerId = decoded["description"]["userID"];

        _controller = VideoPlayerController.network(imagesList[0])
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          }).timeout(const Duration(seconds: 10), onTimeout: () {
            setState(() {
              hasVideoFailed = true;
            });
            Fluttertoast.showToast(
                msg: "Can't load Video, Please try again! ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white70,
                textColor: Colors.black,
                fontSize: 16.0);

            throw TimeoutException(
                'The connection has timed out, Please try again!');
          });


        companyInfo = {
          "email": decoded["company"]["email"],
          "phone": decoded["company"]["phone"],
          "name": decoded["company"]["name"],
          "logo": webURL + json.decode(decoded["company"]["logo"])["1"].toString(),
        };
        print(currentLocale.toUpperCase() + "sssssss");

        decoded = decoded["adjactiveOneValue"];
        for(int i = 0; i < decoded.length ; i++) {
          if(currentLocale.toUpperCase() == "TR"){
            fetchedAd.add({
              "adj": decoded[i]["result"]["adjctive" + currentLocale.toUpperCase()],
              "adjvalue": decoded[i]["result"]["value"]
            });
          }else{
            fetchedAd.add({
              "adj": decoded[i]["result"]["adjactive" + currentLocale.toUpperCase()],
              "adjvalue": decoded[i]["result"]["value"]
            });
          }

        }

      });
    }
  }

  Future<void> fetchPrimaryImage(id) async {

    final queryParameters = {"id": id};

    final url = Uri.parse(webURL + "api/OneAds");
    final headers = {"Content-type": "application/json"};

    final response = await post(url, headers: headers, body: jsonEncode(queryParameters)).timeout(const Duration(seconds: 20), onTimeout:(){
      print(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'));
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

    String currentLocale =
        Localizations.of<AppLocalizations>(context, AppLocalizations)
            .locale
            .languageCode;

    var decoded = jsonDecode(response.body);
//    print("YYYYYYYYYYYYY " + decoded.toString());
    String primaryImage;
    if(decoded["status"]) {
      setState(() {
        primaryImage = webURL + json.decode(decoded["description"]["primaryImage"])["1"].toString();
      });
    }

    return primaryImage;
  }


  @override
  void initState() {
    fetchTokenPreference();
    super.initState();
    if (widget.productArg != null) {
      productId = widget.productArg;
    }
    print("zzzzzzz" + productId);

    fetchAdById(productId);
    fetchUserId();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _dummyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
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
//          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
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
            drawer: Drawers(),

            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: Container(
                    child:appbar(context,_advancedDrawerController)
                  ),
                ),
              // CHAT FAB
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              body: Container(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    // BOTTOM SECTION
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.25,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(bottom: 175),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(245, 245, 245, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            )),
                        // MAIN CONTENT
                        child: ListView(
                          children: [
                            Container(
                              child: CarouselSlider(
                                  options: CarouselOptions(
                                      height: 250,
                                      viewportFraction: 0.6,
                                      enlargeCenterPage: true,
                                      autoPlay: true,
                                      autoPlayCurve: Curves.linear
                                  ),
                                  items: imagesList.map((mediaItem) {
                                    return mediaItem == videoLink ?//productMediaItems[0] ?
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 32.0, left: 15,),
                                        child: Container(
                                          height: 200,
                                          child: _dummyController.value.isInitialized
                                              ? GestureDetector(
                                            onTap: () {
                                              final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                                              if (isPortrait) {
                                                setLandscape();
                                              }
                                              setState(() {
                                                _controller.seekTo(
                                                    Duration(seconds: 0)
                                                );
                                                _controller.play();
                                              });
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Center(
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Container(
                                                          height: MediaQuery.of(context).size.width * 0.8,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: Container(
                                                                  child: _controller.value.isInitialized
                                                                      ? GestureDetector(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                                                      });
                                                                    },
                                                                    child: AspectRatio(
                                                                      aspectRatio: _controller.value.aspectRatio,
                                                                      child: VideoPlayer(_controller),
                                                                    ),
                                                                  )
                                                                      : Container(
                                                                    margin: EdgeInsets.all(100),
                                                                    width: 30,
                                                                    child: CircularProgressIndicator(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).then((value) {
                                                _controller.pause();
                                                final isPortrait =
                                                    MediaQuery.of(context).orientation == Orientation.landscape;
                                                if (isPortrait) {
                                                  setPortrait();//////
                                                }
                                              });
                                            },
                                            child: Stack(
                                                children:[
                                                  Center(
                                                    child: AspectRatio(
                                                      aspectRatio:
                                                      _dummyController.value.aspectRatio,
                                                      child: VideoPlayer(_dummyController),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    top: 0,
                                                    child: Container(
                                                      margin: EdgeInsets.symmetric(vertical: 60),
                                                      child: Image.asset(
                                                        "assets/imgs/playbutton.png",
                                                      ),
                                                    ),
                                                  )
                                                ]
                                            ),
                                          )
                                              : Container(
                                            child: !hasVideoFailed ? Container(
                                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                                              width: 40.0,
                                              height: 40.0,
                                              child: Center(
                                                  child: CircularProgressIndicator()
                                              ),
                                            ) :
                                            Container(
                                              margin: EdgeInsets.only(left: 16.0),
                                              child: Center(
                                                child: Text(
                                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('failedToLoadVideo'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : Stack(
                                        children: [
                                          Positioned(
                                            child: Center(
                                              child: Container(
                                                height: 200,
                                                margin: EdgeInsets.only(
                                                    top: 32.0, left: 16.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: mediaItem,
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
                                        ]);
                                  }).toList()),
                            ),
                            SizedBox(height: 20,),
                            // DESCRIPTION TEXT
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.0),
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.14,
                              child: SingleChildScrollView(
                                child: ReadMoreText(
                                  machineDesc,
                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1)),
                                  trimLines: 3,
                                  colorClickableText: Colors.orange,
                                  trimMode: TrimMode.Line,
                                  moreStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                                  trimCollapsedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('more'),
                                  trimExpandedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('less'),//productTextItems[1],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // PRIMARY IMAGE
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.03,
                      right:
                      Localizations.localeOf(context).toString() == 'ar_SAR'
                          ? MediaQuery.of(context).size.width * 0.40
                          : 16,
                      left: Localizations.localeOf(context).toString() == 'ar_SAR'
                          ? 16
                          : MediaQuery.of(context).size.width * 0.40,
                      child: Container(
                        child: Column(
                          children: [
                          Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            //shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                widget.primaryImage,
                              ),
                            ),
                          ),
                        )
                          ],
                        ),
                      ),
                    ),
                    // TITLE
                    Positioned(
                      top: 16.0,
                      right:
                      Localizations.localeOf(context).toString() == 'ar_SAR'
                          ? 16
                          : MediaQuery.of(context).size.width * 0.60,
                      left: Localizations.localeOf(context).toString() == 'ar_SAR'
                          ? MediaQuery.of(context).size.width * 0.60
                          : 16,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Stack(
                          children: [
                            Container(
                              child: Text(
                                machineTitle,//localProductArgs["title"],
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
                            Positioned(
                              bottom: MediaQuery.of(context).size.height * 0.008,
                              child: Container(
                                width: 120,
                                height: 38,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.email, color: Colors.white, size: 20,),
                                  label:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('iletişim')),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('iletişim')),
                                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16, fontWeight: FontWeight.bold)
                                            ),
                                            content:  Container(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      // USERNAME TEXT FIELD
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                              SizedBox(width: 8,),
                                                              Container(
                                                                child:
                                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('usernameHint')),
                                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                              ),

                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                              width: double.infinity,
                                                              child: TextField(
                                                                readOnly: true,
                                                                minLines: 1,
                                                                maxLines: 3,
                                                                style: TextStyle(color: Colors.black),
                                                                decoration: new InputDecoration(
                                                                  hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                                  hintText: username == null? 'Osmanbaba' : username,
                                                                  focusColor: Colors.orange,
                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                                  border:  OutlineInputBorder(
                                                                    borderSide:  BorderSide(color: Colors.orange),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      // EMAIL TEXT FIELD
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                              SizedBox(width: 8,),
                                                              Container(
                                                                child:
                                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerEmailField')),
                                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                              ),

                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                              width: double.infinity,
                                                              child: TextField(
                                                                readOnly: true,
                                                                focusNode: _emailFocus,
                                                                minLines: 1,
                                                                maxLines: 3,
                                                                style: TextStyle(color: Colors.black),
                                                                decoration: new InputDecoration(
                                                                  hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                                  hintText: email == null? 'OsmanBaba@gmail.com' : email,
                                                                  focusColor: Colors.orange,
                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                                  border:  OutlineInputBorder(
                                                                    borderSide:  BorderSide(color: Colors.orange),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                      // SUBJECT TEXT FIELD
                                                      Column(
                                                        children: [
                                                          SizedBox(height: 10,),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                              SizedBox(width: 8,),
                                                              Container(
                                                                child:
                                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('konu')),
                                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                              width: double.infinity,
                                                              child: TextField(
                                                                readOnly: true,
                                                                minLines: 1,
                                                                maxLines: 3,
                                                                style: TextStyle(color: Colors.black),
                                                                decoration: new InputDecoration(
                                                                  hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                                  hintText: machineTitle,
                                                                  focusColor: Colors.orange,
                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                                  border:  OutlineInputBorder(
                                                                    borderSide:  BorderSide(color: Colors.orange),
                                                                  ),
                                                                ),
                                                              )
                                                          ),

                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      // MESSAGE TEXT FIELD
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                              SizedBox(width: 8,),
                                                              Container(
                                                                child:
                                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('theMessege')),
                                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                              width: double.infinity,
                                                              child: TextField(
                                                                controller: messageController,
                                                                readOnly: false,
                                                                minLines: 1,
                                                                maxLines: 3,
                                                                style: TextStyle(color: Colors.black),
                                                                decoration: new InputDecoration(
                                                                  hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                                  hintText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mesajHint')),
                                                                  focusColor: Colors.orange,
                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                                  border:  OutlineInputBorder(
                                                                    borderSide:  BorderSide(color: Colors.orange),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                            actions: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                                    child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async{
                                                      await sendEmailToSeller();
                                                      Navigator.pop(context, 'OK');
                                                    },
                                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('send')),),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.orange,
                                      padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      textStyle:
                                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // alt bottoms
                    Positioned(
                      bottom: 20,
                      child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 45,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.info, color: Colors.white, size: 20,),
                              label: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('productDetails')),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: (){
                                showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    builder: (context) {
                                            return Column(
                                              children: [
                                                SizedBox(height: 20,),
                                                Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                alignment: Alignment.center,
                                                                child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('productDetails')),
                                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(left: 10 , right: 10 ),
                                                                alignment: Alignment.centerRight,
                                                                child: GestureDetector(
                                                                    onTap: (){
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Icon(Icons.cancel, color: Colors.orange, size: 20,)
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                          SizedBox(height: 15,),
                                                          fetchedAd.length != 0 ?
                                                          Container(
                                                            height: MediaQuery.of(context).size.height * 0.4,
                                                            child: ListView.builder(
                                                                itemCount: fetchedAd.length,
                                                                itemBuilder: (context, index) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                      fetchedAd[index]["adj"] == null ? Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('nodetail'): fetchedAd[index]["adj"],
                                                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold,),
                                                                    ),
                                                                      trailing: Text(
                                                                    fetchedAd[index]["adjvalue"].length == 0 &&  fetchedAd[index]["adj"] != null ? Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('noVal')
                                                                        : valueAdjString(fetchedAd[index]["adjvalue"]),
                                                                      style: TextStyle(
                                                                          color: Color.fromRGBO(46, 96, 113, 1),
                                                                          fontSize: 14
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                            ),
                                                          ) : Container(
                                                            child: Text (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('nodetail'),
                                                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold,),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                    ]
                                            );


                                    });
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 45,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.business, color: Colors.white, size: 20,),
                              label: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyDetails')),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: (){
                                showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    builder: (context) {
                                            return Column(
                                              children: [
                                                SizedBox(height: 20,),
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          alignment: Alignment.center,
                                                          child: Text( (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyDetails')),
                                                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 10 , right: 10 ),
                                                          alignment: Alignment.centerRight,
                                                          child: GestureDetector(
                                                              onTap: (){
                                                                Navigator.pop(context);
                                                              },
                                                              child: Icon(Icons.cancel, color: Colors.orange, size: 20,)
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Container(
                                                      height: MediaQuery.of(context).size.height * 0.4,
                                                      child: ListView(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('name')),
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontWeight: FontWeight.bold, fontSize: 14
                                                              ),
                                                            ),
                                                            trailing: Text(companyInfo["name"] == null ? "null" :companyInfo["name"],
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontSize: 14
                                                              ),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            title: Text(
                                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerPhoneNumberField')),
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontWeight: FontWeight.bold, fontSize: 14
                                                              ),
                                                            ),
                                                            trailing: Text(companyInfo["phone"] == null ? "null" :companyInfo["phone"],
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontSize: 14
                                                              ),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            title: Text(
                                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmailField')),
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontWeight: FontWeight.bold, fontSize: 14
                                                              ),
                                                            ),
                                                            trailing: Text(companyInfo["email"] == null ? "null" :companyInfo["email"],
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontSize: 14
                                                              ),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            title: Text(
                                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('logo')),
                                                              style: TextStyle(
                                                                  color: Color.fromRGBO(46, 96, 113, 1),
                                                                  fontWeight: FontWeight.bold, fontSize: 14
                                                              ),
                                                            ),
                                                            trailing: companyInfo["logo"] == webURL + "null" ? Container(
                                                              child: Image.asset('assets/imgs/error/imageLoadFailure.png'),
                                                            ) :Image.network(companyInfo["logo"]),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              ],
                                            );


                                    });
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                    )
                  ],
                ),
              )
            )

        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Future<void> sendEmailToSeller() async {
    final queryParameters = {
      "Title": machineTitle,
      "Message": messageController.text,
      "ADID": productId,
      "ReciverID": productOwnerId,
      "SenderID": userId,
    };

    print("QQqqqwerty ${queryParameters}");
    print("QQqqqwerty ${token}");

    final url = Uri.parse(webURL + "api/AddEmail");
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token",
    };


    final response = await post(url, headers: headers, body: jsonEncode(queryParameters)).timeout(const Duration(seconds: 20), onTimeout:(){
      setState(() {
        //        isLoading = false;
        //        _state = 0;
      });
      print(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ToastConnectionTimeout'));
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

    print(response.statusCode);
    print(response.body);



  }

  Future<void> fetchUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("id");
  }

  Future setPortrait() async => await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Future setLandscape() async => await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  Future setPortraitAndLandscape() =>
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  Future<bool> _onBackPressed() async {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isPortrait) {
      setPortrait();
    }
    return true;
  }

}