import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/Packages.dart';
import 'package:osmanbaba/pages/auth/login.dart';
import 'package:osmanbaba/pages/chat.dart';
import 'package:osmanbaba/pages/eSignature.dart';
import 'package:osmanbaba/pages/help.dart';
import 'package:osmanbaba/pages/second.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:http/http.dart' as http;

List<Map<String, dynamic>> packages = [];
class spincbbh extends StatefulWidget {
  final BuildContext parentContext;
  spincbbh(this.parentContext);

  @override
  _spincbbhState createState() => _spincbbhState();
}

class _spincbbhState extends State<spincbbh> {
  Future<void> fetchPackages() async {
    String currentLocale = Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode;
    final response = await http.get(Uri.parse(webURL + 'api/ListPackage'));

    var decoded = jsonDecode(response.body);
    if (decoded["status"]) {
      decoded = decoded["description"];
      setState(() {
        for(int i = 0; i < decoded.length; i++){
          packages.add(
              {
                "id": decoded[i]["id"],
                "name": decoded[i]["name_" + currentLocale],
                "numberAd": decoded[i]["numberAd"],
                "number30": decoded[i]["number30"],
                "numberBold": decoded[i]["numberBold"],
                "numberBanner": decoded[i]["numberBanner"],
                "search": decoded[i]["search"],
                "socialMedia": decoded[i]["socialMedia"],
                "message": decoded[i]["message"],
                "price": decoded[i]["price"],
                "addtionalPrice": decoded[i]["addtionalPrice"],
                "priceYear": decoded[i]["priceYear"],
                "price6Month": decoded[i]["price6Month"],
                "used": decoded[i]["used"],
                "active": decoded[i]["active"],
              }
          );
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 170,
        width: MediaQuery.of(context).size.width,
        child: SpinCircleBottomBarHolder(
          bottomNavigationBar: SCBottomBarDetails(
              circleColors: [Colors.white, Colors.orange, Colors.orangeAccent],
              iconTheme: IconThemeData(color: Colors.orange, size: 18),
              activeIconTheme: IconThemeData(color: Colors.orangeAccent, size: 18),
              backgroundColor: Colors.white,
              titleStyle: TextStyle(color: Colors.orange,fontSize: 11),
              activeTitleStyle: TextStyle(color: Colors.orangeAccent,fontSize: 11,fontWeight: FontWeight.bold),
              actionButtonDetails: SCActionButtonDetails(
                  color: Colors.orange,
                  icon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                  elevation: 2),
              elevation: 2.0,
              items: [
                // Suggested count : 4
                SCBottomBarItem(icon: Icons.arrow_back, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('back')), onPressed: () {
                   Navigator.pop(widget.parentContext);
                }),
                SCBottomBarItem(
                    icon: Icons.border_color_outlined,
                    title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('eimza')),
                    onPressed: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => new Esignature()));
                }),
                SCBottomBarItem(icon: FontAwesomeIcons.percent, title: (Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('paketler')),
                    onPressed: () async {
                      await fetchPackages();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new Packages(packages)));
                    }),
                SCBottomBarItem(icon: Icons.chat, title:(Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('mesaj')),
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new Chat()));
                    }),
              ],
              circleItems: [
                //Suggested Count: 3
                SCItem(icon: Icon(Icons.add), onPressed: () {}),
                SCItem(icon: Icon(Icons.print), onPressed: () {}),
                SCItem(icon: Icon(Icons.map), onPressed: () {}),
              ],
              bnbHeight: 75 // Suggested Height 80
          ),
          child: Container(
            width: 109,
            height: 200,
          ),
        ),
      ),
    );
  }
}
