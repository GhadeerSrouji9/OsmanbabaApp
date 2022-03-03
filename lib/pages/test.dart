import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';

class Ad extends StatefulWidget {

  Ad({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AdState();
  }
}

class _AdState extends State<Ad> {
  static final String assetsURL = 'assets/imgs/';
  List<Image> phImgList = [
    Image.asset(assetsURL + 'ad2.jpg', fit: BoxFit.cover),
    Image.asset(assetsURL + 'ad3.jpg', fit: BoxFit.cover),
    Image.asset(assetsURL + 'ad4.png', fit: BoxFit.cover),
    Image.asset(assetsURL + 'ad1.jpg', fit: BoxFit.cover)
  ];




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
      locale: globalLocale,

      theme: ThemeData(
//          primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColor: Color.fromRGBO(200, 100, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.orange,
          // TODO: CONTINUE WITH IMPLEMENTING LANGUAGE BASED ON LOCALE PROBABLY?????
          fontFamily: Localizations.localeOf(context).toString() == 'ar_SAR' ? "Bahij_Muna" : "",//isLanguageSpecified ? "Bahij_Muna":"",
//            fontFamily: "Bahij_Muna", //isLanguageSpecified ? "Bahij_Muna":"",


//            displayColor: Colors.blue,
        ),
        hintColor: Colors.orange,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.orange, fontSize: 24.0),
        ),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.33,
                        width: double.infinity,
                        child: Carousel(
                          dotSize: 0.0,
                          autoplay: false,
                          dotSpacing: 0,
                          indicatorBgPadding: 0,
                          images: phImgList,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: Colors.orange,
                    indicatorColor: Colors.orange,
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.contact_mail),
                      ),
                      Tab(
                        icon: Icon(Icons.phone_iphone),
                      ),
                      Tab(
                        icon: Icon(Icons.info),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16),
                                    child: Icon(
                                      Icons.all_inclusive,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        Localizations.of<AppLocalizations>(
                                            context, AppLocalizations)
                                            .getTranslation('text') +
                                            (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        Localizations.of<AppLocalizations>(
                                            context, AppLocalizations)
                                            .getTranslation('text1') +
                                            (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        Localizations.of<AppLocalizations>(
                                            context, AppLocalizations)
                                            .getTranslation('text2') +
                                            (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16),
                                    child: Icon(
                                      Icons.all_inclusive,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16),
                                    child: Icon(
                                      Icons.all_inclusive,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' ' + (index + 1).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
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
}