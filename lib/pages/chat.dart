import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osmanbaba/Models/Message.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SignalRHelper.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';

class Chat extends StatefulWidget {
  final name;
  const Chat({Key key, this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatState();
  }
}

class _ChatState extends State<Chat> {
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  SignalRHelper signalR = new SignalRHelper();
  var scrollController = ScrollController();
  var txtController = TextEditingController();

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
      
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: signalR.messageList.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(
                      signalR.messageList[i].isMine
                          ? signalR.messageList[i].message
                          : signalR.messageList[i].name +
                              ': ' +
                              signalR.messageList[i].message,
                      textAlign: signalR.messageList[i].isMine
                          ? TextAlign.end
                          : TextAlign.start,
                    ),
                  );
                },
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(color: Color.fromRGBO(72, 122, 112, 1)),
                  controller: txtController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedBorder:OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    hintText: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('send'),
                    hintStyle: TextStyle(color:Colors.orange, fontWeight: FontWeight.bold),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        signalR..sendMessage(widget.name, txtController.text);
                        txtController.clear();
                        scrollController.jumpTo(
                            scrollController.position.maxScrollExtent + 75);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawers()
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
