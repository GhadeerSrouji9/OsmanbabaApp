import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../second.dart';
import '../../helpers/app_localization.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/helpers/globals.dart';
import 'login.dart';

class SignUpSeller extends StatefulWidget {
  final Map<String, dynamic> sellerArgsMap;
  SignUpSeller(this.sellerArgsMap);

  @override
  State<StatefulWidget> createState() {
    return _SignUpSellerState();
  }
}

class _SignUpSellerState extends State<SignUpSeller> {
  final nameSellerTextFieldController = TextEditingController();
  final emailSellerTextFieldController = TextEditingController();
  final passwordSellerTextFieldController = TextEditingController();
  final passwordSellerConfirmTextFieldController = TextEditingController();
  final phoneNumSellerTextFieldController = TextEditingController();
  final facebookSellerTextFieldController = TextEditingController();
  final twitterSellerTextFieldController = TextEditingController();
  final instagramSellerTextFieldController = TextEditingController();
  final adminNameSellerTextFieldController = TextEditingController();
  final adminPhoneNumberSellerTextFieldController = TextEditingController();
  final websiteSellerTextFieldController = TextEditingController();

  String countryDropdownValue = "";
  String cityDropdownValue = "";
  bool isCityDropdownEndabled = false;
  String areaDropdownValue = "";
  bool isAreaDropdownEndabled = false;
  String districtDropdownValue = "";
  bool isDistrictDropdownEndabled = false;
  String mahallaDropdownValue = "";
  bool isMahallaDropdownEndabled = false;

  static const LOGO_FILE = 0;
  static const BUSINESS_FILE = 1;
  static const INDUSTRIAL_FILE = 2;

  File _logoImageFile = null;
  File _businessImageFile = null;
  File _industrialImageFile = null;

  String imagePath = 'Upload logo';

  List<String> citiesList = [];
  List<String> cityIdsList = [];

  List<String> areasList = [];
  List<String> areaIdsList = [];

  List<String> districtList = [];
  List<String> districtIdsList = [];

  List<String> mahallaList = [];
  List<String> mahallaIdsList = [];

  Map<String, dynamic> localAdArgs;
  List<String> countriesList = [];
  List<String> countryIdsList = [];

  int countryIndex = null;
  int cityIndex = null;
  int areaIndex = null;
  int districtIndex = null;
  int mahallaIndex = null;

  @override
  void initState() {
    if(widget.sellerArgsMap != null){
      localAdArgs = widget.sellerArgsMap;
      print("not nullllllllllll");

      countriesList = localAdArgs["countries"];
      countryIdsList = localAdArgs["countryIds"];
      print(countriesList);
//      categoryDropdownValue = categoriesList[0];
//      productDropdownValue = productsList[0];
    }

    super.initState();
//    this.fetchCategories();
  }

