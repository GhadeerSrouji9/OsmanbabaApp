import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/helpers/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';


class AddAd extends StatefulWidget{
//  final List<Map<String, dynamic>> adArgsMap;
  AddAd();


  @override
  State<StatefulWidget> createState() {
    return _AddAdState();
  }

}

class _AddAdState extends State<AddAd>{
  final _advancedDrawerController = AdvancedDrawerController();

  final titleTrTextFieldController = TextEditingController();
  final titleEnTextFieldController = TextEditingController();
  final titleArTextFieldController = TextEditingController();
  final descriptionTrTextFieldController = TextEditingController();
  final descriptionEnTextFieldController = TextEditingController();
  final descriptionArTextFieldController = TextEditingController();
  List<TextEditingController> adjectiveControllers = [new TextEditingController()];


  String selectedImages = "";
  String selectedVideo = "";
  String selectedCategoryId;
  String categoryDropdownValue = "Ccc";
  String productDropdownValue = "vvv";

  bool isProductDropdownEnnabled = false;
  int categoryIndex = null;

  String token;
  int adjectiveCount = 1;

  List<List<String>> adjectiveValuesList = [[]];

  List<File> adImageFiles;
  File primaryImageFile;
  File productImageFile;
  File videoFile;

  Future<void> fetchProductsByCategoryID() async{
    print("fetchhhhhhhhinnng");
    List<String> categoryNamesList = [];
    final response = await http.get(Uri.parse(webURL + 'api/ListCategory'));

    if (response.statusCode == 200) {
      print("jjjjjjjjjjjjjjjjjj:");
      var decoded = jsonDecode(response.body);
      if(this.mounted)
        setState(() {
          for(int i = 0; i < decoded.length; i++){
            categoryNamesList.add(decoded[i]["name_en"]);
          }
        });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  }

//  List<Map<String, dynamic>> localAdArgs;
//  List<String> categoriesList = [];

  @override
  void initState() {

    fetchUserToken();

    super.initState();
//    this.fetchCategories();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleTrTextFieldController.dispose();
    titleEnTextFieldController.dispose();
    titleArTextFieldController.dispose();
    descriptionTrTextFieldController.dispose();
    descriptionEnTextFieldController.dispose();
    descriptionArTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      supportedLocales: [
        Locale('ar', 'SAR'),
        Locale('en', 'US'),
        Locale('tr', 'TR')
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      locale: isLanguageSpecified ? globalLocale : null,//globalLocale,


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
            preferredSize: Size.fromHeight(70.0),
            child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: appbar(
                    context,
                    _advancedDrawerController
                )
            ),
          ),
          body: Container(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 32.0, left: 16.0, bottom: 125.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // AD TITLE TR
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adTitle') + " tr",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: titleTrTextFieldController,
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

                        // AD TITLE EN
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adTitle')  + " en",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: titleEnTextFieldController,
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

                        // AD TITLE AR
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adTitle')  + " ar",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: titleArTextFieldController,
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

                        // AD DESCRIPTION TR
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adDescription') + " tr",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: descriptionTrTextFieldController,
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

                        // AD DESCRIPTION EN
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adDescription')  + " en",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: descriptionEnTextFieldController,
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

                        // AD DESCRIPTION AR
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adDescription') + " ar",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: TextField(
                                  controller: descriptionArTextFieldController,
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

                        // PRIMARY AD IMAGE
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PRIMARY IMAGE TITLE
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  "Primary image",
                                ),
                              ),
                              // PRIMARY IMAGE BUTTON
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: () async{
                                    await pickPrimaryImage();
                                  },
                                  child: Text(
                                    "Upload primary image",
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.transparent,),

