import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:osmanbaba/Models/Message.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/mersis.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/translate.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'Packages.dart';
import 'SignalRHelper.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'chat.dart';
import 'eSignature.dart';

class Company extends StatefulWidget {
  final name;
  const Company({Key key, this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CompanyState();
  }
}

 class _CompanyState extends State<Company> {
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  SignalRHelper signalR = new SignalRHelper();
  var scrollController = ScrollController();
  var txtController = TextEditingController();
  List<Map<String, dynamic>> packages = [];

  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  String altTurDrop;
  List<String> altTurDropDown = ['Tercümanlık Hizmeti', 'Şirket Kuruluş Hizmeti', 'E_imza Hizmeti', 'Paketler', 'Diğer'];

  String username;
  String email;
  String formattedDate;
  String formattedTime;
  FocusNode _emailFocus = FocusNode();
  int altTurDropDownIndex = 0;
  String token ;
  final List<String> dropdownNameItems=[""];
  List<Map<String, dynamic>> kindList = [];
  List<Map<String, dynamic>> languageList = [];



  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime, builder: (BuildContext context, Widget child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child,
      );
    }
    );

    print("vvvvv ${selectedTime}");

    if (picked_s != null && picked_s != selectedTime )
      setState(() {
        selectedTime = picked_s;
        formattedTime = selectedTime.format(context);
        print("ggggggggg" + formattedTime);

      });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        print("xxxxx" + formattedDate);
      });
  }

  Future<void> _AddAppointment(index) async{
    var head = {

      "content-type":"application/json",
      "Authorization":"Bearer $token"

    };
    final response = await http.post(Uri.parse(webURL + "api/AddAppointment"), headers: head, body: jsonEncode(
      {
        "Service":index,
        "Appointment_Date": formattedDate + "T" + formattedTime + ":00"//"2022-02-10T04:03:00"
      },
    ));

    print(response.statusCode);
    print(formattedTime);
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

  void translateAltTurDropDown(){
    altTurDropDown =[(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb1')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb2')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb3')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb4')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb5')),

    ];

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

  Future<void> fetchTokenPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token');
      username = prefs.getString('username');
      email = prefs.getString('email');
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

  receiveMessageHandler(args) {
    signalR.messageList.add(
        Message(
            name: args[0], message: args[1], isMine: args[0] == widget.name));
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 75);
    setState(() {});
  }

  @override
  void initState() {
    fetchTokenPreference();
    signalR.connect(receiveMessageHandler);
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

      home: DefaultTabController(
        length: 2,
        child: AdvancedDrawer(
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
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: TabBar(
                    labelColor: Color.fromRGBO(46, 96, 113, 1),
                    indicatorColor: Color.fromRGBO(46, 96, 113, 1) ,
                    tabs: <Widget>[
                      Tab(
                        child: Text(
                          (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('anonimCompany')),
                          style: TextStyle(fontWeight: FontWeight.bold, color:  Color.fromRGBO(46, 96, 113, 1) ,),
                        ),
                      ),
                      Tab(
                        child: Text(
                          (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('limitedCompany')),
                          style: TextStyle(fontWeight: FontWeight.bold, color:  Color.fromRGBO(46, 96, 113, 1) ,),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                       ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(30, 25, 30, 10),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle')),
                              style: TextStyle(fontWeight: FontWeight.bold, color:Colors.orange,),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 30),
                            child: ReadMoreText((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisDesc')),
                              style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              trimLines: 3,
                              colorClickableText: Colors.orange,
                              trimMode: TrimMode.Line,
                              moreStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                              trimCollapsedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('more'),
                              trimExpandedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('less'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                            width: 300,
                            height: 30,
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyTarif')),
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 30,),
                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText1')),
                              style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle2')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText2')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle3')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, ),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText3')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle4')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText4')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle5')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText5')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle6')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, ),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText6')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle7')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText7')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle8')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText8')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle9')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, ),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText9')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle10')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, ),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText10')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle11')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText11')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                              width: 300,
                              height: 30,
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle12')),
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 30, right: 30,),
                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText12')),
                                style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                          ),

                        ],
                      ),
                       ListView(
                         //crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Container(
                             margin: EdgeInsets.fromLTRB(30, 25, 30, 10),
                             child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle')),
                               style: TextStyle(fontWeight: FontWeight.bold, color:Colors.orange,),
                             ),
                           ),
                           Container(
                             margin: EdgeInsets.only(left: 30, right: 30),
                             child: ReadMoreText((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisDesc')),
                               style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                               trimLines: 3,
                               colorClickableText: Colors.orange,
                               trimMode: TrimMode.Line,
                               moreStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                               trimCollapsedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('more'),
                               trimExpandedText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('less'),
                             ),
                           ),
                           Container(
                             margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                             width: 300,
                             height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyTarif')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               ),
                           ),
                           Container(
                             margin: EdgeInsets.only(left: 30, right: 30,),
                             child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText1')),
                               style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                             ),
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle2')),
                                   style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText2')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                               )
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle3')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, ),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText3')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                               )
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle4')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText4')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                               )
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle5')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText5')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                               )
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle6')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, ),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText6')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle7')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText7')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle8')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText8')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle9')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, ),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText9')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle10')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, ),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText10')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle11')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText11')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                               width: 300,
                               height: 30,
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisTitle12')),
                                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                               )),
                           Container(
                               margin: EdgeInsets.only(left: 30, right: 30,),
                               child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mersisText12')),
                                 style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),)
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: ElevatedButton(
                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('startMersis')),),
                    onPressed: () {
                      Navigator.push(
                          this.context,
                          new MaterialPageRoute(builder: (context) => new Mersis())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        primary: Color.fromRGBO(46, 96, 113, 1),
                        padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: ElevatedButton(
                    child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('callus')),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                          builder: (context, setState) {
                            translateAltTurDropDown();
                            return AlertDialog(
                              title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('randevuAl')),
                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16)
                              ),
                              content:  Container(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
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
                                                  textAlign: TextAlign.left,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(fontSize: 16, color: Colors.black45, ),
                                                    contentPadding: EdgeInsets.all(8),
                                                    hintText: username == null? 'OsmanBaba' : username,
                                                  ),
                                                  keyboardType: TextInputType.emailAddress,
                                                )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
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
                                                  Text( (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('visitReason')),
                                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            Container(
                                              //margin: EdgeInsets.only(left: 10, right: 10),
                                              padding: EdgeInsets.only(left: 10, right: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black38),
                                                borderRadius: BorderRadius.all(Radius.circular(4.0),),
                                              ),
                                              child: DropdownButton<String>(
                                                value: altTurDrop,
                                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                                isExpanded: true,
                                                underline: SizedBox(),
                                                elevation: 16,
                                                style: TextStyle(color: Colors.black, fontSize: 12),
                                                hint: Container(
                                                  width: 150,                      //and here
                                                  child: Text(
                                                    (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('visitReason')),
                                                    style: TextStyle(color: Colors.black26, fontSize: 14),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    altTurDrop = newValue;
                                                    if(altTurDrop == "Tercümanlık Hizmeti"){
                                                      altTurDropDownIndex = 0;
                                                    }else if(altTurDrop == "Şirket Kuruluş Hizmeti"){
                                                      altTurDropDownIndex = 1;
                                                    }else if(altTurDrop == "E_imza Hizmeti"){
                                                      altTurDropDownIndex = 2;
                                                    }else if(altTurDrop == "Paketler"){
                                                      altTurDropDownIndex = 3;
                                                    }else if(altTurDrop == "Diğer"){
                                                      altTurDropDownIndex = 4;
                                                    }

                                                  });
                                                },
                                                items: altTurDropDown
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ofisAdress')),
                                                style: TextStyle(color: Colors.orange, fontSize: 14),),
                                            ),
                                            SizedBox(height: 10,),
                                            Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.orange),
                                                  borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Text(
                                                    (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ofisadresi')),
                                                    style: TextStyle(fontSize: 12, color: Color.fromRGBO(46, 96, 113, 1),),
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                SizedBox(width: 8,),
                                                Container(
                                                  child:
                                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('randevuTarihi')),
                                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                RaisedButton(
                                                  color: Colors.orange ,
                                                  onPressed: () => _selectDate(context),
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectDate')),
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                                SizedBox(width: 8,),
                                                Container(
                                                  child:
                                                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('randevuSaati')),
                                                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                                                ),

                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                RaisedButton(
                                                  color: Colors.orange ,
                                                  onPressed: () => _selectTime(context),
                                                  child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectTime')),
                                                    style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
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
                                        await _AddAppointment(altTurDropDownIndex);
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        primary: Color.fromRGBO(46, 96, 113, 1),
                        padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawers()
        ),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}
