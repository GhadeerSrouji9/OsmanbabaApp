import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'dart:html';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osmanbaba/pages/auth/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/helpers/globals.dart';
import '../second.dart';
import 'package:osmanbaba/pages/auth/signup_customer.dart';
import 'package:osmanbaba/pages/auth/signup_seller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/app_localization.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {

  final Map<String, dynamic> countriesArgs;
  SignUp(this.countriesArgs);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }

}

class _SignUpState extends State<SignUp> {

  final customerNameTextFieldController = TextEditingController();
  final customerEmailTextFieldController = TextEditingController();
  final customerPasswordTextFieldController = TextEditingController();
  final customerPasswordConfirmTextFieldController = TextEditingController();
  final customerPhoneNumTextFieldController = TextEditingController();
  String selectedCustomerCountry;

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

  Map<String, dynamic> localCountriesArgs;
  List<String> countriesList = [];
  List<String> countryIdsList = [];

  int countryIndex = null;
  int cityIndex = null;
  int areaIndex = null;
  int districtIndex = null;
  int mahallaIndex = null;


  static final String assetsURL = 'assets/imgs/';
  int _state = 0;
  bool isLoading = false;
  bool callInit = true;
  int visitorsTotal;
  bool isVisitorsNumLoading = true;

  Future<void> updateVisitorCounter() async {
    if(callInit) {
      callInit = false;
      final response = await http.get(Uri.parse(webURL + 'api/AddCounter'));

      var decoded = jsonDecode(response.body);

      if (decoded["status"]) {
        setState(() {
          visitorsTotal = decoded["description"];
          isVisitorsNumLoading = false;
          print("donnnnnnnnnnnnnnnnnnne");
        });
      } else {
        throw Exception('Failed to load');
      }
    }
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
      print("OOkkkkkkk00 " + countryId.toString());
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


  Future<void> makeSellerSignUpPostRequest(name, email, password, phoneNum , adminName, adminPhoneNumber, website) async {

    final url = Uri.parse(webURL + "api/RegisterCompany");
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

    request.files.add(
        http.MultipartFile('logo',
        File(_logoImageFile.path).readAsBytes().asStream(),
            File(_logoImageFile.path).lengthSync(),
          filename: _logoImageFile.path.split("/").last
        )
    );

    request.files.add(
        http.MultipartFile('Businness_Lecen',
            File(_logoImageFile.path).readAsBytes().asStream(),
            File(_logoImageFile.path).lengthSync(),
            filename: _logoImageFile.path.split("/").last
        )
    );

    request.files.add(
        http.MultipartFile('industrial_Lecen',
            File(_logoImageFile.path).readAsBytes().asStream(),
            File(_logoImageFile.path).lengthSync(),
            filename: _logoImageFile.path.split("/").last
        )
    );

  //  request.files.addAll(iterable);

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

  @override
  void initState(){
    super.initState();
    if(widget.countriesArgs != null){
      localCountriesArgs = widget.countriesArgs;
      print("not nullllllllllll");

      countriesList = localCountriesArgs["countries"];
      countryIdsList = localCountriesArgs["countryIds"];
      print(countriesList);
//      categoryDropdownValue = categoriesList[0];
//      productDropdownValue = productsList[0];
    }
    updateVisitorCounter();

  }

  //
  bool areMatched = true;

  @override
  void dispose() {
    super.dispose();
  }

//  lang() async {
//    fetchLanguagePreference();
//    print('___LOGIN localeOf lang: ' + Localizations.localeOf(context).toString());
//  }

  @override
  Widget build(BuildContext context) {
//    lang();
    print('___LOGIN Localizations lang: ' + Localizations.localeOf(context).toString());

    return MaterialApp(
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

      supportedLocales: [
        Locale('ar', 'SAR'),
        Locale('en', 'US'),
        Locale('tr', 'TR'),
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      locale: isLanguageSpecified ? globalLocale : null,

      debugShowCheckedModeBanner: false,
      
      home: DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context)
          {
            return Scaffold(
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
              body: Column(
                children: [
                  TabBar(
                    labelColor: Colors.orange,
                    indicatorColor: Colors.orange,
                    tabs: <Widget>[
                      Tab(
                        text: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('signUpAsCustomerButton'),
                      ),
                      Tab(
                        text: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('signUpAsSellerButton'),
                      ),

                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                        children: <Widget>[
                          SingleChildScrollView(
                            child: Container(
                              margin: EdgeInsets.only(top: 32.0, left: 16.0, bottom: 16.0, right: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  // CUSTOMER NAME
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: Text(
                                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerNameField'),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          height: 50.0,
                                          child: TextField(
                                            controller: customerNameTextFieldController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.transparent,),

                                  // CUSTOMER EMAIL
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: Text(
                                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmailField'),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          height: 50.0,
                                          child: TextField(
                                            controller: customerEmailTextFieldController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.transparent,),

                                  // CUSTOMER PASSWORD
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: Text(
                                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordField'),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          height: 50.0,
                                          child: TextField(
                                            controller: customerPasswordTextFieldController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.transparent,),

                                  // CUSTOMER PASSWORD CONFIRMATION
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: Text(
                                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordConfirmField'),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          height: 50.0,
                                          child: TextField(
                                            controller: customerPasswordConfirmTextFieldController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.transparent,),
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerFacebookUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: facebookTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      //this widget gonna change to droplist
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerTwitterUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: twitterTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),
//
//                Container(
//                  width: MediaQuery.of(context).size.width,
//                  margin: EdgeInsets.only(bottom: 8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      //this widget gonna change to droplist
//                      Container(
//                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
//                        child: Text(
//                          Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerInstagramUsernameField'),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.90,
//                        height: 50.0,
//                        child: TextField(
//                          controller: instagramTextFieldController,
//                          decoration: InputDecoration(
//                            border: OutlineInputBorder(
//
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                Divider(color: Colors.transparent,),

                                  // CUSTOMER PHONE NUMBER
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                          child: Text(
                                            Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPhoneNumberField'),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          height: 50.0,
                                          child: TextField(
                                            controller: customerPhoneNumTextFieldController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.transparent,),

                                  // COUNTRIES DROPDOWN SEARCH CUSTOMER
                                  DropdownSearch<String>(
                                    mode: Mode.DIALOG,
                                    showSelectedItem: true,
                                    showSearchBox: true,
                                    showClearButton: false,
                                    items: countriesList, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                    label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCountry'),
                                    onChanged: (val) {
                                      setState(() async{
                                        int currentIndex = countriesList.indexOf(val);
                                        selectedCustomerCountry = countryIdsList[currentIndex];
//                                        countryIndex = currentIndex;
//                        countyIdsList = ["s"];
                                      });
                                    },
                                    selectedItem: null,
                                  ),

                                  // CUSTOMER SIGN UP BUTTON
                                  Container(
                                    height: 50.0,
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () async{

                                        String name = customerNameTextFieldController.text;
                                        String email = customerEmailTextFieldController.text;
                                        String password = customerPasswordTextFieldController.text;
                                        String passwordConfirm = customerPasswordConfirmTextFieldController.text;
//                    String facebook = facebookTextFieldController.text;
//                    String twitter = twitterTextFieldController.text;
//                    String instagram = instagramTextFieldController.text;
                                        String phoneNum = customerPhoneNumTextFieldController.text;

                                        print((name == "").toString() + " " + (email == "").toString() + " " + (password == "").toString() + " " + " " + (phoneNum == "").toString());

                                        if(name == "" || email == "" || password == "" || phoneNum == "" || selectedCustomerCountry == "") {
                                          print((name == "").toString() + " " + (email == "").toString() + " " + (password == "").toString() + " " + (phoneNum == "").toString());
                                          Fluttertoast.showToast(
                                              msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerEmptyFields'),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.white70,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        }
                                        else if(password != passwordConfirm){
                                          Fluttertoast.showToast(
                                              msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerPasswordsNoMatch'),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.white70,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        }
                                        else {
                                          await makeCustomerSignUpPostRequest(name, email, password, phoneNum, selectedCustomerCountry);
                                        }
//                    await makePostRequest();

//                    final UserModel userModel = await createUser(name, email, password, countryId, phoneNum);
                                      },
                                      child: Text(
                                        Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('customerSignUp'),
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
//                _imageFile == null ?  Text('No Image') : Image.file(_imageFile)
                                ],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
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
                                    showClearButton: false,
                                    items: countriesList, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                    label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCountry'),
                                    onChanged: (val) {
                                      setState(() async{
                                        isCityDropdownEndabled = true;
                                        int currentIndex = countriesList.indexOf(val);
                                        countryIndex = currentIndex;
                                        await updateCityById(countryIdsList[currentIndex]);
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
                                    showClearButton: false,
                                    items: citiesList, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                    label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
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
                                    showClearButton: false,
                                    items: areasList,
                                    label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectArea'),
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
                                    showClearButton: false,
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
                                    showClearButton: false,
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
                        ],
                    ),
                  ),
                ],
              ),
            );
          }
          )
      ),
    );
  }

  Future<void> storeTokenPreference(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return Text(
        Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('signUpAsSellerButton'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[100],
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


  Future<void> makeCustomerSignUpPostRequest(name, email, password, phoneNum, selectedCustomerCountry) async{

    final url = Uri.parse(webURL + "api/RegisterUser");
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"UserName": "' + name + '",' + ' "Email": "' + email + '",' + ' "Password": "' +  password + '",'  + ' "PhoneNum": "' +  phoneNum + '",'  + ' "CountryID": "' +  selectedCustomerCountry + '"' + '}';
    print("jjjjjjjjjjjjjjjjjjjj " + json);
    final response = await post(url, headers: headers, body: json);

    print(json);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    var decoded = jsonDecode(response.body);

    if(decoded["message"] == "Check your Email"){
      Fluttertoast.showToast(
          msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastEmailInvalid'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    } else{
      Navigator.pop(context);
    }
  }

}
