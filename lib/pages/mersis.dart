import 'dart:async';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:osmanbaba/Models/city.dart';
import 'package:osmanbaba/Models/companyTarget.dart';
import 'package:osmanbaba/Models/subject.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/container.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SignalRHelper.dart';
class Mersis extends StatefulWidget {
  final name;
  const Mersis({Key key, this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Mersis();
  }
}

class _Mersis extends State<Mersis> {
  int val = 0;
  DateTime selectedDate = DateTime.now();
  final _advancedDrawerController = AdvancedDrawerController();
  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  int _state = 0;
  int _fabState = 0;
  bool isLoading = false;
  bool isIlceDropdownEndabled = false;
  SignalRHelper signalR = new SignalRHelper();
  var scrollController = ScrollController();
  var txtController = TextEditingController();
  DateTime _dateTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isMahallaDropdownEndabled = false;
  int mahallaIndex = null;
  List<String> mahallaList = [];
  String ortakDropdownValue;
  String yetkilendrmeDropdownValue;
  String gorevDagitimDropdownValue;
  String gorevSuresiDropdownValue;
  String dropdownValue1 = 'Ticaret Sicili Müdürlüğü Ekle';
  List<String> altTurDropDown ;
  List<String> altTurDropDown1 = ['Şanlıurfa Ticaret Sicil Müdürlüğü'];
  List<String> altTurDropDown2 ;
  int altTurDropDownIndex = 0; // AddCompanyType API body, CompanyTypeID
  int altTurDropDownIndex2 = 0; // AddCompanyType API body, CompanyTypeID

  String altTurDrop;
  String altTurDrop2;
  String altTurDrop1;
  String dropDownCity;
  String dropDownArea;
  String dropDownDistrict;
  String title = "";
  String dropDownTitleS;
  String dropDownTitleS1="";
  String dropDownTitleSW;
  String dropDownTitleSW1="";
  String selectedCustomerCountry;
  List<String> countryIdsList = [];

  List<String> anaAreasList = [];
  List<String> anaAreaIdsList = [];
  List<String> anaCitiesList = [];
  List<String> anaCityIdsList = [""];

  List<String> addressAreasList = [];
  List<String> addressAreaIdsList = [];
  List<String> addressCitiesList = [];
  List<String> addressCityIdsList = [""];

  int ilceId = 0;
  int ilceId2 = 0;
  int districtIndex = null;
  bool isAreaDropdownEndabled = true;
  bool isDistrictDropdownEndabled = false;
  int areaIndex = null;
  List<String> districtList = [];
  List<String> ortakDropdownValueListName = [];
  List<String> ortakDropdownValueListId = [];
  List<String> yetkilendrmeDropdownValueList = ["Müdür"]  ;
  List<String> gorevDagitimDropdownValueList = ["Tek Görevli"]  ;
  List<String> gorevSuresiDropdownValueList = ["Sınırsız"]  ;
  List<String> districtIdsList = [];
  List<String> mahallaIdsList = [];
  List<String> naceUniqueCodeList = [];
  List<String> naceUniqueIdList = [];

  List<Map<String, dynamic>> kindList = [];
  List<Map<String, dynamic>> languageList = [];
  List<Map<String, dynamic>> OrtakList = [];
  String targetCompany = "";
  String anaDetayCityId = "";
  String anaDetayAreaId = "";
  String companyId = "";
  FocusNode _emailFocus = FocusNode();

  final List<String> dropdownNameItems=[""];
  final ortakUyrukController = TextEditingController();
  final ortakAdController = TextEditingController();
  final ortakSoyadController = TextEditingController();
  final ortakTcController = TextEditingController();
  final ortakSeriNoController = TextEditingController();
  final ortakCuzdanNoController = TextEditingController();
  final ortakMaviKartController = TextEditingController();
  final ortakSerialNoController = TextEditingController();
  final ortakDocumentNoController = TextEditingController();
  final ortakPasaportNoController = TextEditingController();
  final unvanController = TextEditingController();
  final adreesController = TextEditingController();
  final naceController = TextEditingController();
  final sermayeController = TextEditingController();
  final _companyEmail = TextEditingController();
  final sermayeController1 = TextEditingController();
  final _emailController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  bool isAnaDetay =false,isOrtak = false,isUnvan = false,isAdrees = false,
      isSirketAmaci = false,isNACE = false ,isIlan = false,isSermaye = false,isMudur= false,
      isKarinVeDagitma = false,isSirketTemsili=false,isYedek =false,isSirketSuresi=false,
      isGenelkurul=false,isYasalHukumlar = false;

  String naceUniqueCode ="";
  String naceUniqueId ="";
  String ortakId="";
  int AnaDetay =0,Unvan = 0,Adrees = 0, SirketAmaci = 0,NACE = 0 ,Ilan = 0,Mudur= 0;
  List<CompanyTarget> _targetList = [];
  String token , username,email ;
  String formattedDate;
  String formattedTime;
  List<CompanyTarget> targetList = [];
  List<CompanyTarget> targetList1 = [];
  List<String> targetListId = [];

  List<String> altTurDropDownVisit = ['Tercümanlık Hizmeti', 'Şirket Kuruluş Hizmeti', 'E_imza Hizmeti', 'Paketler', 'Diğer'];
  int altTurDropDownIndexVisit = 0;


  void translateAltTurDropDown(){
    altTurDropDown =[(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb1')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb2')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb3')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb4')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sebeb5')),

    ];
//add
  }

