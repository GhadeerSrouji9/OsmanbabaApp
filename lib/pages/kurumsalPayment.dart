import 'dart:async';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'whyOsmanbaba.dart';
import 'auth/login.dart';
import 'categories.dart';
import 'company.dart';
import 'eSignature.dart';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'mobile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';


class KurumsalPayment extends StatefulWidget {

  final String _companyTaxNumber;
  final String _companyName;
  final String _phoneNum;
  final String _companyAddress;
  final String _companyEmail;
  final String price;
  final String name;
  final int priceValNum;


  KurumsalPayment(this._companyTaxNumber, this._companyName, this._phoneNum, this._companyAddress, this._companyEmail, this.price, this.name, this.priceValNum);

  @override
  _KurumsalPayment createState() => _KurumsalPayment();
}

class _KurumsalPayment extends State<KurumsalPayment> {

  final _advancedDrawerController = AdvancedDrawerController();
  List<Map<String, dynamic>> languageList = [];
  List<Map<String, dynamic>> kindList = [];
  final List<String> dropdownNameItems=[""];
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  TextEditingController couponController = TextEditingController();

  String cardNumber = '';
  String expiryDate= '';
  String cardHolderName = '';
  String cvvCode= '';
  bool isCvvFocused = false;
  bool issend = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool cardInfo = false;

  bool checkCoupon;
  String code;
  String used;
  int offer;
  double price;
  bool showTotal = false;


