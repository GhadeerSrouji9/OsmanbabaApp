import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateAid extends StatefulWidget {
  @override
  _StateAidState createState() => _StateAidState();
}

class _StateAidState extends State<StateAid> {
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  String altTurDrop;
  List<String> altTurDropDown = ['Tercümanlık Hizmeti', 'Şirket Kuruluş Hizmeti', 'E_imza Hizmeti', 'Paketler', 'Diğer'];
  int altTurDropDownIndex = 0;
  FocusNode _emailFocus = FocusNode();
  bool isEmailValid = false;
  String token ;
  String username;
  String email;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _companyEmail = TextEditingController();
  String formattedDate;
  String formattedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime, builder: (BuildContext context, Widget child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child,
      );
    }
    );

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
      "Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiTk9PUiIsIlJvbGUiOlsiQ29tcGFueSIsIkNvbXBhbnkiLCJDb21wYW55IiwiQ29tcGFueSIsIkNvbXBhbnkiLCJDb21wYW55IiwiQ29tcGFueSJdLCJleHAiOjE2NDYxMzQ2MzUsImlzcyI6IkludmVudG9yeUF1dGhlbnRpY2F0aW9uU2VydmVyIiwiYXVkIjoiSW52ZW50b3J5U2VydmljZVBvdG1hbkNsaWVudCJ9.w1a63UhVaR_c3E72WIGxYH5jAQ5AiZth1MKuT6Yd4KE"

    };
    final response = await http.post(Uri.parse(webURL + "api/AddAppointment"), headers: head, body: jsonEncode(
      {
        "Service":index,
        "Appointment_Date": formattedDate + "T" + formattedTime + ":00"//"2022-02-10T04:03:00"
      },
    ));
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
  void initState() {
    fetchTokenPreference();
    super.initState();
  }

  final _advancedDrawerController = AdvancedDrawerController();
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
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 20),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10, top: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Image.asset('assets/imgs/gelenksel.jpeg', )),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidTitle')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText1')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle2')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText2')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle3')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText3')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle4')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText4')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 20, left: 20),
                                    child: Center(
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
                                                                      controller: _emailController,
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
                                                                      controller: _companyEmail,
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
                                            primary:  Color.fromRGBO(46, 96, 113, 1),
                                            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            textStyle:
                                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15,)
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 300,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                    color: Colors.orange
                                ),
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidTitle')),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10, top: 15,),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Image.asset('assets/imgs/ileri.jpg', )),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle5')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText5')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle2')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText6')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle3')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText7')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle6')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText8')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle7')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText9')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle4')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText10')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 20, left: 20),
                                    child: Center(
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
                                                                      controller: _emailController,
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
                                                                      controller: _companyEmail,
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
                                            primary:  Color.fromRGBO(46, 96, 113, 1),
                                            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            textStyle:
                                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15,)
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 300,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                    color: Colors.orange
                                ),
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle5')),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10, top: 15,),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5.0),),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Image.asset('assets/imgs/Arg.jpg', )),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle8')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle9')),
                                        style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),)),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText11')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                        child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle8')),
                                          style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                      ),
                                      stateAidCard(context, "arge1",  "150.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge2",  "300.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge3",  "200.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge4",  "100.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge5",  "100.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge6",  "20.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge7",  "20.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge8",  "10.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge9",  "20.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge10",  "20.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge11",  "5.000"),
                                      SizedBox(height: 15,),
                                      stateAidCard(context, "arge12",  "10.000"),
                                    ],
                                  ),
                                  SizedBox(height: 30,),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle10')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) , fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubText12')),
                                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1) ,),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 20, left: 20),
                                    child: Center(
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
                                                                      controller: _emailController,
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
                                                                      controller: _companyEmail,
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
                                            primary: Color.fromRGBO(46, 96, 113, 1),
                                            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            textStyle:
                                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15,)
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 380,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                    color: Colors.orange
                                ),
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateAidSubTitle8')),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  ),
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
          ),
          drawer: Drawers()
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  void translateAltTurDropDown(){
    altTurDropDown =[(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb1')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb2')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb3')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb4')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb5')),

    ];

  }

  Container stateAidCard(BuildContext context, text1,  text3) {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: Card(
        elevation: 4,
        child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation(text1)),
                  style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1)),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('limit')),
                      style: TextStyle(color:  Color.fromRGBO(46, 96, 113, 1), fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Text(text3,
                      style: TextStyle(color: Colors.orange , fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}