  void translateAltTurDropDown2(){
    altTurDropDown2 =[(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ortakLimitid')),
      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tekLimited')),
    ];

  }
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
    if (picked_s != null && picked_s != selectedTime )
      setState(() {
        selectedTime = picked_s;
        formattedTime = selectedTime.format(context);
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
        anaAreasList = [];
        anaAreaIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          anaAreasList.add(decoded[i]["name"]);
          anaAreaIdsList.add(decoded[i]["id"]);
        }
      });

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return anaAreasList;
  }

  Future<List<String>> updateMahallaById(districtId) async{
    final url = Uri.parse(webURL + 'api/ListMahallaBaySemet');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{"id": "'+ districtId + '"}';
    final response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"];
      setState(() {
        mahallaList = [];
        mahallaIdsList = [];
        for(int i = 0; i < decoded.length; i++){
          mahallaList.add(decoded[i]["name"]);
          mahallaIdsList.add(decoded[i]["id"]);
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
    return mahallaList;
  }

  Future<List <City>> getCities() async{

    final url = Uri.parse(webURL + 'api/ListCityBayCountry');
    final headers = {"Content-type": "application/json"};
    // TODO: MAKE SURE THIS THING WORKS OUT RIGHT
    final json = '{ "id": "31a92a64-a21c-4cfd-bb55-466cb4c495fb" }';
    final response = await post(url, headers: headers, body: json);
    var jsonData = jsonDecode(response.body);

    jsonData = jsonData["description"];

    setState(() {
      anaCitiesList = [];
      anaCityIdsList = [];
      for(int i = 0; i < jsonData.length; i++){
        anaCitiesList.add(jsonData[i]["name"]);
        anaCityIdsList.add(jsonData[i]["id"]);
      }
    });

    List<City> cities = [];

    for (var i in jsonData) {
      City city = City(i["id"], i["name"], i["countryID"]);
      cities.add(city);
    }
    return cities;
  }

  Future<void> listCompanySubject() async{

    final url = await http.get(Uri.parse(webURL + 'api/ListCompanySubject'));

    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;

    List<Subject> subjectList = [];
    var response = jsonDecode(url.body);
    if(response['status']){
      response = response["description"];
      for (var i in response) {
        Subject subject = Subject(i["id"], i["name_$currentLocale"]);
        subjectList.add(subject);
      }
      return subjectList;
    }
  }

  Future<void> listCompanyTarget() async{

    final url = await http.get(Uri.parse(webURL + 'api/ListTarget'));

    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;


    var response = jsonDecode(url.body);
    if(response['status']){
      response = response["description"];
      for (var i in response) {
        CompanyTarget target = CompanyTarget(i["id"], i["title_$currentLocale"], i["subject_$currentLocale"]);
        targetList.add(target);
      }
      return targetList;
    }
  }

  Future<void> listSpecialWord() async{

    final url = await http.get(Uri.parse(webURL + 'api/ListCompanySpecialWord'));

    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;

    List<Subject> subjectList = [];
    var response = jsonDecode(url.body);
    if(response['status']){
      response = response["description"];
      for (var i in response) {
        Subject subject = Subject(i["id"], i["name_$currentLocale"]);
        subjectList.add(subject);
      }
      return subjectList;
    }
  }

  Future<void> storeLanguagePreference(val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);
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

  Future<void> listNaceCode() async{

    final url = await http.get(Uri.parse(webURL + 'api/ListNace'));

    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations)
        .locale
        .languageCode;
    List<String> naceCodeList = [];
    var response = jsonDecode(url.body);
    if(response['status']){
      response = response["description"];
      for (var i in response) {
        naceCodeList.add(i["desc_${currentLocale.toUpperCase()}"]);
        naceUniqueCodeList.add(i["uniqueCode"]);
        naceUniqueIdList.add(i["id"]);
      }
      return naceCodeList;
    }
  }

  Future<void> listPartner() async{
    ortakDropdownValueListName = [];
    ortakDropdownValueListId = [];
    final url = Uri.parse(webURL + 'api/ListPartnerByCompanyID');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id": companyId
        }

    ));

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"];
      for(int i =0;i<decoded.length; i++){
        ortakDropdownValueListName.add(decoded[i]["name"]);
        ortakDropdownValueListId.add(decoded[i]["id"]);
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future <void> addCompanyType() async{
    String userId = await fetchIdPreference();
    final url = Uri.parse(webURL + 'api/AddCompanyType');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "CompanyTypeID": altTurDropDownIndex,
          "UserId": userId,
          "CityID": anaDetayCityId,
          "AreaId": anaDetayAreaId
        }
    ));
    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded["description"]["companyID"];
      setState(() {
        companyId = decoded;
        isAnaDetay = true;
      });
    } else {
      throw Exception('Failed to load');
    }
  }

  Future <void> addPartner(int val)async{
    final url = Uri.parse(webURL + 'api/AddPartner');
    final headers = {"Content-type": "application/json"};

    var response;
    if(val == 0 ){
      response = await post(url, headers: headers, body:jsonEncode(
          {
            "Nationality": ortakUyrukController.text,
            "TcNo": ortakTcController.text,
            "CuzdanNo": ortakCuzdanNoController.text,
            "CuzdanSerial": ortakSeriNoController.text,
            "Name" : ortakAdController.text,
            "LastName":ortakSoyadController.text,
            "id" : companyId,
          }
      ));
    }else if(val == 1 ){
      response = await post(url, headers: headers, body:jsonEncode(
          {
            "Nationality1": ortakUyrukController.text,
            "TcNo1": ortakTcController.text,
            "Serialno": ortakSerialNoController.text,
            "Name1" : ortakAdController.text,
            "LastName1":ortakSoyadController.text,
            "id" : companyId,
          }
      ));
    }else if(val == 2 ){
      response = await post(url, headers: headers, body:jsonEncode(
          {
            "Nationality2": ortakUyrukController.text,
            "TcNo2": ortakTcController.text,
            "DocumentNo": ortakDocumentNoController.text,
            "Name2" : ortakAdController.text,
            "LastName2":ortakSoyadController.text,
            "id" : companyId,
          }
      ));
    }else if(val == 3 ){
      response = await post(url, headers: headers, body:jsonEncode(
          {
            "Nationality3": ortakUyrukController.text,
            "PasaportNo" : ortakPasaportNoController.text,
            "Name3" : ortakAdController.text,
            "LastName3":ortakSoyadController.text,
            "id" : companyId,
          }
      ));
    }else if(val == 4 ){
      response = await post(url, headers: headers, body:jsonEncode(
          {
            "Nationality4": ortakUyrukController.text,
            "BlueCard" : ortakMaviKartController.text,
            "Name4" : ortakAdController.text,
            "LastName4":ortakSoyadController.text,
            "id" : companyId,
          }
      ));
    }
    var decoded = jsonDecode(response.body);
    if(decoded["status"]){
      this.setState(() {
        isOrtak = true;
      });
    }
  }

  Future <void> addTitile()async{
    final url = Uri.parse(webURL + 'api/AddTitle');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "Title": unvanController.text,
          "titleSubject": dropDownTitleS,
          "titleSpecialWord": dropDownTitleSW,
          "id" : companyId,
        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isUnvan = true;
      });

    } else {
      throw Exception('Failed to load');
    }
  }

  Future <void> addAdrees()async{
    final url = Uri.parse(webURL + 'api/AddAdres');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id":companyId,
          "CityID":dropDownCity,
          "AreaId":dropDownArea,
          "mahalla":dropDownDistrict,
          "Adresdiscription":adreesController.text
        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isAdrees = true;
      });

    } else {
      throw Exception('Failed to load');
    }

  }

  Future <void> addTarget()async{
    final url = Uri.parse(webURL + 'api/AddTarget');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id":companyId,
          "TargetID": targetListId

        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isSirketAmaci = true;
      });

    } else {
      throw Exception('Failed to load');
    }

  }

  Future <void> addNace()async{
    final url = Uri.parse(webURL + 'api/AddNace');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id":companyId,
          "UniqueID": naceUniqueId
        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isNACE = true;
      });

    } else {
      throw Exception('Failed to load');
    }

  }

  Future <void> addSermaya()async{
    final url = Uri.parse(webURL + 'api/AddCapital');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id":companyId,
          "total":sermayeController.text,
          "TotalShare":sermayeController1.text
        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isSermaye = true;
      });

    } else {
      throw Exception('Failed to load');
    }

  }

  Future <void> addManager()async{
    final url = Uri.parse(webURL + 'api/AddManager');
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body:jsonEncode(
        {
          "id":companyId,
          "TaskDistribution":gorevDagitimDropdownValue,
          "AuthorizationShape":yetkilendrmeDropdownValue,
          "TaskDuration":gorevSuresiDropdownValue,
          "PartnerID":ortakId
        }
    ));
    if (response.statusCode == 200) {
      this.setState(() {
        isMudur = true;
      });

    } else {
      throw Exception('Failed to load');
    }

  }

  Future<String> fetchIdPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String id = await prefs.getString('id');
    return id;
  }

  @override
  void initState() {
    super.initState();
    fetchTokenPreference();
    listCompanyTarget();
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
          labelStyle: TextStyle(color: Colors.orange, fontSize: 10),
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
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(70.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: appbar(context,_advancedDrawerController),
            ),
          ),
          body: Scrollbar(
            child: ListView(
              children: [
                SizedBox(height: 10,),
                // ANA DETAYLAR SECTION
                TextButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => StatefulBuilder(
                        builder: (context, setState) {
                          translateAltTurDropDown2();
                          // ANA DETAYLAR DIALOG
                          return AlertDialog(
                            title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('alertTitle')),
                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16)
                            ),
                            content:  SingleChildScrollView(
                              child: Column(
                                children: [
                                  // ALT TUR DROPDOWN
                                  Column(
                                    children: [
                                      Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyType')),
                                        style: TextStyle(color: Colors.orange,),
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        children: [
                                          Container(
                                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                          SizedBox(width: 8,),
                                          Container(
                                            child:
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('altTur')),
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
                                          value: altTurDrop2,
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          elevation: 16,
                                          hint: Container(
                                            width: 150,                      //and here
                                            child: Text(
                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectItemType')),
                                              style: TextStyle(color: Colors.black26, fontSize: 12),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              AnaDetay++;
                                              altTurDrop2 = newValue;
                                              if(altTurDrop2 == "Ortak Sayısı Birden Fazla Limited Şirket"){
                                                altTurDropDownIndex2 = 0;
                                              }else{
                                                altTurDropDownIndex2 = 1;
                                              }
                                            });
                                          },
                                          items: altTurDropDown2
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  // CITY DROPDOWN
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                          SizedBox(width: 8,),
                                          Container(
                                            child:
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('City')),
                                              style: TextStyle(color: Colors.orange, fontSize: 14),),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 50,
                                        width: MediaQuery.of(context).size.width,
                                        child: FutureBuilder(
                                            future: getCities(),
                                            builder: (context, snapshot) {
                                              if(snapshot.hasData){
                                                List<String> cityNames = [];
                                                for(int i = 0 ;i<snapshot.data.length -1; i++){
                                                  cityNames.add(snapshot.data[i].name);
                                                }
                                                return DropdownSearch<String>(
                                                  mode: Mode.DIALOG,
                                                  showSelectedItem: true,
                                                  showSearchBox: true,
                                                  showClearButton: true,
                                                  items: cityNames,
                                                  //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                                  label: " " + Localizations
                                                      .of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
                                                  hint: "city in menu mode",
                                                  onChanged: (val) {
                                                    setState(() {
                                                      AnaDetay++;
                                                      isIlceDropdownEndabled = true;
                                                      int currentIndex = cityNames.indexOf(val);
                                                      ilceId = currentIndex;
                                                      updateAreaById(anaCityIdsList[currentIndex]);
                                                      anaDetayCityId = anaCityIdsList[currentIndex];
                                                    });
                                                  },
                                                  selectedItem: null,
                                                );
                                              }else{
                                                return DropdownSearch<String>(
                                                  mode: Mode.DIALOG,
                                                  showSelectedItem: true,
                                                  enabled: false,
                                                  showSearchBox: true,
                                                  showClearButton: true,
                                                  items: [], //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                                  label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
                                                  hint: "country in menu mode",
                                                  onChanged: (val) {

                                                  },
                                                  selectedItem: null,
                                                );
                                              }

                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  // AREA DROPDOWN
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                          SizedBox(width: 8,),
                                          Container(
                                            child:
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('area')),
                                            style: TextStyle(color: Colors.orange, fontSize: 14),),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 50,
                                        width: MediaQuery.of(context).size.width,
                                        child: FutureBuilder(
                                            future: updateAreaById(anaCityIdsList[ilceId]),
                                            builder: (context, snapshot) {
                                              return DropdownSearch<String>(
                                                enabled: isAreaDropdownEndabled,
                                                mode: Mode.DIALOG,
                                                showSelectedItem: true,
                                                showSearchBox: true,
                                                showClearButton: true,
                                                items: anaAreasList,
                                                label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectArea'),
                                                hint: "Area in menu mode",
                                                onChanged: (val) {
                                                  setState(() {
                                                    AnaDetay++;
                                                    isDistrictDropdownEndabled = true;
                                                    int currentIndex = anaAreasList.indexOf(val);
                                                    areaIndex = currentIndex;
                                                    updateDistrictById(anaAreaIdsList[currentIndex]);
                                                    anaDetayAreaId = anaAreaIdsList[currentIndex].toString();

                                                  });
                                                },
                                                selectedItem: null,
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                          SizedBox(width: 8,),
                                          Container(
                                            child:
                                            Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('registryoffice')),
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
                                          value: altTurDrop1,
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          elevation: 16,
                                          style: const TextStyle(color: Colors.black, fontSize: 12),
                                          hint: Container(
                                            width: 150,                      //and here
                                            child: Text(
                                              (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sicilEkle')),
                                              style: TextStyle(color: Colors.black26, fontSize: 12),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              altTurDrop1 = newValue;
                                              AnaDetay++;
                                            });
                                          },
                                          items: altTurDropDown1
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,style: TextStyle(color: Colors.black, fontSize: 16),),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              ),
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
                                      Navigator.pop(context, 'OK');
                                      this.setState(()async{
                                        if(AnaDetay >= 4)
                                          await addCompanyType();
                                      });
                                    },
                                    child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                    ),
                  ),
                  child: isAnaDetay == true? continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Details')) ,true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Details')), false),
                ),
                // ORTAK SECTION
                TextButton(
                  onPressed: ()  {

                    if(isAnaDetay){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => StatefulBuilder(
                          builder: (context, setState)
                          => AlertDialog(
                            title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ortak')),
                                style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16)
                            ),
                            content: SingleChildScrollView(
                              child:  Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tcile')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 14),
                                      ),
                                      leading: Radio(
                                        value: 0,
                                        groupValue: val,
                                        onChanged: (value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                        activeColor: Colors.orange,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('yenikimlik')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 14),),
                                      leading: Radio(
                                        value: 1,
                                        groupValue: val,
                                        onChanged: (value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                        activeColor: Colors.orange,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('geciciKimlik')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 14),),
                                      leading: Radio(
                                        value: 2,
                                        groupValue: val,
                                        onChanged: (value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                        activeColor: Colors.orange,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('pasaport')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 14),),
                                      leading: Radio(
                                        value: 3,
                                        groupValue: val,
                                        onChanged: (value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                        activeColor: Colors.orange,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mavikart')),
                                        style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1) , fontSize: 14),),
                                      leading: Radio(
                                        value: 4,
                                        groupValue: val,
                                        onChanged: (value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                        activeColor: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    buildColumn(val),
                                  ],
                                ),
                              ),
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
                                    onPressed: () {
                                      Navigator.pop(context, 'OK');
                                      this.setState(()async {
                                        if(val ==0 && ortakTcController.text.isNotEmpty && ortakAdController.text.isNotEmpty &&
                                            ortakCuzdanNoController.text.isNotEmpty && ortakSeriNoController.text.isNotEmpty &&
                                            ortakSoyadController.text.isNotEmpty && ortakUyrukController.text.isNotEmpty  ){
                                          await addPartner(val);
                                        }
                                        else if(val == 1 && ortakTcController.text.isNotEmpty && ortakAdController.text.isNotEmpty &&
                                            ortakSerialNoController.text.isNotEmpty && ortakSoyadController.text.isNotEmpty &&
                                            ortakUyrukController.text.isNotEmpty ){
                                          await addPartner(val);

                                        }
                                        else if(val == 2 && ortakAdController.text.isNotEmpty  && ortakDocumentNoController.text.isNotEmpty &&
                                            ortakSoyadController.text.isNotEmpty && ortakUyrukController.text.isNotEmpty
                                            && ortakTcController.text.isNotEmpty ){
                                          await addPartner(val);

                                        }
                                        else if(val == 3 && ortakAdController.text.isNotEmpty && ortakPasaportNoController.text.isNotEmpty &&
                                            ortakSoyadController.text.isNotEmpty && ortakUyrukController.text.isNotEmpty ){
                                          await addPartner(val);

                                        }
                                        else if(val == 4 && ortakAdController.text.isNotEmpty &&
                                            ortakMaviKartController.text.isNotEmpty && ortakSoyadController.text.isNotEmpty &&
                                            ortakUyrukController.text.isNotEmpty ){
                                          await addPartner(val);
                                        }
                                      });

                                    },
                                    child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isOrtak ?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Partner')) ,true): continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Partner')) ,false),
                ),
                // UNVAN SECTION
                TextButton(
                  onPressed: () {
                    if(isOrtak){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => StatefulBuilder(
                          builder: (context,setState) {
                            return AlertDialog(
                              title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('unvan')),
                                  style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16)
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('unvanEki')),
                                                style: TextStyle(color: Colors.orange, fontSize: 14),),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                            width: double.infinity,
                                            child: TextField(
                                              controller: unvanController,
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
                                              onChanged: (text){
                                                setState(() {
                                                  title = text;
                                                });
                                              },
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
                                                child: Text("*",
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('unvanKonu')),
                                                style: TextStyle(color: Colors.orange, fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          height: 50,
                                          width: MediaQuery.of(context).size.width,
                                          child: FutureBuilder(
                                              future: listCompanySubject(),//updateAreaById(cityIdsList[ilceId]),
                                              builder: (context, snapshot) {
                                                if(snapshot.hasData){
                                                  List<String> subjectNames = [];
                                                  for(int i = 0 ;i<snapshot.data.length -1; i++){
                                                    subjectNames.add(snapshot.data[i].name);
                                                  }
                                                  return DropdownSearch<String>(
                                                    mode: Mode.DIALOG,
                                                    showSelectedItem: true,
                                                    showSearchBox: true,
                                                    showClearButton: true,
                                                    items: subjectNames,
                                                    label: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('unvanKonusec')),
                                                    hint: "Unvan in menu mode",
                                                    onChanged: (val) {
                                                      setState(() {
                                                        dropDownTitleS1 = val;
                                                        Unvan++;
                                                        int currentIndex = subjectNames.indexOf(val);
                                                        dropDownTitleS = snapshot.data[currentIndex].id;
                                                      });
                                                    },
                                                    selectedItem: null,
                                                  );
                                                } else{
                                                  return DropdownSearch<String>(
                                                    mode: Mode.DIALOG,
                                                    showSelectedItem: true,
                                                    enabled: false,
                                                    showSearchBox: true,
                                                    showClearButton: true,
                                                    items: [],
                                                    label: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('unvanKonusec')),
                                                    hint: "Unvan Konu Seçiniz",
                                                    onChanged: (val) {
                                                    },
                                                    selectedItem: null,
                                                  );
                                                }

                                              }
                                          ),
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
                                                child: Text("*",
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ozelKelime')),
                                                style: TextStyle(color: Colors.orange, fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          height: 50,
                                          width: MediaQuery.of(context).size.width,
                                          child: FutureBuilder(
                                              future: listSpecialWord(),//updateAreaById(cityIdsList[ilceId]),
                                              builder: (context, snapshot) {
                                                if(snapshot.hasData){
                                                  List<String> subjectNames = [];
                                                  for(int i = 0 ;i<snapshot.data.length -1; i++){
                                                    subjectNames.add(snapshot.data[i].name);
                                                  }
                                                  return DropdownSearch<String>(
                                                    mode: Mode.DIALOG,
                                                    showSelectedItem: true,
                                                    showSearchBox: true,
                                                    showClearButton: true,
                                                    items: subjectNames,
                                                    label: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ozelKelimesec')),
                                                    hint: "Özel Kelime Seçiniz",
                                                    onChanged: (String val) {
                                                      setState(() {
                                                        Unvan++;
                                                        dropDownTitleSW1 = val;
                                                        int currentIndex = subjectNames.indexOf(val);
                                                        dropDownTitleSW = snapshot.data[currentIndex].id;
                                                      });
                                                    },
                                                    selectedItem: null,
                                                  );
                                                } else{
                                                  return DropdownSearch<String>(
                                                    mode: Mode.DIALOG,
                                                    showSelectedItem: true,
                                                    enabled: false,
                                                    showSearchBox: true,
                                                    showClearButton: true,
                                                    items: [],
                                                    label: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ozelKelimesec')),
                                                    hint: "Özel Kelime Seçiniz",
                                                    onChanged: (val) {
                                                    },
                                                    selectedItem: null,
                                                  );
                                                }

                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Text(
                                        "${(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tamUnvan'))} :",
                                          style: TextStyle(color: Colors.orange, fontSize: 18,fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(title,style: TextStyle(fontSize: 18,color: Colors.black54,fontWeight: FontWeight.bold),),
                                        SizedBox(width: 2,),
                                        Text(dropDownTitleS1,style: TextStyle(fontSize: 18,color: Colors.black54,fontWeight: FontWeight.bold),),

                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(dropDownTitleSW1,style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.bold),),
                                        SizedBox(width: 2,),
                                        title!="" && dropDownTitleS1 !="" && dropDownTitleSW1 != "" ?
                                        Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('limitedCompany')
                                          ,style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.bold),) : SizedBox(),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() async {
                                          if ( unvanController.text.isNotEmpty && Unvan >=2 ) {
                                            await addTitile();
                                          }
                                        });
                                      },
                                      child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        ),
                      );
                    }
                    else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child: isUnvan ? continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('TitleofComp')), true):continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('TitleofComp')) ,false),
                ),
                // ADDRESS SECTION
                TextButton(
                  onPressed: () {
                    if(isUnvan){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adresEkle')),
                              style: TextStyle(color: Color.fromRGBO(46, 96, 113, 1), fontSize: 16)
                          ),
                          content:  StatefulBuilder(
                              builder: (context, setState) {
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                              SizedBox(width: 8,),
                                              Container(
                                                child:
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('City')),
                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            //margin: EdgeInsets.only(left: 10, right: 10),
                                            child: FutureBuilder(
                                                future: getCities(),
                                                builder: (context, snapshot) {
                                                  if(snapshot.hasData){
                                                    List<String> cityNames = [];
                                                    for(int i = 0 ;i<snapshot.data.length -1; i++){
                                                      cityNames.add(snapshot.data[i].name);
                                                    }
                                                    return DropdownSearch<String>(
                                                      mode: Mode.DIALOG,
                                                      showSelectedItem: true,
                                                      showSearchBox: true,
                                                      showClearButton: true,
                                                      items: cityNames, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                                      label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
                                                      hint: "city in menu mode",
                                                      onChanged: (val) {
                                                        setState(() {
                                                          Adrees++;
                                                          //selectedCustomerCountry = countryIdsList[currentIndex];
                                                          isIlceDropdownEndabled = true;
                                                          int currentIndex = cityNames.indexOf(val);
                                                          ilceId = currentIndex;
                                                          updateAreaById(anaCityIdsList[currentIndex]);
                                                          dropDownCity = snapshot.data[currentIndex].id;
                                                          //                                        countryIndex = currentIndex;
                                                        });
                                                      },
                                                      selectedItem: null,
                                                    );
                                                  }else{
                                                    return DropdownSearch<String>(
                                                      mode: Mode.DIALOG,
                                                      showSelectedItem: true,
                                                      enabled: false,
                                                      showSearchBox: true,
                                                      showClearButton: true,
                                                      items: [], //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                                      label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCity'),
                                                      hint: "country in menu mode",
                                                      onChanged: (val) {
                                                      },
                                                      selectedItem: null,
                                                    );
                                                  }

                                                }
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                              SizedBox(width: 8,),
                                              Container(
                                                child:
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('area')),
                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: DropdownSearch<String>(
                                              enabled: isAreaDropdownEndabled,
                                              mode: Mode.DIALOG,
                                              showSelectedItem: true,
                                              showSearchBox: true,
                                              showClearButton: true,
                                              items: anaAreasList,
                                              label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectArea'),
                                              hint: "Area in menu mode",
                                              onChanged: (val) {
                                                setState(() {
                                                  Adrees++;
                                                  isDistrictDropdownEndabled = true;
                                                  int currentIndex = anaAreasList.indexOf(val);
                                                  areaIndex = currentIndex;
                                                  updateDistrictById(anaAreaIdsList[currentIndex]);
                                                  dropDownArea =anaAreaIdsList[currentIndex];
                                                });
                                              },
                                              selectedItem: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                  child: Text("*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                                              SizedBox(width: 8,),
                                              Container(
                                                child:
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Neighborhood')),
                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: DropdownSearch<String>(
                                              enabled: isDistrictDropdownEndabled,
                                              mode: Mode.DIALOG,
                                              showSelectedItem: true,
                                              showSearchBox: true,
                                              showClearButton: true,
                                              items: districtList,
                                              label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectNeighborhood'),
                                              hint: "District in menu mode",
                                              onChanged: (val) {
                                                setState(() {
                                                  Adrees++;
                                                  isMahallaDropdownEndabled = true;
                                                  int currentIndex = districtList.indexOf(val);
                                                  districtIndex = currentIndex;
                                                  updateMahallaById(districtIdsList[currentIndex]);
                                                  dropDownDistrict = districtIdsList[currentIndex];
                                                });
                                              },
                                              selectedItem: null,
                                            ),
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
                                                Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addressInfo')),
                                                  style: TextStyle(color: Colors.orange, fontSize: 14),),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                              width: double.infinity,
                                              child: TextField(
                                                controller: adreesController,
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
                                    ],
                                  ),
                                );
                              }
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
                                  onPressed: () {
                                    Navigator
                                        .pop(context, 'OK');
                                    this.setState(()async {
                                      if(Adrees>=3 && adreesController.text.isNotEmpty) {
                                        await addAdrees();
                                      }
                                    });
                                  },
                                  child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                ),
                              ],
                            ),
                          ],
                        ),

                      );}else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }},
                  child:isAdrees ? continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddAddress')),true):continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddAddress')),false),
                ),
                // SIRKETIN AMACI SECTION
                TextButton(
                  onPressed: () {
                    if(isAdrees) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('companyPurpose')),
                                        style: TextStyle(color: Color.fromRGBO(
                                            46, 96, 113, 1), fontSize: 16)
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          MultiSelectDialogField(
                                            items: targetList.map((e) => MultiSelectItem(e, e.title)).toList(),
                                            title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCompanyPurpose'))),
                                            confirmText: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok'))),
                                            cancelText: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel'))),
                                            listType: MultiSelectListType.CHIP,
                                            onConfirm: (values) {
                                              setState((){
                                                targetList1 = values;
                                                for(int i = 0; i<targetList1.length;i++){
                                                  targetListId.add(targetList1[i].id);
                                                }
                                              });
                                            },
                                            buttonText: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCompanyPurpose')),
                                                style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 16)),
                                          ),
                                          SizedBox(height: 20,),
                                          StatefulBuilder(builder: (context,setState){
                                            return Container(
                                              height: 200,
                                              width: (MediaQuery.of(context).size.width),
                                              child: targetList1.isNotEmpty ?ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: targetList1.length,
                                                  itemBuilder: (context,index){
                                                    return Row(
                                                      children: [
                                                        SizedBox(width: 10,),
                                                        SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                  width: (MediaQuery.of(context).size.width*0.65),
                                                                  child: Text(targetList1[index].title,style: TextStyle(
                                                                      fontSize: 16,fontWeight: FontWeight.bold))),
                                                              SizedBox(height: 20,),
                                                              Container(
                                                                  width: (MediaQuery.of(context).size.width*0.65),
                                                                  child: Text(targetList1[index].subject,style: TextStyle(
                                                                      color: Color.fromRGBO(46, 96, 113, 1),
                                                                      fontSize: 16))),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,)
                                                      ],
                                                    );
                                                  }) : Text(""),
                                            ) ;
                                          })

                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, 'Cancel'),
                                            child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                              this.setState(()async{
                                                if(targetList1.isNotEmpty) {
                                                  await addTarget();
                                                }
                                              });
                                            },
                                            child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isSirketAmaci?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddTargetofComp')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddTargetofComp')),false),
                ),
                // NACE KODU SECTION
                TextButton(
                  onPressed: () {
                    if(isSirketAmaci) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('naceCode')),
                                        style: TextStyle(
                                            color: Color.fromRGBO(46, 96, 113, 1),
                                            fontSize: 16)
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.red),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addNaceCode')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 14),),
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
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    decoration: new InputDecoration(
                                                      hintText: naceUniqueCode ,
                                                      focusColor: Colors.orange,
                                                      contentPadding: EdgeInsets
                                                          .symmetric(horizontal: 10,
                                                          vertical: 0),
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.orange),
                                                      ),
                                                    ),
                                                  )
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.red),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('naceCodeDesc')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 14),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              FutureBuilder(
                                                  future: listNaceCode(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      List<String> nacecodeList = [];
                                                      for (int i = 0; i < snapshot.data.length - 1; i++) {
                                                        nacecodeList.add(
                                                            snapshot.data[i]
                                                                .toString());
                                                      }
                                                      return DropdownSearch<String>(
                                                        enabled: isAreaDropdownEndabled,
                                                        mode: Mode.DIALOG,
                                                        hint: "Select Itme",
                                                        showSelectedItem: true,
                                                        showSearchBox: true,
                                                        showClearButton: true,
                                                        items: nacecodeList,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            NACE++;
                                                            int index = nacecodeList
                                                                .indexOf(val);
                                                            targetCompany =
                                                            snapshot.data[index];
                                                            naceUniqueCode = naceUniqueCodeList[index];
                                                            naceUniqueId = naceUniqueIdList[index];
                                                          });
                                                        },
                                                        selectedItem: null,
                                                      );
                                                    } else {
                                                      return DropdownSearch<String>(
                                                        mode: Mode.DIALOG,
                                                        showSelectedItem: true,
                                                        enabled: false,
                                                        hint: "Select Itme",
                                                        showSearchBox: true,
                                                        showClearButton: true,
                                                        items: [],
                                                        onChanged: (val) {},
                                                        selectedItem: null,
                                                      );
                                                    }
                                                  }
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Cancel'),
                                            child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                              if(NACE>=1 ) {
                                                this.setState(()async {
                                                  await addNace();
                                                });
                                              }
                                            },
                                            child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }

                  },
                  child:isNACE ?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addNaceCode')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addNaceCode')),false),
                ),
                // ILAN SECTION
                TextButton(
                  onPressed: () {
                    if(isNACE) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ilanEkle')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("*",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ilan')),
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                            height: 100,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.orange),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),),
                                            ),
                                            width: double.infinity,
                                            child: SingleChildScrollView(
                                              child: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ilanDesc')),
                                                style: TextStyle(fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      46, 96, 113, 1),),
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isIlan = true;
                                        });

                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                      );
                    }
                    else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isIlan ?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddAds')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddAds')),false),
                ),
                // SERMAYE SECTION
                TextButton(
                  onPressed: () {
                    if(isIlan) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sermaye')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("*",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total2')),
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 14),),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                            width: double.infinity,
                                            child: TextField(
                                              controller: sermayeController,
                                              minLines: 1,
                                              maxLines: 3,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: new InputDecoration(
                                                focusColor: Colors.orange,
                                                contentPadding: EdgeInsets
                                                    .symmetric(horizontal: 10,
                                                    vertical: 0),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                child: Text("*",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('total2')),
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 14),),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                            width: double.infinity,
                                            child: TextField(
                                              controller: sermayeController1,
                                              minLines: 1,
                                              maxLines: 3,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: new InputDecoration(
                                                focusColor: Colors.orange,
                                                contentPadding: EdgeInsets
                                                    .symmetric(horizontal: 10,
                                                    vertical: 0),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        if(sermayeController.text.isNotEmpty) {
                                          this.setState(() async{
                                            await addSermaya();
                                          });
                                        }
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isSermaye? continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Capital')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('Capital')),false),
                ),
                // MUDUR SECTION
                TextButton(
                  onPressed: () async{
                    await listPartner();
                    if(isSermaye) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addManager')),
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                46, 96, 113, 1),
                                            fontSize: 16)
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          Column(
                                            children: [
                                              ListTile(
                                                title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ExternalLegalPartner')),
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          46, 96, 113, 1),
                                                      fontSize: 14),
                                                ),
                                                leading: Radio(
                                                  value: 0,
                                                  groupValue: val,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      Mudur++;
                                                      val = value;
                                                    });
                                                  },
                                                  activeColor: Colors.orange,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('LegalPartner')),
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          46, 96, 113, 1),
                                                      fontSize: 14),
                                                ),
                                                leading: Radio(
                                                  value: 1,
                                                  groupValue: val,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      Mudur++;
                                                      val = value;
                                                    });
                                                  },
                                                  activeColor: Colors.orange,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('RealPartner')),
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          46, 96, 113, 1),
                                                      fontSize: 14),
                                                ),
                                                leading: Radio(
                                                  value: 2,
                                                  groupValue: val,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      Mudur++;
                                                      val = value;
                                                    });
                                                  },
                                                  activeColor: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .red),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ortak')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 14),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                //margin: EdgeInsets.only(left: 10, right: 10),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black38),
                                                  borderRadius: BorderRadius
                                                      .all(
                                                    Radius.circular(4.0),),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ortaksec')),
                                                    style: TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 12,fontWeight: FontWeight.bold),),
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black),
                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 14,fontWeight: FontWeight.bold),
                                                  onChanged: (String newValue) {
                                                    setState(() {
                                                      Mudur++;
                                                      ortakDropdownValue = newValue;
                                                      int index = ortakDropdownValueListName.indexOf(newValue);
                                                      ortakId = ortakDropdownValueListId[index];
                                                    });
                                                  },
                                                  items: ortakDropdownValueListName.map(( value) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(value,style :TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,fontWeight: FontWeight.bold),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value:ortakDropdownValue ,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AuthorizationShape')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 18),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                //margin: EdgeInsets.only(left: 10, right: 10),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black38),
                                                  borderRadius: BorderRadius
                                                      .all(
                                                    Radius.circular(4.0),),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddAuthorizationShape')),
                                                    style: const TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 12),),
                                                  value: yetkilendrmeDropdownValue,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black),
                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  elevation: 16,
                                                  onChanged: (String newValue) {
                                                    setState(() {
                                                      Mudur++;
                                                      yetkilendrmeDropdownValue = newValue;
                                                    });
                                                  },
                                                  items: yetkilendrmeDropdownValueList.map<
                                                      DropdownMenuItem<
                                                          String>>((
                                                      String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value,style:  TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .red),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('TaskDistribution')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 14),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                //margin: EdgeInsets.only(left: 10, right: 10),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black38),
                                                  borderRadius: BorderRadius
                                                      .all(
                                                    Radius.circular(4.0),),
                                                ),
                                                child: DropdownButton<String>(
                                                  value: gorevDagitimDropdownValue,
                                                  hint : Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddTaskDistribution')),
                                                    style:  TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 12),),
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black),
                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  elevation: 16,
                                                  onChanged: (String newValue) {
                                                    setState(() {
                                                      Mudur++;
                                                      gorevDagitimDropdownValue = newValue;
                                                    });
                                                  },
                                                  items: gorevDagitimDropdownValueList.map<
                                                      DropdownMenuItem<
                                                          String>>((
                                                      String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value,style:  TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      child: Text("*",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .red),)),
                                                  SizedBox(width: 8,),
                                                  Container(
                                                    child:
                                                    Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('TaskDuration')),
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 14),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                //margin: EdgeInsets.only(left: 10, right: 10),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black38),
                                                  borderRadius: BorderRadius
                                                      .all(
                                                    Radius.circular(4.0),),
                                                ),
                                                child: DropdownButton<String>(
                                                  value: gorevSuresiDropdownValue,
                                                  hint : Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddِTaskDuration')),
                                                    style:  TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 12),),
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black),
                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  elevation: 16,

                                                  onChanged: (String newValue) {
                                                    setState(() {
                                                      Mudur++;
                                                      gorevSuresiDropdownValue = newValue;
                                                    });
                                                  },
                                                  items: gorevSuresiDropdownValueList.map<
                                                      DropdownMenuItem<
                                                          String>>((
                                                      String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value,style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, 'Cancel'),
                                            child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                              this.setState(()async{
                                                if(Mudur>=5) {
                                                  await addManager();
                                                }
                                              });

                                            },
                                            child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isMudur ?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddManager')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddManager')),false),
                ),
                // KAR AÇIKLAMASI
                TextButton(
                  onPressed: () {
                    if(isMudur) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addProfit')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: new BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),),
                                ),
                                child: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Text(
                                        (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('profitDesc')),
                                        style: TextStyle(fontSize: 12,
                                            color: Color.fromRGBO(
                                                46, 96, 113, 1)
                                        ),
                                      ),
                                    )
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isKarinVeDagitma = true;
                                        });
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isKarinVeDagitma ?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddProfitDetection')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddProfitDetection')),false),
                ),
                TextButton(
                  onPressed: () {
                    if(isKarinVeDagitma) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AdministrationRepresentation')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: Container(
                                  height: 100,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AdministrationDesc')),
                                      style: TextStyle(fontSize: 12,
                                        color: Color.fromRGBO(46, 96, 113, 1),),
                                    ),
                                  )
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState((){
                                          isSirketTemsili = true;
                                        });
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isSirketTemsili?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddRepresntation')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AddRepresntation')),false),
                ),
                TextButton(
                  onPressed: () {
                    if(isSirketTemsili) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('reserveFound')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),),
                                  ),
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('reserveFoundDesc')),
                                      style: TextStyle(fontSize: 12,
                                        color: Color.fromRGBO(46, 96, 113, 1),),
                                    ),
                                  )
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isYedek = true;
                                        });
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isYedek?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ReserveFound')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ReserveFound')),false),
                ),
                TextButton(
                  onPressed: () {
                    if(isYedek) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adTime')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                child: Text(
                                                  "*", style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red),)),
                                            SizedBox(width: 8,),
                                            Container(
                                              child:
                                              Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('time')),
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14),),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                            width: double.infinity,
                                            child: Scrollbar(
                                              controller: _scrollController,
                                              isAlwaysShown: true,
                                              child: TextField(
                                                scrollController: _scrollController,
                                                autofocus: true,
                                                keyboardType: TextInputType
                                                    .multiline,
                                                maxLines: 3,
                                                minLines: 1,
                                                readOnly: true,
                                                decoration: new InputDecoration(
                                                  hintText: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('sinirsiz')),
                                                  hintStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        46, 96, 113, 1),),
                                                  focusColor: Colors.orange,
                                                  contentPadding: EdgeInsets
                                                      .symmetric(horizontal: 10,
                                                      vertical: 10),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.orange),
                                                  ),
                                                ),
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isSirketSuresi = true;
                                        });
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isSirketSuresi?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AdCompTime')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('AdCompTime')),false),
                ),
                TextButton(
                  onPressed: () {
                    if(isSirketSuresi) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('GeneralAssemblyModal')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: Container(
                                  height: 100,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),),
                                  ),
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('GeneralAssemblyDesc')),
                                      style: TextStyle(fontSize: 12,
                                        color: Color.fromRGBO(46, 96, 113, 1),),
                                    ),
                                  )
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isGenelkurul = true;
                                        });
                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isGenelkurul?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CompGeneralAssem')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CompGeneralAssem')),false),
                ),
                TextButton(
                  onPressed: () {
                    if(isGenelkurul) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('LegalProvisionsModal')),
                                  style: TextStyle(
                                      color: Color.fromRGBO(46, 96, 113, 1),
                                      fontSize: 16)
                              ),
                              content: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),),
                                  ),
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('LegalProvisionsDesc')),
                                      style: TextStyle(fontSize: 12,
                                        color: Color.fromRGBO(46, 96, 113, 1),),
                                    ),
                                  )
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cancel')),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        this.setState(() {
                                          isYasalHukumlar = true;
                                        });

                                      },
                                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('ok')),),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      );
                    }else{
                      Fluttertoast.showToast(msg: "Please fill in the information in order ",fontSize: 15);
                    }
                  },
                  child:isYasalHukumlar?continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CompLegalPrev')),true):
                  continer((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('CompLegalPrev')),false),
                ),
                SizedBox(height: 20,),
                Container(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/4,
                        left: MediaQuery.of(context).size.width/4),
                    child: ElevatedButton(
                      child:  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('randevuAl')),
                        style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
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
                                                      contentPadding: EdgeInsets.all(5),
                                                      hintText: username == null? 'OsmanBaba' :username,
                                                    ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          primary: Color.fromRGBO(46, 96, 113, 1),
                          padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/4,
                      left: MediaQuery.of(context).size.width/4),
                  child: ElevatedButton(
                    child: const Text('Pdf',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        primary: Color.fromRGBO(46, 96, 113, 1),
                        padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Column buildColumn(val) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20,),
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
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('uyruk')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakUyrukController,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(color: Colors.black),
                  decoration: new InputDecoration(
                    focusColor: Colors.orange,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderSide:  BorderSide(color: Colors.orange),
                    ),
                  ),
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
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('firstName')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakAdController,
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
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('secondName')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakSoyadController,
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
        SizedBox(height: 10,),
        val ==0 || val == 1 || val == 2 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('tcile')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakTcController,
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
        ) : SizedBox(height: 10,),

        val ==0 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cuzdanSerialNo')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakSeriNoController,
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
        ) : SizedBox(height: 10,),

        val ==0 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('cuzdanNo')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakCuzdanNoController,
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
        ): SizedBox(height: 10,),

        val == 3  ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('pasaportNo')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakPasaportNoController,
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
        ) : SizedBox(height: 0,),

        val == 4  ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mavikart')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakMaviKartController,
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
        ) : SizedBox(height: 0,),

        val == 1 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('serialNo')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakSerialNoController,
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
        ) : SizedBox(height: 0,),

        val == 2  ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    child: Text("*",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)),
                SizedBox(width: 8,),
                Container(
                  child:
                  Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('documentNo')),
                    style: TextStyle(color: Colors.orange, fontSize: 14),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
                width: double.infinity,
                child: TextField(
                  controller: ortakDocumentNoController,
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
        ) : SizedBox(height: 0,),
      ],
    );

  }

}