                        // PRODUCT AD IMAGE
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PRODUCT IMAGE TITLE
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  "Product image",
                                ),
                              ),
                              // PRODUCT IMAGE BUTTON
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: () async{
                                    await pickProductImage();
                                  },
                                  child: Text(
                                    "Upload product image",
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.transparent,),

                        // AD IMAGES
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGES TITLES
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  "Ad images " + selectedImages,
                                ),
                              ),
                              // PRODUCT IMAGE BUTTON
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: () async{
//                            List<File> imageFiles = await FilePicker.getMultiFile();
                                    adImageFiles = await FilePicker.getMultiFile();
                                    if(adImageFiles.length > 3) {
                                      adImageFiles = null;
                                      selectedImages = "";
                                      Fluttertoast.showToast(
                                        msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toast4ImagesLimit'),
                                      );
                                    }
                                    else {
                                      if(this.mounted) {
                                        print("iiiiiiiiiii " + adImageFiles.toString());
                                        setState(() {
                                          selectedImages = " (" + adImageFiles.length.toString() + " images selected)";
                                        });
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Upload other images (max 3 images)",
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.transparent,),

                        // AD VIDEO
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //this widget gonna change to droplist
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adVideo') + selectedVideo,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: () async{
                                    videoFile = await FilePicker.getFile(type: FileType.video);
                                    if(videoFile != null){
                                      print("iiiiiiiiiii " + videoFile.toString());
                                      setState(() {
                                        selectedVideo = " (video path: " + videoFile.path + ")";
                                      });
                                    }
                                  },
                                  child: Text(
                                    Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('videoButton'),
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.transparent,),

                        // AD CATEGORY
                        Divider(color: Colors.transparent,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                                child: Text(
                                  Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('adCategory'),
                                ),
                              ),
                              // CATEGORY DROPDOWN SEARCH
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: FutureBuilder(
                                  future: fetchCategories(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData){
                                      List<String> categoryNames = [];
                                      for(int i = 0; i < snapshot.data.length - 1; i++){
                                        categoryNames.add(snapshot.data[i]["name"]);
                                      }
                                      return DropdownSearch<String>(
                                        mode: Mode.DIALOG,
                                        showSelectedItem: true,
                                        showSearchBox: true,
                                        showClearButton: true,
                                        items: categoryNames, //["Brazil", "Tunisia", 'Canada', "Ireland"],
                                        label: " " + Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('selectCategory'),
                                        onChanged: (val) {
                                          setState(() {
                                            //TODO: Sooo... now what?
                                            int selectedIndex = categoryNames.indexOf(val);
                                            selectedCategoryId = snapshot.data[selectedIndex]["id"];
                                          });
                                        },
                                        selectedItem: null,
                                      );
                                    } else {
                                      return DropdownSearch();
                                    }

                                  }
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 16.0,),

                        // ADJECTIVE DIVIDER
                        Row(
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: 10, left: 10),
                                width: 50,
                                child: Divider(
                                  color: Colors.orange, thickness: 1,)),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "Product Adjectives",
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
                        SizedBox(height: 8.0,),

                        // ADJECTIVES CONTENT
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // RECURSIVE ADJECTIVES SECTION
                              Container(
                                height: 180 * (adjectiveCount).toDouble(),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index){
                                      return
                                        index < adjectiveCount ?
                                        Container(
                                          height: 180,
                                          // ADJECTIVE NAME/VALUE(S) PAIRS
                                          child: Column(
                                            children: [
                                              // ADJECTIVE NAME TEXT FIELD
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                child: TextField(
                                                  controller: adjectiveControllers[index],
                                                  decoration: InputDecoration(
                                                    hintText: "Adjective name"
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 12.0,),
                                              // ADJECTIVE VALUE(S) TEXT FILED
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                child: TextFieldTags(
                                                  //initialTags: ["better", "lovely"],
                                                  textSeparators: [" ", ".", ","],
                                                  tagsStyler: TagsStyler(
                                                    showHashtag: false,
                                                    tagMargin: const EdgeInsets.only(right: 4.0),
                                                    tagCancelIcon: Icon(Icons.cancel, size: 15.0, color: Colors.orange),
                                                    tagCancelIconPadding: EdgeInsets.only(left: 4.0, top: 2.0),
                                                    tagPadding: EdgeInsets.only(top: 2.0, bottom: 4.0, left: 8.0, right: 4.0),
                                                    tagDecoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Color.fromRGBO(46, 96, 113, 1),
                                                      ),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    tagTextStyle:
                                                    TextStyle(fontWeight: FontWeight.normal, color: Color.fromRGBO(46, 96, 113, 1)),
                                                  ),
                                                  textFieldStyler: TextFieldStyler(
                                                    hintText: "Values",
                                                    textFieldFocusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color.fromRGBO(46, 96, 113, 1), width: 1.0),
                                                    ),
                                                    textFieldBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                                                    ),
                                                  ),
                                                  onDelete: (adjectiveVal) {
                                                    adjectiveValuesList[index].remove(adjectiveVal);
                                                  },
                                                  onTag: (adjectiveVal) {
                                                    adjectiveValuesList[index].add(adjectiveVal);
                                                    print("LENGTH: ${adjectiveValuesList[index].length}");
                                                  },
                                                  validator: (String tag) {
                                                    if (tag.length > 15) {
                                                      return "hey that is too much";
                                                    } else if (tag.isEmpty) {
                                                      return "enter something";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 16.0,)
                                            ],
                                          ),
                                        ) : null;
                                    }
                                ),
                              ),
                              // ADD ADJECTIVE BUTTON
                              Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      adjectiveCount++;
                                      adjectiveControllers.add(new TextEditingController());
                                      adjectiveValuesList.add([]);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(16, 16),
                                      shape: const CircleBorder()
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // ADD AD BUTTON
                        Divider(color: Colors.transparent,),
                        Container(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: () async{
                              for(int i = 0; i < adjectiveControllers.length; i++){
                                print("adjectivesSSssssss: ${adjectiveControllers[i].text}");
                                for(int j = 0; j < adjectiveValuesList[i].length; j++) {
                                  print("adjectivesSSssssss vvvvvallllls: ${adjectiveValuesList[i][j]}");
                                }
                              }
                              await addAd();
                            },

                            child: Text(
                              "Add an ad",
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
                spincbbh(context)
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> addAd() async {
    final url = Uri.parse(webURL + "api/AddAds");
    var request = http.MultipartRequest(
        'POST', url
    );
    request.headers['Content-type'] ='multipart/form-data';
    request.headers["Authorization"] = "Bearer $token";

    request.fields['Title_tr'] = titleTrTextFieldController.text;
    request.fields['Title_ar'] = titleArTextFieldController.text;
    request.fields['Title_en'] = titleEnTextFieldController.text;
    request.fields['Description_tr'] = descriptionTrTextFieldController.text;
    request.fields['Description_ar'] = descriptionArTextFieldController.text;
    request.fields['Description_en'] = descriptionEnTextFieldController.text;
    request.fields['ModelID'] = selectedCategoryId;

    int valueCounter = 0;

    for(int i = 0; i < adjectiveCount; i++) {
      print("$i : ${adjectiveCount}");

      request.fields['adjen[$i]'] = adjectiveControllers[i].text;
      request.fields['adjtr[$i]'] = adjectiveControllers[i].text;
      request.fields['adjar[$i]'] = adjectiveControllers[i].text;
      request.fields['FlagAdj[$i]'] = i.toString();
      print("adjectiveValuesList ${adjectiveValuesList[i].length}");

      for(int j = 0; j < adjectiveValuesList[i].length; j++) {
        print("valuessss counttt: $j in $i adjective");
        request.fields['adjvalue[$valueCounter]'] = adjectiveValuesList[i][j];
        request.fields['Flagvalue[$valueCounter]'] = i.toString();
        valueCounter ++;
      }

    }


    request.files.add(
      http.MultipartFile('PrimaryImage',
          File(primaryImageFile.path).readAsBytes().asStream(),
          File(primaryImageFile.path).lengthSync(),
          filename: primaryImageFile.path.split("/").last),
    );

    request.files.add(
      http.MultipartFile('ProductImage',
          File(productImageFile.path).readAsBytes().asStream(),
          File(productImageFile.path).lengthSync(),
          filename: productImageFile.path.split("/").last),
    );

    if(adImageFiles != 0) {
      for(int i = 0; i < adImageFiles.length; i++){
        request.files.add(
          http.MultipartFile('Image${i + 1}',
              File(adImageFiles[i].path).readAsBytes().asStream(),
              File(adImageFiles[i].path).lengthSync(),
              filename: adImageFiles[i].path.split("/").last),
        );
      }
    }

    request.files.add(
      http.MultipartFile('Video',
          File(videoFile.path).readAsBytes().asStream(),
          File(videoFile.path).lengthSync(),
          filename: videoFile.path.split("/").last),
    );

    print("${request.fields}");

    for(int i = 0; i < request.files.length; i++){
      print("${request.files[i].filename}");
    }

    try {
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      print("tryyy try try: " + res.body.toString());
      print("${res.statusCode}");
      Map<String, dynamic> dep = jsonDecode(utf8.decode(res.bodyBytes));
      if(dep["description"] == "Seccess") {
        print("stonksssss");
      }
    }
    catch(error) {
      print("ccccatch errrrrrrrrrrrror " + error.toString());
    }

  }

  Future<void> fetchUserToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    List<Map<String, dynamic>> primaryCategories = [];
    List<String> categoryNamesList = [];
    List<String> primaryCategoryNames = [];

    final response = await http.get(Uri.parse(webURL + 'api/ListCategory')).timeout(const Duration(seconds: 20), onTimeout:(){

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
//            print("ffffffffffffffff " + currentRecord["name_" + currentLocale]);
            primaryCategoryNames.add(currentRecord["name_" + currentLocale].trim());
            primaryCategories.add({
              "name": currentRecord["name_" + currentLocale],
              "id": currentRecord["id"],
//              webURL + json.decode(decoded["result"][i]["productImage"])["1"].toString(),
//              "image": webURL + json.decode(currentRecord["image"])["1"].toString()
            });
          }
        }
      });
      return primaryCategories;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> pickPrimaryImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
    );

    setState(() {
      primaryImageFile = File(image.path);
      print("a3hhhhhhhhhhhhhhh ${primaryImageFile}");
      print(primaryImageFile.path);
    });
//    path = image.path;
  }

  Future<void> pickProductImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      productImageFile = File(image.path);
      print("a3hhhhhhhhhhhhhhh ${productImageFile}");
      print(productImageFile.path);
    });

//    path = image.path;
  }
}