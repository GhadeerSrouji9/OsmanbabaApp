import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/second.dart';
import 'package:readmore/readmore.dart';
import 'dart:async';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';

import 'Packages.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'chat.dart';
import 'company.dart';
import 'eSignature.dart';

class Translate extends StatefulWidget {
  final List<Map<String, dynamic>> kindList;
  final List<Map<String, dynamic>> languageList;
  Translate(this.kindList, this.languageList);


  @override
  _TranslateState createState() => _TranslateState();
}
class _TranslateState extends State<Translate> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _adresController = TextEditingController();
  List <List<String>> dropdownNameItems=[];
  List<Map<String, dynamic>> kindList=[];
  List<String> fileType = [];
  List<bool> isNoterChecked = [false];
  List<bool> isOnayChecked = [false];
  bool issend = false;
  File myfile;
  List<File> _file = [];
  List<File> _file1 = [];
  List<File> _file2 = [];
  String path;
  String path1;
  List<TextEditingController> notController = [TextEditingController()];
  List<int> filePrices = [];
  List<int> noterPrice= [0];
  List<int> onayPrice= [0];
  List<int> sum= [];
  List<int> selectFileType= [0];
  int topSum;
  int topTrans;
  int topNoter = 0;
  int topOnay = 0;

  int addressRadio = 1;
  String sendType="0";
  String addressHint = "Bamyasuyu Mahallesi 128.Sok Mzc Yapı 24/9 Haliliye/Şanlıurfa/Türkiye";

  String token ;
  String username;
  String email;
  bool isAddressActive = true;

  int fileNum = 0 ;
  List <int> radioGroupValue1 =[-1];
  List <int> radioGroupValue2 = [-1];

  List<String> mesut = [] ;
  List<Map<String , dynamic>> langList = [];
  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> languageList = [];


  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  int fileNumber = 0;


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

  @override
  void initState() {
    _file.add(myfile);
    _file1.add(myfile);
    _file2.add(myfile);
    super.initState();
    kindList = widget.kindList;
    for(int i = 0; i<kindList.length; i++){
      mesut.add(kindList[i]["name"]);
    }
    dropdownNameItems.add(mesut);
    fileType.add(dropdownNameItems[0][0]) ;
    filePrices.add(kindList[0]["price"]);
    sum.add(kindList[0]["price"]);
    topSum = kindList[0]["price"];
    topTrans = kindList[0]["price"];
    langList = widget.languageList;
    print("rrrrrr " + langList.toString());

    fetchTokenPreference();
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

  Future<void> fetchDrop(fileNum) async {
    final url = Uri.parse(webURL + "api/AddTranslateFile");
    var request = http.MultipartRequest(
        'POST', url
    );
    request.headers['Content-type'] ='multipart/form-data';
    request.headers["Authorization"] = "Bearer ${token}";
    request.fields['SendType'] = addressRadio.toString();
    if(addressRadio == 0){
      request.fields['Address'] = _adresController.text;
    }

    request.fields['Email'] = email;
    request.fields['user'] = username;
    request.fields['phone'] = _phoneController.text;


    for(int i = 0; i <= fileNum; i++){
      print("666666" + radioGroupValue1[i].toString());
      print("666666" + langList[(radioGroupValue1[i] + 2 * i) % 3]["name"]);
      request.fields['fromLanguageID[$i]'] = langList[(radioGroupValue1[i] + 2 * i) % 3]["id"]; //"251e1834-a2b3-4a11-8f3e-452a90a63b82";
      request.fields['ToLanguageID[$i]'] =  langList[(radioGroupValue2[i] + 2 * i) % 3]["id"];
      request.fields['Note[$i]'] = notController[i].text;
      request.fields['Kind[$i]'] = kindList[selectFileType[i]]["id"];
      if(noterPrice[i] == 0){
        request.fields['ISNoter[$i]'] = "False";
      }else{
        request.fields['ISNoter[$i]'] = "True";
      }

      request.fields['IsVerfication[$i]'] = isOnayChecked[i].toString();

      if(selectFileType[i] == 0 || selectFileType[i] == 1  || selectFileType[i] == 6) {
        request.files.add(
          http.MultipartFile('file1',
              File(_file1[i].path).readAsBytes().asStream(),
              File(_file1[i].path).lengthSync(),
              filename: _file1[i].path.split("/").last),
        );
        request.files.add(
          http.MultipartFile('file',
              File(_file[i].path).readAsBytes().asStream(),
              File(_file[i].path).lengthSync(),
              filename: _file[i].path.split("/").last),
        );
      }else{
        print(_file[i].path + "qqqqqqq");
        request.files.add(
          http.MultipartFile('Certaficate',
              File(_file[i].path).readAsBytes().asStream(),
              File(_file[i].path).lengthSync(),
              filename: _file[i].path.split("/").last),
        );
      }
      request.files.add(
        http.MultipartFile(
            'PersonID',
            File(_file2[i].path).readAsBytes().asStream(),
            File(_file2[i].path).lengthSync(),
            filename: _file2[i].path.split("/").last),
      );
    }
    print(request.fields);
    print(request.files);

    try{
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      print("tryyy try try: " + res.body.toString());
      Map<String, dynamic> dep = jsonDecode(utf8.decode(res.bodyBytes));
      if(dep["message"] == "Seccess") {
        print("stonksssss");
      }
    }
    catch(error) {
      print("ccccatch errrrrrrrrrrrror " + error.toString());
    }
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
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

  Future<void> galeridenSec(index) async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file[index]=(File(image.path));
    });
    path = image.path;

  }

  Future<void> galeridenSec1(index) async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file1[index]=(File(image.path));
    });
    path1 = image.path;
  }

  Future<void> galeridenSec2(index) async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _file2[index]=(File(image.path));
    });
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
            body: Container(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 120),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('translate1')),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('translate2')),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(46, 96, 113, 1)),
                                ),
                                SizedBox(height: 10,),
                                ReadMoreText((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('translate3')),
                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1),),
                                  trimLines: 3,
                                  colorClickableText: Colors.orange,
                                  trimMode: TrimMode.Line,
                                  moreStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                                  trimCollapsedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('more'),
                                  trimExpandedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('less'),
                                )
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 10, right: 10, top: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 30,),
                                      Row(
                                        children: [
                                          Container(
                                            //margin: EdgeInsets.only(right: 10),
                                              width: 50,
                                              child: Divider(color: Colors.orange, thickness: 1,)
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('personalInfo')),
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              //margin: EdgeInsets.only(left: 10),
                                                child: Divider(color: Colors.orange, thickness: 1,)),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        padding: EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('usernameHint')),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),),
                                            Container(
                                                width: 200,
                                                height: 30,
                                                child: TextField(
                                                  readOnly: true,
                                                  textAlign: TextAlign.left,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                    contentPadding: EdgeInsets.all(5),
                                                    hintText: username == null? 'OsmanBaba' :username,
                                                  ),
                                                )
                                            )
                                          ],),
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerPhoneNumberField')),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black, fontWeight: FontWeight.bold),),
                                            ),
                                            //ggggg
                                            Container(
                                              width: 250,
                                              height: 50,
                                              child:  IntlPhoneField(
                                                showDropdownIcon: false,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(),
                                                  ),
                                                ),
                                                initialCountryCode: 'TR',
                                                onChanged: (phone) {
                                                  print(phone.completeNumber);
                                                  if(token == null){
                                                    Fluttertoast.showToast(
                                                      msg: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('loginTranslate')),
                                                      toastLength: Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.white70,
                                                      textColor: Colors.orange,
                                                      fontSize: 10.0,
                                                    );
                                                  }
                                                },
                                              ),
                                            )
                                          ],),
                                      ),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index){
                                            return
                                              index <= fileNum ?
                                              Container(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20,),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          //margin: EdgeInsets.only(right: 10),
                                                            width: 50,
                                                            child: Divider(color: Colors.orange, thickness: 1,)
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('fileInformation')),
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            //margin: EdgeInsets.only(left: 10),
                                                              child: Divider(color: Colors.orange, thickness: 1,)),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15,),
                                                    //radio groups
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        //radio group 1
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(left: 18, right: 18),
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                    text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('fileLanguage')),
                                                                    style: TextStyle(color: Colors.orange),
                                                                    children: <TextSpan> [
                                                                      TextSpan(
                                                                        text: ' *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),

                                                                      )
                                                                    ],
                                                                  )
                                                              ),
                                                            ),
                                                            Column (
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index + 2,
                                                                        groupValue: radioGroupValue1[index],
                                                                        onChanged: (val){
                                                                          setState(() {
                                                                            radioGroupValue1[index] = val;
                                                                          });
                                                                          if(token == null){
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
                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Arabic')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),

                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index + 1,
                                                                        groupValue: radioGroupValue1[index],
                                                                        onChanged: (val){

                                                                          setState(() {
                                                                            radioGroupValue1[index] = val;
                                                                          });
                                                                          if(token == null){
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
                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Turkish')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),

                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index,
                                                                        groupValue: radioGroupValue1[index],
                                                                        onChanged: (val){
                                                                          setState(() {
                                                                            radioGroupValue1[index] = val;
                                                                          });

                                                                          if(token == null){
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

                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('English')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),
                                                                  ],
                                                                ),


                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        //radio group 2
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(left: 18, right: 18),
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                    text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('translateLanguage')),
                                                                    style: TextStyle(color: Colors.orange),
                                                                    children: <TextSpan> [
                                                                      TextSpan(
                                                                        text: ' *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),

                                                                      )
                                                                    ],
                                                                  )
                                                              ),
                                                            ),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index + 2,
                                                                        groupValue: radioGroupValue2[index],
                                                                        onChanged: (val){
                                                                          setState(() {
                                                                            radioGroupValue2[index] = val;
                                                                          });
                                                                          if(token == null){
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
                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Arabic')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index + 1,
                                                                        groupValue: radioGroupValue2[index],
                                                                        onChanged: (val){
                                                                          setState(() {
                                                                            radioGroupValue2[index] = val;
                                                                          });
                                                                          if(token == null){
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
                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Turkish')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),

                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Radio(
                                                                        value: index,
                                                                        groupValue: radioGroupValue2[index],
                                                                        onChanged: (val){
                                                                          setState(() {
                                                                            radioGroupValue2[index] = val;
                                                                          });
                                                                          if(token == null){
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
                                                                        }),
                                                                    Text(
                                                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('English')),
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),

                                                                  ],
                                                                ),


                                                              ],
                                                            ),
                                                            SizedBox(height: 10,),

                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          //margin: EdgeInsets.only(right: 10),
                                                            width: 50,
                                                            child: Divider(color: Colors.orange, thickness: 1,)),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('documentType')),
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            //margin: EdgeInsets.only(left: 10),
                                                              child: Divider(color: Colors.orange, thickness: 1,)),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Container(
                                                      margin: EdgeInsets.only(left: 20, right: 20),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.black38),
                                                        borderRadius: BorderRadius.all(Radius.circular(4.0),),
                                                      ),
                                                      child: DropdownButton<String>(
                                                        value: fileType[index],
                                                        iconSize: 30,
                                                        icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                                                        isExpanded: true,
                                                        underline: SizedBox(),
                                                        elevation: 16,
                                                        items: dropdownNameItems[index].map((String item) {
                                                          return DropdownMenuItem(
                                                            value: item,
                                                            child: Container(
                                                                margin: EdgeInsets.only(left: 10, right: 10),
                                                                child: Text(item, style: TextStyle(fontSize: 14, color: Colors.black),)),
                                                          );
                                                        }).toList(),
                                                        onTap: () {},
                                                        onChanged: (value) {
                                                          setState(() {
                                                            fileType[index] = value;
                                                             selectFileType[index] = dropdownNameItems[index].indexOf(value);
                                                            filePrices[index] = kindList[selectFileType[index]]["price"];
                                                            sum[index] = filePrices[index] + noterPrice[index] + onayPrice[index];
                                                            topSum = 0;
                                                            for(int i = 0; i < sum.length;  i++){
                                                              topSum += sum[i];
                                                            }
                                                            topTrans = 0;
                                                            for(int i = 0; i<filePrices.length; i++){
                                                              topTrans += filePrices[i];
                                                            }

                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Container(
                                                      margin: EdgeInsets.only(top: 20, bottom: 20),
                                                        width: double.infinity,
                                                        child: Divider(color: Colors.orange, thickness: 1,)),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(left: 25),
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                checkColor: Colors.white,
                                                                value: isNoterChecked[index],
                                                                onChanged: (bool value) {
                                                                  if(token == null){
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
                                                                  setState(() {
                                                                    if(value){
                                                                      noterPrice[index] = 130;
                                                                    }else{
                                                                      noterPrice[index] = 0;
                                                                    }
                                                                    isNoterChecked[index] = value;
                                                                    sum[index] =  filePrices[index] + noterPrice[index] + onayPrice[index];
                                                                    topSum = 0;
                                                                    for(int i = 0; i < sum.length;  i++){
                                                                      topSum += sum[i];
                                                                    }
                                                                    topNoter =0;
                                                                    for(int i = 0; i<noterPrice.length; i++){
                                                                      topNoter += noterPrice[i];
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('noter')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(right: 50),
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                checkColor: Colors.white,
                                                                value: isOnayChecked[index],
                                                                onChanged: (bool value) {
                                                                  if(token == null){
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
                                                                  setState(() {
                                                                    isOnayChecked[index] = value;
                                                                    if(value){
                                                                      onayPrice[index] = 10;
                                                                    }else{
                                                                      onayPrice[index] = 0;
                                                                    }
                                                                    sum[index] =  filePrices[index] + noterPrice[index] + onayPrice[index];
                                                                    topSum = 0;
                                                                    for(int i = 0; i < sum.length;  i++){
                                                                      topSum += sum[i];
                                                                    }
                                                                    topOnay =0;
                                                                    for(int i = 0; i<onayPrice.length; i++){
                                                                      topOnay += onayPrice[i];
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('onay')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        //SizedBox(width: 5,),
                                                        GestureDetector(
                                                          onTap: (){
                                                            bool b = token != null;
                                                            if(token != null){
                                                              showModalBottomSheet(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  // return object of type Dialog
                                                                  return Container(
                                                                    width: 150,
                                                                    height: 400,
                                                                    child: selectFileType[index] == 0 || selectFileType[index] == 6 ?
                                                                    Column(
                                                                      children: [
                                                                        SizedBox(height: 20,),
                                                                        Container(
                                                                          margin: EdgeInsets.only(left: 10 , right: 10 ),
                                                                          alignment: Alignment.centerRight,
                                                                          child: GestureDetector(
                                                                              onTap: (){
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Icon(Icons.cancel, color: Colors.orange, size: 30,)
                                                                          ),
                                                                        ),
                                                                        Stack(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async{
                                                                                print("jjjjjjjjjjjjjj");
                                                                                await galeridenSec(index);
                                                                                print("ttttttttttt ${_file[index].path}");
                                                                              },
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 150,
                                                                                  width: 200,
                                                                                  color: Colors.black12,
                                                                                  child: _file[index] == null ? Center(
                                                                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('on')),
                                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                                                  ) : null,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              child: _file[index] != null ?
                                                                              Center(
                                                                                child: Container(
                                                                                  height: 150,
                                                                                  width: 200,
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: FileImage(
                                                                                        File(_file[index].path),
                                                                                      ),
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ) : Container(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: 20,),
                                                                        Stack(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async{
                                                                                await galeridenSec1(index);
                                                                              },
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 150,
                                                                                  width: 200,
                                                                                  color: Colors.black12,
                                                                                  child: _file1[index] == null ? Center(
                                                                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('arka')),
                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                  ) : null,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              child: _file1[index] != null ? Center(
                                                                                child: Container(
                                                                                  height: 150,
                                                                                  width: 200,
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: FileImage(
                                                                                        File(_file1[index].path),
                                                                                      ),
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ) : Container(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ):
                                                                    selectFileType[index] == 1 ? Container() :
                                                                    Column(
                                                                      children: [
                                                                        SizedBox(height: 20,),
                                                                        Container(
                                                                          margin: EdgeInsets.only(left: 10 , right: 10 ),
                                                                          alignment: Alignment.centerRight,
                                                                          child: GestureDetector(
                                                                              onTap: (){
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Icon(Icons.cancel, color: Colors.orange, size: 30,)
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 30,),
                                                                        Stack(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async{
                                                                                print("jjjjjjjjjjjjjj");
                                                                                await galeridenSec(index);
                                                                                print("ttttttttttt ${_file[index].path}");
                                                                              },
                                                                              child: Center(
                                                                                child: Container(
                                                                                  height: 200,
                                                                                  width: 200,
                                                                                  color: Colors.black12,
                                                                                  child: _file[index] == null ? Center(
                                                                                    child: Text("image",
                                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                                                  ) : null,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              child: _file[index] != null ?
                                                                              Center(
                                                                                child: Container(
                                                                                  height: 200,
                                                                                  width: 200,
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: FileImage(
                                                                                        File(_file[index].path),
                                                                                      ),
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ) : Container(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )
                                                                  );
                                                                },
                                                              );
                                                            }


                                                          },//_showDialog, //galeridenSec,
                                                          child: Container(
                                                            width: 100,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                                              color:  token == null ? Colors.black12 : Colors.orange,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Icon(Icons.file_upload,color: Colors.white , size: 15,),
                                                                Center(
                                                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('chooseFile')) + "*",
                                                                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        //SizedBox(height: 40,),
                                                        GestureDetector(
                                                          onTap: token == null ? null : () async {
                                                            await galeridenSec2(index);
                                                          },
                                                          child: Container(
                                                            width: 100,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                                              color:  token == null ? Colors.black12 : Colors.orange,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Icon(Icons.file_upload,color: Colors.white , size: 15,),
                                                                Center(
                                                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('chooseFile')) + " *",
                                                                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],),
                                                    Container(
                                                      width: double.infinity,
                                                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('not'),
                                                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                                          ),
                                                          Container(
                                                            width: double.infinity,
                                                            child: TextField(
                                                              minLines: 1,
                                                              maxLines: 3,
                                                              controller: notController[index],
                                                              style: TextStyle(color: Colors.black),
                                                              decoration: InputDecoration(
                                                                focusColor: Colors.orange,
                                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                              ),

                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        // Belge Fiyatı
                                                        Column(
                                                          children: [
                                                            Container(
                                                              child:
                                                              Text((
                                                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('documentPrice')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Container(
                                                              child:
                                                              Text(
                                                                filePrices[index].toString(),
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Noterlik Fiyatı
                                                        Column(
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                (
                                                                    Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('noterPrice')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Container(
                                                              child: Text(
                                                                noterPrice[index].toString(),
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20,),
                                                    // Apostil Fiyatı
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                (
                                                                    Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('apostilPrice')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Container(
                                                              child: Text(
                                                                onayPrice[index].toString(),
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Toplam Fiyat
                                                        Column(
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                (
                                                                    Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('totalPrice')),
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Container(
                                                              child: Text(
                                                                sum[index].toString(),
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),


                                                  ],
                                                ),
                                              ) : null;
                                          }

                                      ),
                                      SizedBox(height: 15,),
                                      GestureDetector(
                                        onTap: token == null ? null : (){
                                          setState(() {
                                            fileNum ++;
                                            print(fileNum);
                                            radioGroupValue1.add(-1);
                                            radioGroupValue2.add(-1);
                                            dropdownNameItems.add(mesut);
                                            fileType.add(dropdownNameItems[0][0]);
                                            isNoterChecked.add(false);
                                            isOnayChecked.add(false);
                                            notController.add(TextEditingController());
                                            filePrices.add(kindList[0]["price"]);
                                            sum.add(kindList[0]["price"]);
                                            topTrans += kindList[0]["price"];
                                            noterPrice.add(0);
                                            onayPrice.add(0);
                                            _file.add(myfile);
                                            _file1.add(myfile);
                                            _file2.add(myfile);
                                            selectFileType.add(0);
                                            print(selectFileType);
                                            topSum = 0;
                                            for(int i = 0; i < sum.length;  i++){
                                              topSum += sum[i];
                                            }
                                            fileNumber ++;
                                          });
                                        },
                                        child: Align(
                                          //alignment: Alignment.centerRight,
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 35),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color:  token == null ? Colors.black12 : Colors.orange,
                                            ),
                                            height: 30,
                                            width: 120,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Icon(Icons.add_circle, color: Colors.white, size: 15,),
                                                Text(
                                                  (
                                                      Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('newDoc')),
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ],),),
                                        ),
                                      ),
                                      Container(
                                        child:
                                        Row(
                                          children: [
                                            Container(
                                              // margin: EdgeInsets.only(right: 10),
                                                width: 50,
                                                child: Divider(color: Colors.orange, thickness: 1,)),
                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text((
                                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('deliveryMethod')),
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                //margin: EdgeInsets.only(left: 10),
                                                  child: Divider(color: Colors.orange, thickness: 1,)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                                            children: [
                                              Radio(value: 0, groupValue: addressRadio,
                                                onChanged: (value) {
                                                  if(token == null){
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
                                                  setState(() {
                                                    addressRadio = value;
                                                    sendType=0.toString();
                                                    addressHint = "";
                                                    isAddressActive = false;
                                                  });
                                                },
                                              ),
                                              Text((
                                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cargoDelivery')),
                                                style: TextStyle(color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Radio(value: 1, groupValue: addressRadio,
                                                onChanged: (value) {
                                                  if(token == null){
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
                                                  setState(() {
                                                    addressRadio = value;
                                                    sendType=1.toString();
                                                    _adresController.text = "";
                                                    addressHint = "İmam Bakır Mah.Şutim Cad. B Blok No:21 İç Kapı No:1 -Halilye/ŞANLIURFA";
                                                    isAddressActive = true;
                                                  });
                                                },),
                                              Text((
                                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('officeDelivery')),
                                                style: TextStyle(color: Colors.black),),
                                            ],
                                          ),
                                        ],),
                                      SizedBox(height: 20,),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                              text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('address')),
                                              style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold,),
                                              children: <TextSpan> [
                                                TextSpan(
                                                  text: ' * ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),

                                                )
                                              ],
                                            )
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                        width: double.infinity,
                                        child: TextField(
                                          controller: _adresController,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Colors.black),
                                          readOnly: isAddressActive,
                                          maxLines: 3,
                                          minLines: 1,
                                          decoration: InputDecoration(
                                            focusColor: Colors.orange,
                                            border: OutlineInputBorder(),
                                            hintText: addressHint,
                                            hintStyle: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                //margin: EdgeInsets.only(right: 10),
                                                  width: 50,
                                                  child: Divider(
                                                    color: Colors.orange, thickness: 1,)),

                                              Container(
                                                margin: EdgeInsets.symmetric(horizontal: 10),
                                                child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('paymentInfo')),
                                                  style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  //margin: EdgeInsets.only(left: 20, right: 20),
                                                    child: Divider(
                                                      color: Colors.orange, thickness: 1,)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 30,),
                                          //translate
                                          Container(
                                            margin: EdgeInsets.only(left: 20, right: 20),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('translate')),
                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                  Text(topTrans.toString(),
                                                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                ]
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: 30),
                                              child: Divider(thickness: 1, color: Colors.orange,)),
                                          SizedBox(height: 10,),
                                          //Noter
                                          Container(
                                            margin: EdgeInsets.only(left: 20, right: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('noter')),
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                Text(topNoter.toString(),
                                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: 30),
                                              child: Divider(thickness: 1, color: Colors.orange,)),
                                          SizedBox(height: 10,),
                                          //Onay
                                          Container(
                                            margin: EdgeInsets.only(left: 20, right: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('onay')) ,
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                Text(topOnay.toString(), style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),)
                                              ],
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.symmetric(horizontal: 30),
                                              child: Divider(thickness: 1, color: Colors.orange,)),
                                          SizedBox(height: 10,),

                                          //topSum
                                          Container(
                                            margin: EdgeInsets.only(left: 20, right: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('totalPrice')),
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                Text(topSum.toString(), style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Container(
                                            margin: EdgeInsets.only(right: 10, left: 10),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  checkColor: Colors.white,
                                                  value: issend,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      issend = value;
                                                    });
                                                  },
                                                ),
                                                TextButton(
                                                    onPressed: () => showDialog<String>(
                                                      context: context,
                                                      builder: (BuildContext context) => AlertDialog(
                                                        title: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('serviceTermsTitle'),
                                                          style: TextStyle(
                                                            color: Colors.orange,
                                                          ),
                                                        ),
                                                        content: SingleChildScrollView(
                                                          child:  Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('serviceTerms'),
                                                            style: TextStyle(
                                                              color: Color.fromRGBO(46, 96, 113, 1),
                                                            ),
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context, 'Cancel');
                                                              setState(() {
                                                                issend = false;
                                                              });
                                                            } ,
                                                            child:  Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel'),),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                issend = true;
                                                              });
                                                              Navigator.pop(context, 'Accept');
                                                            } ,
                                                            child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('acceptService'),
                                                          ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    child:  RichText(
                                                      text: TextSpan(
                                                        text: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('accept'),
                                                        style: TextStyle(color: Colors.black),
                                                        children:  <TextSpan>[
                                                          TextSpan(
                                                              text: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('terms'),
                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange,  decoration: TextDecoration.underline,)),
                                                          TextSpan(
                                                              text: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('service')
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 10,),
                                        ],
                                      ),
                                      Container(
                                        child: ElevatedButton(
                                          onPressed: token == null ? null : ()async{
                                            // radioGroupValue1

                                            bool require = true;
                                            for(int i = 0; i <= fileNumber; i++){
                                              if(radioGroupValue1[i] == -1 || radioGroupValue2[i] == -1 || _file[i] == null || (_file1[i] == null && (selectFileType[i] == 0 || selectFileType[i] == 1 ||selectFileType[i] == 6 ))  || _file2[i] == null || (_adresController.text == null && sendType == 0)){
                                                require = false;
                                                Fluttertoast.showToast(
                                                  msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.white70,
                                                  textColor: Colors.orange,
                                                  fontSize: 16.0,
                                                );
                                              }
                                            }
                                            if(require){
                                              if(issend == false){
                                                Fluttertoast.showToast(
                                                  msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastsend'),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.white70,
                                                  textColor: Colors.orange,
                                                  fontSize: 16.0,
                                                );

                                              }else{
                                                await fetchDrop(fileNumber);
                                              }
                                            }
                                          },
                                          child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('send')),
                                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold
                                            ),),
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ],

                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 150,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                      color: Colors.orange
                                  ),
                                  child: Center(
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('serviceRequest')),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
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