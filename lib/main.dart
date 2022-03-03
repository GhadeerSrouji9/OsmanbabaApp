import 'package:custom_splash/custom_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:osmanbaba/pages/contracts.dart';
import 'package:osmanbaba/pages/facebook.dart';
import 'package:osmanbaba/pages/mersis.dart';
import 'package:osmanbaba/pages/pdf_sync.dart';
import 'package:osmanbaba/provider/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:osmanbaba/pages/help.dart';
import 'pages/second.dart';
import 'helpers/app_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

AndroidNotificationChannel channel;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  await fetchLanguagePreference();

  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

fetchLanguagePreference() async{

  Map<String, String> languageCountryCode = {
    'en': 'US',
    'ar': 'SAR',
    'tr': 'TR',
  };

  SharedPreferences prefs = await SharedPreferences.getInstance();

  String langCode = prefs.getString('languageCode') ?? 'tr';
  isLanguageSpecified = prefs.getBool('isLanguageSpecified') ?? false;

  String countryCode = languageCountryCode[langCode];

  globalLocale = new Locale(langCode, countryCode);

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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


      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(245, 124, 0, 1),
        primaryColorLight: Color.fromRGBO(255, 173, 66, 1),
        primaryColorDark: Color.fromRGBO(187, 77, 0, 1),
        primarySwatch: Colors.orange,
      ),

      home: Container(
        child: CustomSplash(
          imagePath: 'assets/imgs/orangesplash.png',
          backGroundColor: Color.fromRGBO(247, 247, 247, 1.0),
          animationEffect: 'fade-in',
          duration: 3000,
//        customFunction: lang(),
          home: MainHP(),
          type: CustomSplashType.StaticDuration,
        ),
      ),
    );
  }

}

class MainHP extends StatefulWidget {
  const MainHP({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainHP> {
  String username = null;
  String password = null;


  fetchLoginPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     username = prefs.getString('username');
     password = prefs.getString('password');
     token = prefs.getString('token');
   });
  }

  @override
  void initState() {
    fetchLoginPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentLocale =
        Localizations.of<AppLocalizations>(context, AppLocalizations)
            .locale
            .languageCode;


     return Second(
         {
           'username': username,
           'password': password,
           'isLoggedIn': false
         },
         null,
         true,
     );
    // return contracts();


  }

}
