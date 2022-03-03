import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/aboutUs.dart';
import 'package:osmanbaba/pages/contracts.dart';
import 'package:osmanbaba/pages/help.dart';
import 'package:osmanbaba/pages/whyOsmanbaba.dart';
import 'package:osmanbaba/pages/add_ad.dart';
import 'package:osmanbaba/pages/auth/login.dart';
import 'package:osmanbaba/pages/categories.dart';
import 'package:osmanbaba/pages/company.dart';
import 'package:osmanbaba/pages/eSignature.dart';
import 'package:osmanbaba/pages/stateAid.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';


final List<String> dropdownNameItems=[""];

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

var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};

List<Map<String, dynamic>> kindList = [];
Future<List<String>> getKind(context) async{
  String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;
  final url = await http.get(Uri.parse(webURL + 'api/ListKind'));
  kindList=[];
  var response=jsonDecode(url.body);
  if(response['status']){
    for(int i = 0; i < response["description"].length; i++){
      kindList.add(
          {
            "id": response["description"][i]["id"],
            "name": response["description"][i]["name_" + currentLocale],
            "price": response["description"][i]["price"]
          }
      );
      print(currentLocale + "33333");
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
    }
  }
}

Future<void> storeLanguagePreference(val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  globalLocale = Locale(val, langMap[val]);
  await prefs.setString('languageCode', globalLocale.languageCode);
  await prefs.setString('countryCode', globalLocale.countryCode);
  await prefs.setBool('isLanguageSpecified', true);
}
class Drawers extends StatefulWidget {
  const Drawers({ Key key }) : super(key: key);

  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<Drawers> {
  String lang(context){

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
  Future <void> fetchSignOutPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('email');
    await prefs.remove ('id');
    setState(() {
      token= null;
      isToken=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:Column(
          children: [
            Container(
              width: double.infinity,
              height: (MediaQuery.of(context).size.height/4),
              margin: const EdgeInsets.only(
                top: 24.0,
                bottom: 64.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Image.asset(
                'assets/imgs/loogo.png',
                height: 200.0,
              ),
            ),
            Container(
              width: 200,
              height: (MediaQuery.of(context).size.height*0.45),
              child: ListTileTheme(
                textColor: Colors.white,
                iconColor: Colors.white,
                child: Container(
                    width: 200,
                    child:ListView(
                      children: [
                        ListTile(
                          onTap: (){
                            //                                List<Map<String, dynamic>> categories = await fetchCategories();
                            List<Map<String, dynamic>> categories = [];
                            String s;
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Categories(s))
                            );
                          },
                          leading: Icon(Icons.category),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('categories')),
                            style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () async{
                            await getKind(context);
                            await getLanguage();
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Translate(kindList, languageList))
                            );
                          },
                          leading: Image(
                              height: 25,
                              image: AssetImage("assets/imgs/trans.png")),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('etranslate')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

                          ),
                        ),
                        ListTile(
                          onTap: () async{
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Company())
                            );
                          },
                          leading: Icon(Icons.business),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('company')),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          onTap: () async{
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new AddAd())
                            );
                          },
                          leading: Icon(Icons.add_comment_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('addAds')),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          onTap: () async{
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Esignature())
                            );
                          },
                          leading: Icon(Icons.border_color_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('eimza')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new StateAid())
                            );
                          },
                          leading: Icon(Icons.card_giftcard_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('stateaid')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new WhyOsmanbaba())
                            );
                          },
                          leading: Icon(Icons.quiz_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('whyOsmanbaba')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new AboutUs())
                            );
                          },
                          leading: Icon(Icons.groups_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('about')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new contracts())
                            );
                          },
                          leading: Icon(Icons.article_outlined ),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('contracts')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Help())
                            );
                          },
                          leading: Icon(Icons.assignment_late_outlined),
                          title: Text((Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('faq')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        isToken ? ListTile(
                          onTap: () {
                            fetchSignOutPreference();
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Login())
                            );
                          },
                          leading: Icon(Icons.logout),
                          title: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('signout'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ): ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => new Login())
                            );
                          },
                          leading: Icon(Icons.logout),
                          title: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('login'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ),

                        // FLAGS
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16.0, right: 16),
                              child: Icon(Icons.language, color: Colors.white,),
                            ),
                            SizedBox(width: 20,),
                            Container(
                              //margin: EdgeInsets.only(left: 32),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                    canvasColor: Colors.orange
                                ),
                                child: DropdownButton<String>(
                                  iconEnabledColor: Colors.white,
                                  value: lang(context),
                                  //                          value: globalLocale.languageCode,//Localizations.localeOf(context),
                                  iconSize: 24,
                                  // icon: Visibility (visible: false, child: Icon(Icons.arrow_downward)),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  onChanged: (String newValue) {
                                    // Gonna use this onChanged listener to change icon
                                    setState(() async{
                                      await storeLanguagePreference(langShort(newValue));
                                      isLanguageSpecified = true;
                                      Phoenix.rebirth(this.context);
                                    });
                                  },
                                  items: <String>['English', 'Arabic', 'Turkish'].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(
                                        child: Container(
                                          color: Colors.orange,
                                          // height: 20.0,
                                          child: Text(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation(value),), //flagImages[fetchFlagImage(value)]
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.white,
              ),
            )
          ],
        )

    );
  }
}