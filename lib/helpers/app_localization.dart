import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  AppLocalizations(this.locale);

  Map<String, String> languageMap = Map();

  Future load() async {
//    locale = new Locale('ar');
    final fileString = await rootBundle
        .loadString('lang/${locale.languageCode}.json');
    final Map<String, dynamic> mapData = json.decode(fileString);
    languageMap = mapData.map((key, value) => MapEntry(key, value.toString()));
  }

  getTranslation(key) {
    return languageMap[key];
  }

}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {

    return false;
  }
}

//import 'dart:convert';
//import 'dart:async';
//
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;
//
//class AppLocalizations {
//  Locale locale;
//
//  AppLocalizations(this.locale);
//
//
//  static AppLocalizations of(BuildContext context) {
//    return Localizations.of<AppLocalizations>(context, AppLocalizations);
//  }
//
//  static const LocalizationsDelegate<AppLocalizations> delegate =
//      _AppLocalizationsDelegate();
//
//
//  Map<String, String> languageMap;
//
//  Future<bool> load() async {
//    String fileString = await rootBundle
//        .loadString('assets/lang/${locale.languageCode}.json');
//
//    Map<String, dynamic> mapData = json.decode(fileString);
//
//    languageMap = mapData.map((key, value) => MapEntry(key, value.toString()));
//
//    return true;
//  }
//
//  getTranslation(String key) {
//    return languageMap[key];
//  }
//}
//
//class _AppLocalizationsDelegate
//    extends LocalizationsDelegate<AppLocalizations> {
//
//  const _AppLocalizationsDelegate();
//
//  @override
//  bool isSupported(Locale locale) {
//    return ['en', 'ar', 'tr'].contains(locale.languageCode);
//  }
//
//  @override
//  Future<AppLocalizations> load(Locale locale) async {
//    AppLocalizations localizations = new AppLocalizations(locale);
//    await localizations.load();
//    return localizations;
//  }
//
//  @override
//  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
//    // TODO: implement shouldReload
//    return false;
//  }
//}
//
