import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'package:osmanbaba/pages/second.dart';
import 'package:osmanbaba/pages/translate.dart';
import 'drawer.dart';
final String assetsURL = 'assets/imgs/';

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

class appbar extends StatelessWidget {
  final BuildContext _context;
  final _advancedDrawerController ;
  appbar(this._context,this._advancedDrawerController);

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
  @override
  Widget build(BuildContext context) {

    return  new AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.grey[50],
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.orange[800],
          ),
          title: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _handleMenuButtonPressed();
                    },
                    child: Image(
                      image: AssetImage(assetsURL + 'menu.png'),
                      height: 20,
                    ),
                  ),
                  SizedBox(width: (MediaQuery.of(context).size.width/30)),
                  InkWell(
                    onTap: (){
                      Navigator.push(
                          this._context,
                          new MaterialPageRoute(builder: (context) => new Second(null, null, true))
                      );
                    } ,
                    child: Image(
                      image: AssetImage('assets/imgs/footerob.png'),
                      height: 35,
                    ),
                  ),
                  SizedBox(width: (MediaQuery.of(context).size.width/30)),
                  InkWell(
                    onTap: () async{
                      await getKind(context);
                      await getLanguage();
                      print("wwwwww" + languageList.toString());
                      Navigator.push(
                          this._context,
                          new MaterialPageRoute(builder: (context) => new Translate(kindList, languageList))
                      );
                    } ,
                    child: Image(
                      image: AssetImage('assets/imgs/translate.png'),
                      height: 35,
                    ),
                  ),
                ],
              ),
            ),
          ),

    );
  }
}


