import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:osmanbaba/Models/city.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/kurumsalPayment.dart';
import 'package:osmanbaba/pages/payment.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as Math;
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';


class Kurumsal extends StatefulWidget {
  final String price;
  final String name;
  final int priceValNum;

  Kurumsal (this.price, this.name, this.priceValNum);

  @override
  _KurumsalState createState() => _KurumsalState();
}

class _KurumsalState extends State<Kurumsal> {

  final _advancedDrawerController = AdvancedDrawerController();
  List<Map<String, dynamic>> kindList = [];
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> languageList = [];
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  bool isIlceDropdownEndabled = false;
  int ilceId = 0;
  List<String> cityIdsList = [""];
  bool isAreaDropdownEndabled = true;
  List<String> areasList = [];
  bool isDistrictDropdownEndabled = false;
  bool cardInfo = false;
  int areaIndex = null;
  String token = "s" ;

  List<String> areaIdsList = [];
  List<String> districtList = [];
  List<String> districtIdsList = [];
  List<String> citiesList = [];

  TextEditingController _companyName = TextEditingController();
  TextEditingController _companyAddress = TextEditingController();
  TextEditingController _companyPhone = TextEditingController();
  TextEditingController _companyEmail = TextEditingController();
  TextEditingController _companyVergiNo = TextEditingController();
  String kurumsalPhone = "";


  FocusNode _emailFocus = FocusNode();
  bool isEmailValid = false;

  @override
  void initState() {
    _emailFocus.addListener(_onEmailFocusChange);
    super.initState();
  }