  Future _getImage(fileCode) async {
    print("jjjjjjjjjj logo: " + (_logoImageFile == null).toString() + " busi: " + (_businessImageFile == null).toString() + " indi: " + (_industrialImageFile == null).toString());

    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      switch (fileCode) {
        case LOGO_FILE:
          _logoImageFile = image;
          imagePath = 'Selected file: ' + _logoImageFile.path;
          break;
        case BUSINESS_FILE:
          _businessImageFile = image;
          imagePath = 'Selected file: ' + _businessImageFile.path;
          break;
        case INDUSTRIAL_FILE:
          _industrialImageFile = image;
          imagePath = 'Selected file: ' + _industrialImageFile.path;
          break;
      }
    });
  }

  Future<List<String>> updateCityById(countryId) async{
    final url = Uri.parse(webURL + 'api/ListCityBayCountry');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ countryId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      print("OOkkkkkkk00");
      var decoded = jsonDecode(response.body);
      print(decoded);
      decoded = decoded["description"];
      setState(() {
        citiesList = [];
        cityIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          citiesList.add(decoded[i]["name"]);
          print("hhhhhhhhhhhh" + citiesList[i]);
          cityIdsList.add(decoded[i]["id"]);
        }
      });
    } else {
      print("NNNNNNnnnnnnnooooooooOOOOOOOOO");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return citiesList;
  }

  Future<List<String>> updateAreaById(cityId) async{
    final url = Uri.parse(webURL + 'api/ListAreaBayCity');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ cityId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      print("OOkkkkkkk00");
      var decoded = jsonDecode(response.body);
      print(decoded);
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
      print("NNNNNNnnnnnnnooooooooOOOOOOOOO");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return areasList;
  }

  Future<List<String>> updateDistrictById(areaId) async{
    final url = Uri.parse(webURL + 'api/ListSemetBayArea');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ areaId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      print("OOkkkkkkk00");
      var decoded = jsonDecode(response.body);
      print(decoded);
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
      print("NNNNNNnnnnnnnooooooooOOOOOOOOO");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return districtList;
  }

  Future<List<String>> updateMahallaById(districtId) async{
    final url = Uri.parse(webURL + 'api/ListMahallaBaySemet');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ districtId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      print("OOkkkkkkk00");
      var decoded = jsonDecode(response.body);
      print(decoded);
      decoded = decoded["description"];
      setState(() {
        mahallaList = [];
        mahallaIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          mahallaList.add(decoded[i]["name"]);
          print("hhhhhhhhhhhh" + mahallaList[i]);
          mahallaIdsList.add(decoded[i]["id"]);
        }
      });
    } else {
      print("NNNNNNnnnnnnnooooooooOOOOOOOOO");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return mahallaList;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameSellerTextFieldController.dispose();
    emailSellerTextFieldController.dispose();
    passwordSellerTextFieldController.dispose();
    passwordSellerConfirmTextFieldController.dispose();
    phoneNumSellerTextFieldController.dispose();
    facebookSellerTextFieldController.dispose();
    twitterSellerTextFieldController.dispose();
    instagramSellerTextFieldController.dispose();
    adminNameSellerTextFieldController.dispose();
    adminPhoneNumberSellerTextFieldController.dispose();
    websiteSellerTextFieldController.dispose();
    super.dispose();
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
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.orange,
//            displayColor: Colors.blue,
            ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: InkWell(
                onTap: (){
                  Navigator.push(
                      this.context,
                      new MaterialPageRoute(builder: (context) => new Login())
                  );
                } ,
                child: Image(
                  image: AssetImage('assets/imgs/footerob.png'),
                  height: 50,
                ),
              ),
            ),
          ),

        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
                top: 32.0, left: 16.0, bottom: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerNameField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: nameSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerEmailField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: emailSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerPasswordField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: passwordSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerPasswordConfirmField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: passwordSellerConfirmTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerPhoneNumberField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: phoneNumSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(
//                                  context, AppLocalizations)
//                              .getTranslation('sellerFacebookUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: facebookTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(
//                  color: Colors.transparent,
//                ),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(
//                                  context, AppLocalizations)
//                              .getTranslation('sellerTwitterUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: twitterTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(
//                  color: Colors.transparent,
//                ),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(
//                                  context, AppLocalizations)
//                              .getTranslation('sellerInstagramUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: instagramTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(
//                  color: Colors.transparent,
//                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerAdminUsernameField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: adminNameSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerAdminTelUsernameField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: adminPhoneNumberSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                              context, AppLocalizations)
                              .getTranslation('sellerWebsiteField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: TextField(
                          controller: websiteSellerTextFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

// Image Upload Field
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                              context, AppLocalizations)
                              .getTranslation('sellerLogoField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            _getImage(LOGO_FILE);
                          },
                          child: Text(
                            Localizations.of<AppLocalizations>(
                                context, AppLocalizations)
                                .getTranslation('logoButton'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerBusinessLicenseField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            _getImage(BUSINESS_FILE);
                          },
                          child: Text(
                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerUploadBusinessLicenseField'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: Text(
                          Localizations.of<AppLocalizations>(
                                  context, AppLocalizations)
                              .getTranslation('sellerIndustrialLicenseField'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            _getImage(INDUSTRIAL_FILE);
                          },
                          child: Text(
                            Localizations.of<AppLocalizations>(
                                    context, AppLocalizations)
                                .getTranslation(
                                    'sellerUploadIndustrialLicenseField'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                ),

                // COUNTRIES DROPDOWN SEARCH
                DropdownSearch<String>(
                    mode: Mode.DIALOG,
                    showSelectedItem: true,
                    showSearchBox: true,
                    showClearButton: true,
                    items: countriesList, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                    label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCountry'),
                    hint: "country in menu mode",
                    onChanged: (val) {
                      setState(() {
                        isCityDropdownEndabled = true;
                        int currentIndex = countriesList.indexOf(val);
                        countryIndex = currentIndex;
                        updateCityById(countryIdsList[currentIndex]);
//                        countyIdsList = ["s"];
                      });
                    },
                    selectedItem: null,
                ),

                Divider(
                  color: Colors.transparent,
                ),

                // CITIES DROPDOWN SEARCH
                DropdownSearch<String>(
                  enabled: isCityDropdownEndabled,
                  mode: Mode.DIALOG,
                  showSelectedItem: true,
                  showSearchBox: true,
                  showClearButton: true,
                  items: citiesList, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                  label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
                  hint: "city in menu mode",
                  onChanged: (val) {
                    setState(() {
                      isAreaDropdownEndabled = true;
                      int currentIndex = citiesList.indexOf(val);
                      cityIndex = currentIndex;
                      print("LLLLLLLLLLLLLLLLLLL " + cityIdsList[currentIndex].toString());
                      updateAreaById(cityIdsList[currentIndex]);
                    });
                  },
                  selectedItem: null,
                ),

                Divider(
                  color: Colors.transparent,
                ),

                // AREAS DROPDOWN SEARCH
                DropdownSearch<String>(
                  enabled: isAreaDropdownEndabled,
                  mode: Mode.DIALOG,
                  showSelectedItem: true,
                  showSearchBox: true,
                  showClearButton: true,
                  items: areasList,
                  label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectArea'),
                  hint: "Area in menu mode",
                  onChanged: (val) {
                    setState(() {
                      isDistrictDropdownEndabled = true;
                      int currentIndex = areasList.indexOf(val);
                      areaIndex = currentIndex;
                      print("LLLLLLLLLLLLLLLLLLL " + areaIdsList[currentIndex].toString());
                      updateDistrictById(areaIdsList[currentIndex]);
                    });
                    },
                  selectedItem: null,
                ),

                Divider(
                  color: Colors.transparent,
                ),

                // DISTRICT DROPDOWN SEARCH
                DropdownSearch<String>(
                  enabled: isDistrictDropdownEndabled,
                  mode: Mode.DIALOG,
                  showSelectedItem: true,
                  showSearchBox: true,
                  showClearButton: true,
                  items: districtList,
                  label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectDistrict'),
                  hint: "District in menu mode",
                  onChanged: (val) {
                    setState(() {
                      isMahallaDropdownEndabled = true;
                      int currentIndex = districtList.indexOf(val);
                      districtIndex = currentIndex;
                      print("LLLLLLLLLLLLLLLLLLL " + districtIdsList[currentIndex].toString());
                      updateMahallaById(districtIdsList[currentIndex]);
                    });
                    },
                  selectedItem: null,
                ),

                Divider(
                  color: Colors.transparent,
                ),

                // MAHALLA DROPDOWN SEARCH
                DropdownSearch<String>(
                  enabled: isMahallaDropdownEndabled,
                  mode: Mode.DIALOG,
                  showSelectedItem: true,
                  showSearchBox: true,
                  showClearButton: true,
                  items: mahallaList,
                  label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectNeighborhood'),
                  hint: "Mahalla in menu mode",
                  onChanged: (val) {
                    int currentIndex = mahallaList.indexOf(val);
                    mahallaIndex = currentIndex;
                  },
                  selectedItem: null,
                ),

                //Sign up
                Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String name = nameSellerTextFieldController.text;
                      String email = emailSellerTextFieldController.text;
                      String password = passwordSellerTextFieldController.text;
                      String phoneNum = phoneNumSellerTextFieldController.text;
                      String passwordConfirm = passwordSellerConfirmTextFieldController.text;
//                      String facebook = facebookTextFieldController.text;
//                      String twitter = twitterTextFieldController.text;
//                      String instagram = instagramTextFieldController.text;
                      String adminName = adminNameSellerTextFieldController.text;
                      String adminPhoneNumber = adminPhoneNumberSellerTextFieldController.text;
                      String website = websiteSellerTextFieldController.text;


                      if (name == "" || email == "" || password == "" || phoneNum == "" || adminName == ""  || adminPhoneNumber == "" || website == ""
                          || _logoImageFile == null || _businessImageFile == null || _industrialImageFile == null
                          || countryIndex == null || cityIndex == null || areaIndex == null || mahallaIndex == null) {
//                        print("TTTTTTTTTTTTTTTTTTT" + (name == "").toString() + " " + (email == "").toString() + " " + (password == "").toString() + " " + (facebook == "").toString() + " " + (twitter == "").toString() + " " + (instagram == "").toString() + " " + (phoneNum == "").toString());

                        print("TTTTTTTTTTTTTTTTTTT " + (countryIndex == null).toString() + " zzzzzzzzzzz " + (cityIndex == null).toString() + " zzzzzzzzzzz "  + (areaIndex == null).toString() + " zzzzzzzzzzz " + (mahallaIndex == null).toString() + " zzzzzzzzzzz ");
                        Fluttertoast.showToast(
                            msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmptyFields'),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white70,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      } else if (password != passwordConfirm) {
                        Fluttertoast.showToast(
                            msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordsNoMatch'),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white70,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      } else {
                        makeSellerSignUpPostRequest(name, email, password, phoneNum, adminName, adminPhoneNumber, website);
                      }
                    },
                    child: Text(
                      Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sellerSignUp'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> makeSellerSignUpPostRequest(name, email, password, phoneNum , adminName, adminPhoneNumber, website) async {

    final url = Uri.parse("http://88.225.215.42:8083/api/RegisterCompany");
//    final headers = {"Content-type": "application/json"};
//    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
//    final json = '{"UserName": "' + name + '",' + ' "Email": "' + email + '",' + ' "Password": "' + password + '",' +
//        ' "Facebook": "' + facebook + '",' + ' "Twitter": "' + twitter + '",' + ' "Instagram": "' + instagram + '",' + ' "PhoneNum": "' + phoneNum + '"' +
//        ' "Business_Lecen": "' + _businessImageFile.toString() + '",' + '}';
//    final response = await post(url, headers: headers, body: json);

    var request = http.MultipartRequest(
      'POST', url
    );

    request.headers['Content-type'] ='multipart/form-data';
//    request.headers['Content-type'] ='application/json';
    request.fields['UserName'] = name;
    request.fields['Email'] = email;
    request.fields['Password'] = password;
    request.fields['PhoneNumber'] = phoneNum;

//    request.fields['Facebook'] = facebook;
//    request.fields['Twitter'] = twitter;
//    request.fields['Instgram'] = instagram;
    request.fields['adminName'] = adminName;
    request.fields['AdminTel'] = adminPhoneNumber;
    request.fields['WebSite'] = website;
    print(
        countryIdsList[countryIndex] + " " +
        cityIdsList[cityIndex] + " " +
        areaIdsList[areaIndex] + " " +
        mahallaIdsList[mahallaIndex]
    );
    request.fields['CountryID'] = countryIdsList[countryIndex];
    request.fields['CityID'] = cityIdsList[cityIndex];
    request.fields['AreaID'] = areaIdsList[areaIndex];
    request.fields['MahallaID'] = mahallaIdsList[mahallaIndex];

//    request.files.add(_businessImageFile);
    var multipart = [];

    multipart.add(MultipartFile.fromBytes(
        "Logo",
        _logoImageFile.readAsBytesSync())
    );
    multipart.add(MultipartFile.fromBytes(
        "Businness_Lecen",
        _businessImageFile.readAsBytesSync())
    );
    multipart.add(MultipartFile.fromBytes(
        "industrial_Lecen",
        _industrialImageFile.readAsBytesSync())
    );

    Iterable<MultipartFile> iterable = [multipart[0], multipart[1], multipart[2]];

    print(iterable);

    request.files.addAll(iterable);

    print(request.fields);

    print("aaaaalmost there");

    try{
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      print("tryyy try try: " + res.body);
      Map<String, dynamic> dep = jsonDecode(utf8.decode(res.bodyBytes));
      if(dep["message"] == "Seccess") {
        print("stonksssss");
      }
    } catch(error) {
      print("ccccatch error " + error.toString());
    }
  }
}
