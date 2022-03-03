import 'dart:convert';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:osmanbaba/Widgets/appBar.dart';
import 'package:osmanbaba/Widgets/drawer.dart';
import 'package:osmanbaba/Widgets/spinCBBH.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();

}
Future<void> listQuestion(String Id,BuildContext context) async{
  final url = Uri.parse(webURL + 'api/QuestionBySourceId');
  final headers = {
    "Content-type": "application/json",
    "lang": Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode.toString(),

  };
  final response = await post(url, headers: headers, body:jsonEncode(
      {
        "id": Id
      }
  ));

  if (response.statusCode == 200) {
    var decoded = jsonDecode(response.body);
    decoded = decoded["description"];
    return decoded;
  } else {
    throw Exception('Failed to load');
  }
}

class _HelpState extends State<Help> {

  Future<void> listSourceQuestion() async{
    final headers = {
      "Content-type": "application/json",
      "lang": Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode.toString(),

    };
    final url = await http.get(Uri.parse(webURL + 'api/SourceQuestion'),headers: headers );
    var response = jsonDecode(url.body);
    if(response['status']){
      response = response["description"];
      return response;
    }
  }
  @override
  void initState() {
    listSourceQuestion();
    super.initState();
  }
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
                        Text((Localizations.of<AppLocalizations>
                        (context, AppLocalizations).getTranslation("faqDefinition"))
                          ,style: TextStyle(fontSize: 20,color: Color.fromRGBO(46, 96, 113, 1)),),
                        SizedBox(height: 10,),
                        Container(
                          margin: EdgeInsets.only(bottom: 100),
                            child: FutureBuilder(
                              future: listSourceQuestion(),
                              builder: (context,snapshot){
                                if(snapshot.hasData){
                                  return ListView.builder(itemCount: snapshot.data.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context,i){
                                      return Container(
                                        padding: EdgeInsets.only(top: 15,left: 10,right: 10),
                                        margin: EdgeInsets.all(5),
                                        width: (MediaQuery.of(context).size.width*0.98),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black54,blurRadius: 2)
                                            ]
                                        ),
                                        child: ExpandablePanel(
                                          header: Text(
                                            "${snapshot.data[i]["source"].toString()}",
                                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.orange),),
                                          expanded: Container(
                                            height: 200,
                                            child:Question(snapshot.data[i]["id"].toString()) ,

                                          ), collapsed: null,
                                        ),
                                      );
                                    },
                                  );

                                }else{
                                  return Center();
                                }
                              },
                            )
                        ),
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
}


class Question extends StatelessWidget {
  String id;
  Question(this.id);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: listQuestion(id,context),
      builder: (context,snapshot){
        if(snapshot.hasData){
          return ListView.builder(itemCount: snapshot.data.length,
            itemBuilder: (context,i){
              return TextButton(
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                          builder: (context, setState) {
                            // ANA DETAYLAR DIALOG
                            return AlertDialog(
                              title: Text(
                                "${snapshot.data[i]["question"]}",textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.orange),),
                              content:  SingleChildScrollView(
                                child: Container(
                                  child: Html(data : snapshot.data[i]["answer"].toString(),defaultTextStyle:
                                  TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color.fromRGBO(46, 96, 113, 1)),)),
                              ),
                              actions: <Widget>[

                              ],
                            );
                          }
                      ),
                    ),
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text("${i+1}. ${snapshot.data[i]["question"].toString()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color.fromRGBO(46, 96, 113, 1),),),
                          ),
                        ],
                      ),
                    ),
                  );
            },
          );

        }else{
          return Text("Sorular yok",style: TextStyle(color: Colors.black,fontSize: 15),);
        }
      },
    );
  }
}