  void _onEmailFocusChange(){
    if(!_emailFocus.hasFocus ){
      if(EmailValidator.validate(_companyEmail.text)){
        setState(() {
          isEmailValid = true;
        });
      } else{
        isEmailValid = false;
        Fluttertoast.showToast(
            msg: "Please Enter a valid email",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    }
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

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  Future<List<String>> updateDistrictById(areaId) async{
    final url = Uri.parse(webURL + 'api/ListSemetBayArea');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ areaId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"];
      setState(() {
        districtList = [];
        districtIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          districtList.add(decoded[i]["name"]);
          districtIdsList.add(decoded[i]["id"]);
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return districtList;
  }

  Future<List<String>> updateAreaById(cityId) async{
    final url = Uri.parse(webURL + 'api/ListAreaBayCity');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ cityId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"];

      setState(() {
        areasList = [];
        areaIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          areasList.add(decoded[i]["name"]);
          areaIdsList.add(decoded[i]["id"]);
        }
      });

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return areasList;
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

  Future<List <City>> getCities() async{

    final url = Uri.parse(webURL + 'api/ListCityBayCountry');
    final headers = {"Content-type": "application/json"};
    final json = '{ "id": "31a92a64-a21c-4cfd-bb55-466cb4c495fb" }';
    final response = await post(url, headers: headers, body: json);
    var jsonData = jsonDecode(response.body);
    jsonData = jsonData["description"];

    setState(() {
      citiesList = [];
      cityIdsList = [];
      for(int i = 0; i < jsonData.length; i++){
        citiesList.add(jsonData[i]["name"]);
        cityIdsList.add(jsonData[i]["id"]);
      }
    });

    List<City> cities = [];

    for (var i in jsonData) {
      City city = City(i["id"], i["name"], i["countryID"]);
      cities.add(city);
    }
    return cities;
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
        dropdownNameItems.add(kindList[i]["name"]);


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

  // taxxxxxxx
  bool taxNumber(String tax) {
    int tmp;
    int sum = 0;

    print("222222b $tax");
    bool isNum = isNumeric(tax);
    print("3333333 $isNum");

    if (tax != null && tax.length == 10 && isNum) {
      int taxNumber = int.parse(tax);
      int lastDigit = taxNumber % 10;
      print("weeeeeeee ${lastDigit}");
      for (int i = 0; i < 9; i++) {
        int digit = int.parse(tax[i]);
        tmp = (digit + 10 - (i + 1)) % 10;
        sum = (tmp == 9 ? sum + tmp : sum + ((tmp * (Math.pow(2, 10 - (i + 1)))) % 9));
      }
      return lastDigit == (10 - (sum % 10)) % 10;
    }
    return false;
  }

  bool isNumeric(String tax) {
    if (tax == null) {
      print("sssss $tax");
      return false;
    }
    print("ttttttS $tax");
    return double.tryParse(tax) != null;
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
        primaryColor: Color.fromRGBO(245, 124, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30,),
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        width: 50,
                        child: Divider(
                          color: Colors.orange, thickness: 1,)),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyInfo')),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),),
                    ),
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Divider(
                            color: Colors.orange, thickness: 1,)),
                    ),

                  ],
                ),
                SizedBox(height: 20,),
                Column(
                  children: [
                    Container(
                      height: 100,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                SizedBox(width: 8,),
                                Container(
                                  child:
                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyName')),
                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextField(
                                controller: _companyName,
                                maxLines: 1,
                                style: TextStyle(color: Colors.black),
                                decoration: new InputDecoration(
                                  focusColor: Colors.orange,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  border:  OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.orange),
                                  ),
                                ),
                              )
                          )],
                      ),
                    ),
                    Container(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                SizedBox(width: 8,),
                                Container(
                                  child:
                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyAddress')),
                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextField(
                                controller: _companyAddress,
                                maxLines: 1,
                                style: TextStyle(color: Colors.black),
                                decoration: new InputDecoration(
                                  focusColor: Colors.orange,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  border:  OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.orange),
                                  ),
                                ),
                              )
                          )],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      height: 100,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                SizedBox(width: 8,),
                                Container(
                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyEmail')),
                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                controller: _companyEmail,
                                maxLines: 1,
                                focusNode: _emailFocus,
                                style: TextStyle(color: Colors.black),
                                decoration: new InputDecoration(
                                  focusColor: Colors.orange,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  border:  OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.orange),
                                  ),
                                ),
                                onChanged: (text) {
                                  if(EmailValidator.validate(_companyEmail.text)){
                                    setState(() {
                                      isEmailValid = true;
                                    });
                                  } else{
                                    isEmailValid = false;
                                  }
                                },
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                // VERGI NO AND COMPANY PHONE
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Container(
                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                          SizedBox(width: 8,),
                          Container(
                            child:
                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyVergiNo')),
                              style: TextStyle(color: Colors.orange, fontSize: 14),),
                          ),

                        ],
                      ),
                    ),

                    // VERGI TEXT FIELD
                    SizedBox(height: 10,),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          controller: _companyVergiNo,
                          maxLines: 1,
                          maxLength: 10,
                          validator: (value) {
                            if (!taxNumber(value)) {
                              return 'Please enter valid tax number';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: new InputDecoration(
                            focusColor: Colors.orange,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            border:  OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange),
                            ),
                          ),
                        )
                    ),
                    SizedBox(height: 30,),
                    // kkkkkkkkkkkkkkkkkkkkk
                    Container(
                      height: 100,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                SizedBox(width: 8,),
                                Container(
                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyPhone')),
                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 10, right: 10),
                            height: 65,
                            child:  IntlPhoneField(
                              showDropdownIcon: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
                              ),
                              initialCountryCode: 'TR',
                              onChanged: (phone) {
                                setState(() {
                                  kurumsalPhone = phone.completeNumber;
                                });
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        width: 50,
                        child: Divider(
                          color: Colors.orange, thickness: 1,)),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addressInfo')),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),),
                    ),
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Divider(
                            color: Colors.orange, thickness: 1,)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                          SizedBox(width: 8,),
                          Container(
                            child:
                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('address')),
                              style: TextStyle(color: Colors.orange, fontSize: 14),),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Container(
                          width: double.infinity,
                          child: TextField(
                            minLines: 1,
                            maxLines: 3,
                            style: TextStyle(color: Colors.black),
                            decoration: new InputDecoration(
                              focusColor: Colors.orange,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              border:  OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.orange),
                              ),
                            ),
                          )
                      )],
                  ),
                ),
                SizedBox(height: 30,),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.name}",
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  "${widget.price}",
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 30,),
                            Container(
                                margin: EdgeInsets.only(left: 50, right: 50),
                                child: Divider(color: Colors.orange,)),
                            SizedBox(height: 30,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total')),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                Text(
                                  "${widget.priceValNum}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ],
                            ),
                            SizedBox(height: 40,),
                          ],
                        ),
                      ),
                    )
                ),
                Container(
                  width: 100,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.orange) ),
                    onPressed: (){
                      bool isTaxNumValid = taxNumber(_companyVergiNo.text);
                      print("11111 $isTaxNumValid");
//                      print("yyyyyyyyyyy" + _companyName.text.isEmpty.toString() + kurumsalPhone.isEmpty.toString() + _companyVergiNo.text.isEmpty.toString() + _companyAddress.text.isEmpty.toString());
                      if( _companyName.text.isEmpty ||  _companyEmail.text.isEmpty ||  kurumsalPhone.isEmpty|| _companyVergiNo.text.isEmpty || _companyAddress.text.isEmpty){
                        Fluttertoast.showToast(
                          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastInfoFill'),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white70,
                          textColor: Colors.orange,
                          fontSize: 16.0,
                        );
                      } else if (!isTaxNumValid) {
                        Fluttertoast.showToast(
                            msg: "Check Vergi number",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white70,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      } else if(!isEmailValid) {
                        Fluttertoast.showToast(
                          msg: "Email not Valid",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white70,
                          textColor: Colors.orange,
                          fontSize: 16.0,
                        );
                      } else{
                        Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => new KurumsalPayment(_companyVergiNo.text, _companyName.text, kurumsalPhone, _companyAddress.text, _companyEmail.text, widget.price, widget.name, widget.priceValNum))
                        );
                      }
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
                          style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),

        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,

    );
  }
}
