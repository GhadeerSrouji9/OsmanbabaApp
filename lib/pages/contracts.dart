import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class PDFApi {
  static Future<File> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();

    return _storeFile(path, bytes);
  }
  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}


// ignore: camel_case_types
class contracts extends StatefulWidget {
  @override
  _contractsState createState() => _contractsState();
}
// ignore: camel_case_types
class _contractsState extends State<contracts> {
  final _advancedDrawerController = AdvancedDrawerController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'SAR'),
        Locale('tr', 'TR'),
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
        animationDuration: const Duration(milliseconds: 200),
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
            body:Container(
              padding:EdgeInsets.only(top: 10),
              margin: EdgeInsets.all(8.0),
              child:Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("membershipAgreement")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/ÜYELİK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/ÜYELİK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/ÜYELİK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("advertisingAgreement")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/REKLAM SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/REKLAM SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/REKLAM SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("distanceSalesAgreement")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/MESAFELİ SATIŞ SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/MESAFELİ SATIŞ SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/MESAFELİ SATIŞ SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("translatingService")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/TERCÜMANLIK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/TERCÜMANLIK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/TERCÜMANLIK SÖZLEŞMESİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("dataOwnerApplicationForm")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/VERİ SAHİBİ BAŞVURU FORMU.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/VERİ SAHİBİ BAŞVURU FORMU.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/VERİ SAHİBİ BAŞVURU FORMU.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("termsOfUse")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/KULLANIM KOŞULLARI.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/KULLANIM KOŞULLARI.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/KULLANIM KOŞULLARI.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("kvkkAndCookieLighting")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/KVKK ÇEREZ VE AYDINLATMA.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/KVKK ÇEREZ VE AYDINLATMA.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/KVKK ÇEREZ VE AYDINLATMA.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("shippingAndDelivery")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/KARGO VE TESLİMAT.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/KARGO VE TESLİMAT.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/KARGO VE TESLİMAT.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          InkWell(
                            child:contractContainer(
                              (Localizations.of<AppLocalizations>
                                (context, AppLocalizations).getTranslation("customerService")),
                            ) ,
                            onTap: ()async{
                              if(globalLocale.toString().substring(0,2) == "en"){
                                final path = 'assets/documents/MÜŞTERİ HİZMETLERİ VE ŞİKAYET YÖNETİMİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else if (globalLocale.toString().substring(0,2) == "ar"){
                                final path = 'assets/documents/MÜŞTERİ HİZMETLERİ VE ŞİKAYET YÖNETİMİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }else{
                                final path = 'assets/documents/MÜŞTERİ HİZMETLERİ VE ŞİKAYET YÖNETİMİ.pdf';
                                final file = await PDFApi.loadAsset(path);
                                openPDF(context, file);
                              }
                            },
                          ),
                          SizedBox(height: 100,)
                        ],
                      ),
                    ),
                  ),
                  spincbbh(context)
                ],
              ),
            )
        ),
        drawer: Drawers(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );
}

// ignore: camel_case_types, must_be_immutable
class contractContainer extends StatelessWidget {
  String text ;
  contractContainer(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15,left: 10,right: 10),
      margin: EdgeInsets.all(5),
      height: 60,
      width: (MediaQuery.of(context).size.width*0.98),

      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black54,blurRadius: 2)
          ]
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black54),),

    );
  }

}

class PDFViewerPage extends StatefulWidget {
  final File file;

  const PDFViewerPage({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    final text = '${indexPage + 1} / $pages';
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
        title: Text(name,style: TextStyle(
            color: Colors.white,fontSize:15,fontWeight: FontWeight.bold )),
        actions: pages >= 2
            ? [
          Center(
            child: Text(text,style: TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold ),),),
          IconButton(
            icon: Icon(Icons.chevron_left, size: 32,color : Colors.white),
            onPressed: () {
              final page = indexPage == 0 ? pages : indexPage - 1;
              controller.setPage(page);
            },
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 32,color : Colors.white),
            onPressed: () {
              final page = indexPage == pages - 1 ? 0 : indexPage + 1;
              controller.setPage(page);
            },
          ),
        ]
            : null,
      ),
      body: PDFView(
        filePath: widget.file.path,
        onRender: (pages) => setState(() => this.pages = pages),
        onViewCreated: (controller) =>
            setState(() => this.controller = controller),
        onPageChanged: (indexPage, _) =>
            setState(() => this.indexPage = indexPage),
      ),
    );
  }
}