  void onCreditCardModelChange(CreditCardModel creditCardModel){
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
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

  Future<void> checkCopone() async {
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token",
    };
    final response = await http.get(Uri.parse(webURL + 'api/CheckCopone'), headers: headers);
    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      print("vvvvvvvvv" + decoded.toString());
      setState(() {
        checkCoupon = decoded;
      });
    } else {
      throw Exception('Failed to load');
    }
  }

  Future <void> getCopuneByCode() async{
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token",
    };
    final url = Uri.parse(webURL + 'api/GetCopuneByCode');
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "code": couponController.text,
        }
    ));
    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      if (decoded["status"]) {
        decoded = decoded["description"];
        setState(() {
          offer = decoded["offer"];
          used = decoded["used"];
          if(used == "Not Used"){
            price = price * (offer / 100);
            showTotal = true;
          }
        });
      }
    } else {
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

  @override
  void initState() {
    price = widget.priceValNum.toDouble();
    checkCopone();
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
      home:  AdvancedDrawer(
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
                Container(
                    margin: EdgeInsets.only(top: 20),
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
                                  widget.name,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  widget.price,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyVergiNo')),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  widget._companyTaxNumber,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyName')),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  widget._companyName,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyPhone')),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  widget._phoneNum,
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('address')),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  "??anl??urfa",
                                  style: TextStyle(fontSize: 12 , color: Colors.black),
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
                                 " ${widget.priceValNum}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ],
                            ),
                            SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    )
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    "Havale/EFT ile ??deme yapmak i??in a??a????daki IBAN numaralar??na sipari?? tutar??n??, a????klama k??sm??na a??a??daki referans numaras??n?? girerek g??nderiniz",
                    style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) ,),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                      "Osmanbaba Vak??f Kat??l??m Bankas??n?? IBANI:"
                     " RUHARTE B??L??????M TEKNOLOJ??LER?? SANAY?? VE T??CARET L??M??TED ????RKET",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(46, 96, 113, 1) ,),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                      "TR24 0021 0000 0005 6503 9000"
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                      "Referans Numaras??",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(46, 96, 113, 1) ,),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                      "348728473"
                  ),
                ),


                checkCoupon == true ? Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Text( (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AdCoupon')),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: TextField(
                        controller: couponController,
                        maxLength: 8,
                      ),
                    ),
                  ],
                ) : Container(),
                SizedBox(height: 10,),
                Container(
                  child: Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: issend,
                        onChanged: (bool value) async{
                          if(checkCoupon == true  && showTotal == false){
                            await getCopuneByCode();
                          }
                          setState(() {
                            issend = value;

                          });
                        },
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: RichText(
                            text:  TextSpan(
                                text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('iRead')),
                                style: TextStyle(
                                  color: Color.fromRGBO(46, 96, 113, 1) ,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('advertisingAgreement')),
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _createPdf();
                                        }
                                  ),
                                  TextSpan(
                                      text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('and')),
                                      style: TextStyle(
                                        color: Color.fromRGBO(46, 96, 113, 1) ,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('privacyPolicy')),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                                decoration: TextDecoration.underline
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                launch('https://osmanbaba.net/Privacy');
                                              }
                                        ),
                                        TextSpan(
                                          text: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('andAcceptit')),
                                          style: TextStyle(
                                            color: Color.fromRGBO(46, 96, 113, 1) ,
                                          ),
                                        )
                                      ]
                                  )
                                ]
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                showTotal ?
                Container(
                  width: double.infinity,
                  height: 250,
                  margin: EdgeInsets.all(20),
                  child: DottedBorder(
                    color: Colors.orange,//color of dotted/dash line
                    strokeWidth: 3, //thickness of dash/dots
                    dashPattern: [10,6],
                    child: Column(
                      children: [
                        Container(
                          color: Color.fromRGBO(245, 245, 245, 1),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('packageName')),
                                style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('price')),
                                style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                widget.price,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 50, right: 50),
                            child: Divider(color: Colors.orange,)),
                        Container(
                          color: Color.fromRGBO(245, 245, 245, 1),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('coupon')),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              Text(
                                " ${widget.priceValNum.toDouble() - price}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Color.fromRGBO(245, 245, 245, 1),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total')),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              Text(
                                " ${price}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ): Container(),
                Column(
                  children: [
                    Container(
                      height: 200,
                      margin: EdgeInsets.only(top: 20),
                      child: CreditCardWidget(
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        showBackView: isCvvFocused,
                        obscureCardNumber: true,
                        obscureCardCvv: true,
                        cardBgColor: Color.fromRGBO(46, 96, 113, 1),
                      ),
                    ),
                    Column(
                      children: [
                        CreditCardForm(
                          themeColor: Colors.orange,
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          cvvCode: cvvCode,
                          onCreditCardModelChange: onCreditCardModelChange,
                          formKey: formKey,
                          cardNumberDecoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cardNumber')),
                            labelStyle: TextStyle(color: Colors.black26, fontSize: 12),
                            hintText: 'xxxx xxxx xxxx xxxx',
                          ),
                          expiryDateDecoration: InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.orange ),

                              ),
                              focusedBorder: new OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.orange ),

                              ),
                              labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ValidDate')),
                              labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                              hintText: 'xx/xx'
                          ),
                          cvvCodeDecoration: InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.orange ),

                              ),
                              focusedBorder: new OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.orange ),

                              ),
                              labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cvv')),
                              labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                              hintText: 'xxx'
                          ),
                          cardHolderDecoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.orange ),

                            ),
                            labelText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CardholderName')),
                            labelStyle: TextStyle(color: Colors.black38, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: 100,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.orange) ),
                            onPressed: (){},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18.0,
                                  semanticLabel: 'Text to announce in accessibility modes',
                                ),
                                Text( (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('next')),
                                  style: TextStyle(color: Colors.white),),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _createPdf() async {
    PdfDocument document = PdfDocument();

    final firstPage = document.pages.add();
    final secondPage = document.pages.add();
    final thirdPage = document.pages.add();


    PdfFont normalFont = PdfTrueTypeFont(await _readFontData(), 10);
    PdfFont mediumFont = PdfTrueTypeFont(await _readFontData(), 15);
    PdfFont boldTitleFont = PdfTrueTypeFont(await _readBoldFontData(), 18);
    PdfFont normalBoldFont = PdfTrueTypeFont(await _readBoldFontData(), 10);



    writeOnPdfPage(firstPage, secondPage, thirdPage, normalFont, boldTitleFont, mediumFont);


    List<int> bytes = document.save();
    document.dispose();

    print("11111");

    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  void writeOnPdfPage(firstPage, secondPage,thirdPage, normalFont, boldTitleFont, mediumFont) {
    final Size pageSize = firstPage.getClientSize();

    double currentTop = 0;

    firstPage.graphics.drawString(
      "REKLAM S??ZLE??MES??",
      boldTitleFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;

//    page.graphics.drawRectangle(
//        bounds: Rect.fromLTWH(0, 0, pageSize.width, 40),
//        pen: PdfPen(PdfColor(142, 170, 219, 255)));

    firstPage.graphics.drawString(
      "MADDE 1 - TARAFLAR:",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      '????bu Mesafeli Sat???? S??zle??mesi ("S??zle??me"); ("ALICI???) ile (???SATICI???) aras??nda a??a????da belirtilen h??k??m ve ??artlar ??er??evesinde elektronik ortamda kurulmu??tur.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 60;

    firstPage.graphics.drawString(
      '1.1. SATICI B??LG??LER?? :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 30;

    firstPage.graphics.drawString(
      'SATICI UNVANI:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'RUHARTE B??L????M TEKNOLOJ??LER?? SANAY?? VE T??CARET LTD.??T??',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Mersis Numaras??:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0735170808500001',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Adresi: ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '??mam bak??r Mah. ??utim cad. B blok no:21/1 Haliliye ??? ??anl??urfa ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Tel:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0542 207 22 47',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      '??ikayetler ????in ??rtibat Bilgisi: ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      '0542 207 22 47',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Web Adresi:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'www.osmanbaba.net',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'E- mail:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );

    firstPage.graphics.drawString(
      'info@osmanbaba.net',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;


    firstPage.graphics.drawString(
      '1.2. ALICI B??LG??LER??:',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;


    firstPage.graphics.drawString(
      'Firma ??nvan?? :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      widget._companyName,
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      ' Firma Adresi : ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      widget._companyAddress,
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      ' Firma Telefon: ',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      widget._phoneNum,
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Firma E-posta :??',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      widget._companyEmail,
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Firma Vergi Numaras?? :',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    firstPage.graphics.drawString(
      widget._companyTaxNumber,
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width * 0.33, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 50;


    firstPage.graphics.drawString(
      'MADDE 2 - KONU VE KAPSAM',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'S??zle??me, reklam verenin firmas??n??n reklam?? i??in verilecek hizmetlerin tan??mlanmas?? ve ne ??ekilde i??letilece??i ile ??al????ma ??ekil ve ko??ullar??n?? kapsamaktad??r.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    firstPage.graphics.drawString(
      'MADDE 3 - TARAFLARIN Y??K??ML??L??KLER??',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    firstPage.graphics.drawString(
      'Osmanbaba.net, 1. maddedeki ama??lar do??rultusunda Reklam Veren ile tam bir i??birli??i i??inde ??al????may??, verdi??i hizmetin kalitesini korumak ve y??kseltmek i??in her t??rl?? ??abay?? g??stermeyi kabul ve taahh??t eder.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 30;

    firstPage.graphics.drawString(
      'Reklam Veren, anla??ma kapsam?? do??rultusunda Osmanbaba.net\'e her alanda i??birli??i yapmay??, ??zellikle do??ru ve eksiksiz bilgi vermeyi, tan??mlanan hizmetin y??r??t??lmesinde Osmanbaba.net\'i tek sorumlu olarak g??rmeyi, kabul ve taahh??t eder.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 35;

    /////////////////// SECOND PAGE ////////////////////////////////

    currentTop = 0;
    secondPage.graphics.drawString(
      'MADDE 4 - OSMANBABA.NET REKLAM T??RLER??',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 40;


    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
        font: normalFont,
        cellPadding: PdfPaddings(left: 20, right: 20, top: 5, bottom: 5)
    );
    grid.columns.add(count: 4);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = "??r??n A????klamas??";
    header.cells[1].value = "S??zle??me Ba??lang???? Tarihi";
    header.cells[2].value = "S??zle??me Biti?? Tarihi";
    header.cells[3].value = "Kdv Dahil Tutar";

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = widget.name;
    row.cells[1].value = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    row.cells[2].value = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().add(Duration(days: 356)).year}";
    row.cells[3].value = widget.price;

    grid.draw(page: secondPage, bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height));
    currentTop += 100;


    secondPage.graphics.drawString(
      'Listelenen ve sitede g??sterilen hizmetler g??ncelleme yap??lana ve de??i??ene kadar ??zerinde belirtilen fiyatlar ge??erlidir. Listelenen ve sitede g??sterilen hizmet/sat???? ve fiyatlar al??c?? taraf??ndan kabul ve beyan edilir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      'MADDE 5 - ??CRET KAPSAMI VE UYGULAMASI',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "3. maddede tan??mlanan i?? ad??na belirlenen ??cret ( reklam??n sitede yay??nlanma s??resi ) ge??erlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 6 ??? S??ZLE??ME BEDEL?? VE ??DEMELER',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "5.1. Mal??n /??r??n/??r??nlerin/ Hizmetin temel ??zelliklerini (t??r??, miktar??, marka/modeli, rengi, adedi) SATICI???ya ait internet sitesinde yay??nlanmaktad??r. Sat??c?? taraf??ndan kampanya d??zenlenmi?? ise ilgili ??r??n??n temel ??zelliklerini kampanya s??resince inceleyebilirsiniz. Kampanya tarihine kadar ge??erlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      "5.1. Mal??n /??r??n/??r??nlerin/ Hizmetin temel ??zelliklerini (t??r??, miktar??, marka/modeli, rengi, adedi) SATICI???ya ait internet sitesinde yay??nlanmaktad??r. Sat??c?? taraf??ndan kampanya d??zenlenmi?? ise ilgili ??r??n??n temel ??zelliklerini kampanya s??resince inceleyebilirsiniz. Kampanya tarihine kadar ge??erlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 40;

    secondPage.graphics.drawString(
      "5.1. Mal??n /??r??n/??r??nlerin/ Hizmetin temel ??zelliklerini (t??r??, miktar??, marka/modeli, rengi, adedi) SATICI???ya ait internet sitesinde yay??nlanmaktad??r. Sat??c?? taraf??ndan kampanya d??zenlenmi?? ise ilgili ??r??n??n temel ??zelliklerini kampanya s??resince inceleyebilirsiniz. Kampanya tarihine kadar ge??erlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 7 - ANLA??MANIN SONA ERD??R??LMES??',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      "5.1. Mal??n /??r??n/??r??nlerin/ Hizmetin temel ??zelliklerini (t??r??, miktar??, marka/modeli, rengi, adedi) SATICI???ya ait internet sitesinde yay??nlanmaktad??r. Sat??c?? taraf??ndan kampanya d??zenlenmi?? ise ilgili ??r??n??n temel ??zelliklerini kampanya s??resince inceleyebilirsiniz. Kampanya tarihine kadar ge??erlidir.",
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    secondPage.graphics.drawString(
      'MADDE 8 - G??ZL??L??K',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      'Osmanbaba.net , Reklamveren\'in kendisine vermi?? oldu??u sat????, reklam, ??r??n geli??tirme ve ara??t??rma faaliyetleri ve planlar??n?? yans??tan rakamlar ve di??er bilgiler de dahil olmak ??zere t??m yaz??l?? veya s??zl?? bilgilerin gizli belgeler oldu??unu kabul eder ve t??m bilgileri, dok??manlar??, veri ve know how?? daima gizli tutar ve bunun i??in t??m tedbirleri al??r.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 60;

    secondPage.graphics.drawString(
      'MADDE 9- UYU??MAZLIKLARIN ????Z??M??',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    secondPage.graphics.drawString(
      '????bu S??zle??me ile ilgili olarak ????kabilecek ihtilaflarda ??ncelikle bu s??zle??medeki h??k??mler uygulanacak olup, bu s??zle??mede h??k??m bulunmayan hallerde ise; ilgili mevzuat h??k??mleri uygulan??r. Taraflar i??bu s??zle??meden do??abilecek ihtilaflarda OSMANBABA.NET???in defter ve kay??tlar?? ile bilgisayar kay??tlar??n??n HMK 193. maddesi anlam??nda muteber, ba??lay??c??, kesin ve m??nhas??r delil te??kil edece??ini ve bu maddenin Delil S??zle??mesi niteli??inde oldu??unu, belirtilen OSMANBABA.NET kay??tlar??n??n usul??ne uygun tutuldu??unu kabul, beyan ve taahh??t ederler \n\nBu s??zle??me, T??rkiye Cumhuriyeti kanunlar??na tabidir ve T??rkiye Cumhuriyeti kanunlar??na g??re yorumlanacakt??r. Bu s??zle??meden do??acak her t??rl?? uyu??mazl??kta ??anl??urfa ??Mahkemeleri ve ??cra M??d??rl??kleri yetkilidir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;

    /////////////////// THIRD PAGE ////////////////////////////////

    currentTop = 0;

    thirdPage.graphics.drawString(
      'MADDE 10 - ELEKTRON??K T??CAR?? ??LET??LER',
      mediumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width, pageSize.height),
    );
    currentTop += 25;

    thirdPage.graphics.drawString(
      '????bu S??zle??me ile ilgili olarak ????kabilecek ihtilaflarda ??ncelikle bu s??zle??medeki h??k??mler uygulanacak olup, bu s??zle??mede h??k??m bulunmayan hallerde ise; ilgili mevzuat h??k??mleri uygulan??r. Taraflar i??bu s??zle??meden do??abilecek ihtilaflarda OSMANBABA.NET???in defter ve kay??tlar?? ile bilgisayar kay??tlar??n??n HMK 193. maddesi anlam??nda muteber, ba??lay??c??, kesin ve m??nhas??r delil te??kil edece??ini ve bu maddenin Delil S??zle??mesi niteli??inde oldu??unu, belirtilen OSMANBABA.NET kay??tlar??n??n usul??ne uygun tutuldu??unu kabul, beyan ve taahh??t ederler \n\nBu s??zle??me, T??rkiye Cumhuriyeti kanunlar??na tabidir ve T??rkiye Cumhuriyeti kanunlar??na g??re yorumlanacakt??r. Bu s??zle??meden do??acak her t??rl?? uyu??mazl??kta ??anl??urfa ??Mahkemeleri ve ??cra M??d??rl??kleri yetkilidir.',
      normalFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(25, currentTop, pageSize.width - 25, pageSize.height),
    );
    currentTop += 50;
  }

  Future<List<int>> _readFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<List<int>> _readBoldFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<List<int>> _readItalicFontData() async {
    final ByteData bytes = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

}
